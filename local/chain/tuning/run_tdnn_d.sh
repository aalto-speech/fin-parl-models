#!/usr/bin/env bash

# Copyright 2022 Anja Virkkunen, Aku Rouhe
# Apache 2.0

# The same model as the first one, but train for 8 epochs.

trainset=parl2015-2020-train
gmm_str=f/tri4j
stage=0
train_stage=0
lm=test_parl_20M_varikn.bpe19000.d0.0001
use_cleaned=false

# EGS options
frames_per_eg=150,110,100
common_egs_dir=

# NN hyperparams
xent_regularize=0.1
dropout_schedule='0,0@0.20,0.5@0.50,0'

# End configuration section.
echo "$0 $@" # Print the command line for logging

. ./cmd.sh
. ./path.sh
. parse_options.sh

set -eu

if ! cuda-compiled; then
    cat <<EOF && exit 1
This script is intended to be used with GPUs but you have not compiled Kaldi with CUDA
If you want to use GPUs (and have them), go to src/, and configure and make on a machine
where "nvcc" is installed.
EOF
fi

$use_cleaned && trainset=${trainset}_cleaned
traindir=data/${trainset}_hires
tree_dir=exp/${trainset}/chain/tree
lat_dir=exp/${trainset}/chain/${gmm_str}_lats
dir=exp/${trainset}/chain/tdnn_d

if [ $stage -le 0 ]; then
    echo "$0: creating neural net configs using the xconfig parser"

    num_targets=$(tree-info $tree_dir/tree | grep num-pdfs | awk '{print $2}')
    learning_rate_factor=$(echo "print (0.5/$xent_regularize)" | python)
    affine_opts="l2-regularize=0.008 dropout-proportion=0.0 dropout-per-dim=true dropout-per-dim-continuous=true"
    tdnnf_opts="l2-regularize=0.008 dropout-proportion=0.0 bypass-scale=0.75"
    linear_opts="l2-regularize=0.008 orthonormal-constraint=-1.0"
    prefinal_opts="l2-regularize=0.008"
    output_opts="l2-regularize=0.002"

    mkdir -p $dir/configs

    cat <<EOF >$dir/configs/network.xconfig
    input dim=80 name=input

    # please note that it is important to have input layer with the name=input
    # as the layer immediately preceding the fixed-affine-layer to enable
    # the use of short notation for the descriptor
    fixed-affine-layer name=lda input=Append(-1,0,1) affine-transform-file=$dir/configs/lda.mat

    # the first splicing is moved before the lda layer, so no splicing here
    relu-batchnorm-dropout-layer name=tdnn1 $affine_opts dim=1536
    tdnnf-layer name=tdnnf2 $tdnnf_opts dim=1536 bottleneck-dim=160 time-stride=1
    tdnnf-layer name=tdnnf3 $tdnnf_opts dim=1536 bottleneck-dim=160 time-stride=1
    tdnnf-layer name=tdnnf4 $tdnnf_opts dim=1536 bottleneck-dim=160 time-stride=1
    tdnnf-layer name=tdnnf5 $tdnnf_opts dim=1536 bottleneck-dim=160 time-stride=0
    tdnnf-layer name=tdnnf6 $tdnnf_opts dim=1536 bottleneck-dim=160 time-stride=3
    tdnnf-layer name=tdnnf7 $tdnnf_opts dim=1536 bottleneck-dim=160 time-stride=3
    tdnnf-layer name=tdnnf8 $tdnnf_opts dim=1536 bottleneck-dim=160 time-stride=3
    tdnnf-layer name=tdnnf9 $tdnnf_opts dim=1536 bottleneck-dim=160 time-stride=3
    tdnnf-layer name=tdnnf10 $tdnnf_opts dim=1536 bottleneck-dim=160 time-stride=3
    tdnnf-layer name=tdnnf11 $tdnnf_opts dim=1536 bottleneck-dim=160 time-stride=3
    tdnnf-layer name=tdnnf12 $tdnnf_opts dim=1536 bottleneck-dim=160 time-stride=3
    tdnnf-layer name=tdnnf13 $tdnnf_opts dim=1536 bottleneck-dim=160 time-stride=3
    tdnnf-layer name=tdnnf14 $tdnnf_opts dim=1536 bottleneck-dim=160 time-stride=3
    tdnnf-layer name=tdnnf15 $tdnnf_opts dim=1536 bottleneck-dim=160 time-stride=3
    tdnnf-layer name=tdnnf16 $tdnnf_opts dim=1536 bottleneck-dim=160 time-stride=3
    tdnnf-layer name=tdnnf17 $tdnnf_opts dim=1536 bottleneck-dim=160 time-stride=3
    linear-component name=prefinal-l dim=256 $linear_opts

    prefinal-layer name=prefinal-chain input=prefinal-l $prefinal_opts big-dim=1536 small-dim=256
    output-layer name=output include-log-softmax=false dim=$num_targets $output_opts

    prefinal-layer name=prefinal-xent input=prefinal-l $prefinal_opts big-dim=1536 small-dim=256
    output-layer name=output-xent dim=$num_targets learning-rate-factor=$learning_rate_factor $output_opts
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
        --egs.opts "--frames-overlap-per-eg 0 --constrained false" \
        --egs.chunk-width $frames_per_eg \
        --cleanup.remove-egs false \
        --feat.cmvn-opts "--norm-means=false --norm-vars=false" \
        --chain.xent-regularize $xent_regularize \
        --chain.leaky-hmm-coefficient 0.1 \
        --chain.l2-regularize 0.0 \
        --chain.apply-deriv-weights false \
        --chain.lm-opts="--num-extra-lm-states=2000" \
        --trainer.dropout-schedule $dropout_schedule \
        --trainer.add-option="--optimization.memory-compression-level=2" \
        --trainer.num-chunk-per-minibatch 64 \
        --trainer.frames-per-iter 2500000 \
        --trainer.num-epochs 8 \
        --trainer.optimization.num-jobs-initial 1 \
        --trainer.optimization.num-jobs-final 4 \
        --trainer.optimization.initial-effective-lrate 0.00015 \
        --trainer.optimization.final-effective-lrate 0.000015 \
        --trainer.max-param-change 2.0 \
        --feat-dir $traindir \
        --tree-dir $tree_dir \
        --lat-dir $lat_dir \
        --dir $dir
