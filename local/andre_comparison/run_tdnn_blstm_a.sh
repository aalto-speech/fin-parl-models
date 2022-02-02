#!/usr/bin/env bash
set -e

# Flow
stage=0
train_stage=0
train_set=parl-train-unfiltered
decode_set=parl-dev-all
gmm_str="i/tri4j"
lm=test_parl_20M_varikn.bpe19000.d0.0001

# EGS options
frames_per_eg=140,100,160
chunk_left_context=40
chunk_right_context=40
common_egs_dir=

# NN hyperparams
xent_regularize=0.025
dropout_schedule='0,0@0.20,0.1@0.50,0'
label_delay=0

# End configuration section.
echo "$0 $@"  # Print the command line for logging

. ./cmd.sh
. ./path.sh
. ./utils/parse_options.sh

if ! cuda-compiled; then
  cat <<EOF && exit 1
This script is intended to be used with GPUs but you have not compiled Kaldi with CUDA
If you want to use GPUs (and have them), go to src/, and configure and make on a machine
where "nvcc" is installed.
EOF
fi

train_data_dir=data/andre_comparison/${train_set}_hires
tree_dir=exp/andre_comparison/chain/tree
lat_dir=exp/andre_comparison/chain/${gmm_str}_${train_set}_lats
dir=exp/andre_comparison/chain/tdnn_blstm_a_multigpu

if [ $stage -le 0 ]; then
  echo "$0: creating neural net configs using the xconfig parser";

  num_targets=$(tree-info $tree_dir/tree | grep num-pdfs | awk '{print $2}')
  [ -z $num_targets ] && { echo "$0: error getting num-targets"; exit 1; }
  learning_rate_factor=$(echo "print (0.5/$xent_regularize)" | python)

  lstm_opts="decay-time=20 dropout-proportion=0.0"

  mkdir -p $dir/configs
  cat <<EOF > $dir/configs/network.xconfig
  input dim=80 name=input

  # please note that it is important to have input layer with the name=input
  # as the layer immediately preceding the fixed-affine-layer to enable
  # the use of short notation for the descriptor
  fixed-affine-layer name=lda input=Append(-2,-1,0,1,2) affine-transform-file=$dir/configs/lda.mat

  # the first splicing is moved before the lda layer, so no splicing here
  relu-renorm-layer name=tdnn1 dim=1024
  relu-renorm-layer name=tdnn2 input=Append(-1,0,1) dim=1024
  relu-renorm-layer name=tdnn3 input=Append(-1,0,1) dim=1024

  # check steps/libs/nnet3/xconfig/lstm.py for the other options and defaults
  fast-lstmp-layer name=blstm1-forward input=tdnn3 cell-dim=1024 recurrent-projection-dim=256 non-recurrent-projection-dim=256 delay=-3 $lstm_opts
  fast-lstmp-layer name=blstm1-backward input=tdnn3 cell-dim=1024 recurrent-projection-dim=256 non-recurrent-projection-dim=256 delay=3 $lstm_opts

  fast-lstmp-layer name=blstm2-forward input=Append(blstm1-forward, blstm1-backward) cell-dim=1024 recurrent-projection-dim=256 non-recurrent-projection-dim=256 delay=-3 $lstm_opts
  fast-lstmp-layer name=blstm2-backward input=Append(blstm1-forward, blstm1-backward) cell-dim=1024 recurrent-projection-dim=256 non-recurrent-projection-dim=256 delay=3 $lstm_opts

  fast-lstmp-layer name=blstm3-forward input=Append(blstm2-forward, blstm2-backward) cell-dim=1024 recurrent-projection-dim=256 non-recurrent-projection-dim=256 delay=-3 $lstm_opts
  fast-lstmp-layer name=blstm3-backward input=Append(blstm2-forward, blstm2-backward) cell-dim=1024 recurrent-projection-dim=256 non-recurrent-projection-dim=256 delay=3 $lstm_opts

  ## adding the layers for chain branch
  output-layer name=output input=Append(blstm3-forward, blstm3-backward) output-delay=$label_delay include-log-softmax=false dim=$num_targets max-change=1.5

  # adding the layers for xent branch
  # This block prints the configs for a separate output that will be
  # trained with a cross-entropy objective in the 'chain' models... this
  # has the effect of regularizing the hidden parts of the model.  we use
  # 0.5 / args.xent_regularize as the learning rate factor- the factor of
  # 0.5 / args.xent_regularize is suitable as it means the xent
  # final-layer learns at a rate independent of the regularization
  # constant; and the 0.5 was tuned so as to make the relative progress
  # similar in the xent and regular final layers.
  output-layer name=output-xent input=Append(blstm3-forward, blstm3-backward) output-delay=$label_delay dim=$num_targets learning-rate-factor=$learning_rate_factor max-change=1.5
EOF
  steps/nnet3/xconfig_to_configs.py --xconfig-file $dir/configs/network.xconfig --config-dir $dir/configs/
fi

if [ $stage -le 1 ]; then
	# Chain prep (egs, phone-lm, etc.) separately:

  steps/nnet3/chain/train.py \
		--stage -10 \
		--exit-stage 0 \
    --cmd "$basic_cmd" \
    --egs.cmd "$egs_cmd" \
    --egs.stage -10 \
    --egs.opts "--frames-overlap-per-eg 0" \
    --egs.chunk-width $frames_per_eg \
    --egs.chunk-left-context $chunk_left_context \
    --egs.chunk-right-context $chunk_right_context \
    --egs.chunk-left-context-initial=0 \
    --egs.chunk-right-context-final=0 \
    --cleanup.remove-egs false \
    --feat.cmvn-opts "--norm-means=false --norm-vars=false" \
    --chain.xent-regularize $xent_regularize \
    --chain.leaky-hmm-coefficient 0.1 \
    --chain.l2-regularize 0.00005 \
    --chain.apply-deriv-weights false \
    --chain.lm-opts="--num-extra-lm-states=2000" \
    --trainer.dropout-schedule $dropout_schedule \
    --trainer.num-chunk-per-minibatch 64 \
    --trainer.frames-per-iter 1200000 \
    --trainer.num-epochs 8 \
    --trainer.optimization.shrink-value 0.99 \
    --trainer.optimization.momentum 0.0 \
    --trainer.optimization.num-jobs-initial 1 \
    --trainer.optimization.num-jobs-final 4 \
    --trainer.optimization.initial-effective-lrate 0.001 \
    --trainer.optimization.final-effective-lrate 0.0001 \
    --trainer.max-param-change 2.0 \
    --trainer.deriv-truncate-margin 8 \
    --feat-dir $train_data_dir \
    --tree-dir $tree_dir \
    --lat-dir $lat_dir \
    --dir $dir  || exit 1;
fi

if [ $stage -le 2 ]; then
	# Network training
  run.pl $dir/log/train_network.log \
		steps/nnet3/chain/train.py \
			--stage $train_stage \
			--cmd "$nnet_cmd" \
			--egs.chunk-width $frames_per_eg \
			--egs.chunk-left-context $chunk_left_context \
			--egs.chunk-right-context $chunk_right_context \
			--egs.chunk-left-context-initial=0 \
			--egs.chunk-right-context-final=0 \
			--cleanup.remove-egs false \
			--feat.cmvn-opts "--norm-means=false --norm-vars=false" \
			--chain.xent-regularize $xent_regularize \
			--chain.leaky-hmm-coefficient 0.1 \
			--chain.l2-regularize 0.00005 \
			--chain.apply-deriv-weights false \
			--chain.lm-opts="--num-extra-lm-states=2000" \
			--trainer.dropout-schedule $dropout_schedule \
			--trainer.num-chunk-per-minibatch 64 \
			--trainer.frames-per-iter 1200000 \
			--trainer.num-epochs 8 \
			--trainer.optimization.shrink-value 0.99 \
			--trainer.optimization.momentum 0.0 \
			--trainer.optimization.num-jobs-initial 1 \
			--trainer.optimization.num-jobs-final 4 \
			--trainer.optimization.initial-effective-lrate 0.001 \
			--trainer.optimization.final-effective-lrate 0.0001 \
			--trainer.max-param-change 2.0 \
			--trainer.deriv-truncate-margin 8 \
			--feat-dir $train_data_dir \
			--tree-dir $tree_dir \
			--lat-dir $lat_dir \
			--dir $dir  || exit 1;
fi

if [ $stage -le 3 ]; then
	utils/mkgraph.sh --self-loop-scale 1.0 --remove-oov data/lang_$lm $dir $dir/graph_$lm
	
  frames_per_chunk=$(echo $frames_per_eg | cut -d, -f1)
	steps/nnet3/decode.sh --acwt 1.0 --post-decode-acwt 10.0 \
			--nj 16 --cmd "$basic_cmd" \
			--extra-left-context $chunk_left_context  \
			--extra-right-context $chunk_right_context  \
			--extra-left-context-initial 0 \
			--extra-right-context-final 0 \
			--frames-per-chunk "$frames_per_chunk" \
			$dir/graph_$lm data/${decode_set}_hires $dir/decode_${decode_set}_$lm
fi