fi

if [ $stage -le 2 ]; then
    # Network training
    run.pl $dir/log/train_network.log \
        steps/nnet3/chain/train.py \
        --stage $train_stage \
        --cmd "$nnet_cmd" \
        --egs.chunk-width $frames_per_eg \
        --cleanup.remove-egs false \
        --feat.cmvn-opts "--norm-means=false --norm-vars=false" \
        --chain.xent-regularize $xent_regularize \
        --chain.leaky-hmm-coefficient 0.1 \
        --chain.l2-regularize 0.0 \
        --chain.apply-deriv-weights false \
        --chain.lm-opts="--num-extra-lm-states=2000" \
        --trainer.dropout-schedule $dropout_schedule \
        --trainer.add-option="--optimization.memory-compression-level=2" \
        --trainer.num-chunk-per-minibatch 64 \
        --trainer.frames-per-iter 2500000 \
        --trainer.num-epochs 8 \
        --trainer.optimization.num-jobs-initial 1 \
        --trainer.optimization.num-jobs-final 4 \
        --trainer.optimization.initial-effective-lrate 0.00015 \
        --trainer.optimization.final-effective-lrate 0.000015 \
        --trainer.max-param-change 2.0 \
        --feat-dir $traindir \
        --tree-dir $tree_dir \
        --lat-dir $lat_dir \
        --dir $dir
fi

if [ $stage -le 3 ]; then
    utils/mkgraph.sh --self-loop-scale 1.0 --remove-oov data/lang_$lm $dir $dir/graph_$lm

    steps/nnet3/decode.sh --acwt 1.0 --post-decode-acwt 10.0 \
        --nj 16 --cmd "$basic_cmd" \
        $dir/graph_$lm data/parl2016-dev_hires $dir/decode_parl2016-dev_$lm
fi
