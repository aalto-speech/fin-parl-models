#!/bin/bash

train_set=parl-train-2008-2020-kevat
lores_traindir=data/combined_comparison/${train_set}
gmm_str=i/tri4j

gmm_dir=exp/combined_comparison/${gmm_str}
ali_dir=exp/combined_comparison/${gmm_str}_ali_${train_set}
lang=data/combined_comparison/lang_chain
lat_dir=exp/combined_comparison/chain/${gmm_str}_${train_set}_lats
tree_dir=exp/combined_comparison/chain/tree

stage=1
num_leaves=6000

# EGS OPTIONS:

egs_opts="--frames-overlap-per-eg 0 --constrained false"
frames_per_eg=150,110,100


. ./cmd.sh
. ./path.sh
. ./utils/parse_options.sh


# -- Step 1, Features --

if [ $stage -le 1 ]; then
	echo "$0: Stage 1, prepare data dirs."
	# Training set
	utils/copy_data_dir.sh ${lores_traindir} ${lores_traindir}_hires
	steps/make_mfcc.sh --nj 32 --cmd "$basic_cmd" --mfcc-config conf/mfcc_hires.conf ${lores_traindir}_hires
	steps/compute_cmvn_stats.sh ${lores_traindir}_hires
fi

if [ $stage -le 2 ]; then
  if [ -f $ali_dir/ali.1.gz ]; then
    echo "$0: alignments in $ali_dir appear to already exist. Please either remove them "
    echo " ... or use a later --stage option."
    exit 1
  fi
  echo "$0: aligning with the data"
  steps/align_fmllr.sh --nj 100 --cmd "$train_cmd" \
    ${lores_traindir} data/combined_comparison/lang_train $gmm_dir $ali_dir || exit 1
fi

if [ $stage -le 3 ]; then
  echo "$0: creating lang directory with one state per phone."
  # Create a version of the lang/ directory that has one state per phone in the
  # topo file. [note, it really has two states.. the first one is only repeated
  # once, the second one has zero or more repeats.]
  if [ -d $lang ]; then
    if [ $lang/L.fst -nt data/combined_comparison/lang_train/L.fst ]; then
      echo "$0: $lang already exists, not overwriting it; continuing"
    else
      echo "$0: $lang already exists and seems to be older than data/combined_comparison/lang_train..."
      echo " ... not sure what to do. Exiting."
      exit 1;
    fi
  else
    cp -r data/combined_comparison/lang_train $lang
    silphonelist=$(cat $lang/phones/silence.csl) || exit 1;
    nonsilphonelist=$(cat $lang/phones/nonsilence.csl) || exit 1;
    # Use our special topology... note that later on may have to tune this
    # topology.
    steps/nnet3/chain/gen_topo.py $nonsilphonelist $silphonelist >$lang/topo
  fi
fi

if [ $stage -le 4 ]; then
  # Get the alignments as lattices (gives the chain training more freedom).
  # use the same num-jobs as the alignments
  nj=$(cat ${ali_dir}/num_jobs) || exit 1;
  steps/align_fmllr_lats.sh --nj $nj --cmd "$train_cmd" ${lores_traindir} \
    $lang $gmm_dir $lat_dir
  rm $lat_dir/fsts.*.gz # save space
fi

if [ $stage -le 5 ]; then
  # Build a tree using our new topology. We know we have alignments for the
  # speed-perturbed data (local/nnet3/run_ivector_common.sh made them), so use
  # those.
  if [ -f $tree_dir/final.mdl ]; then
    echo "$0: $tree_dir/final.mdl already exists, refusing to overwrite it."
    exit 1;
  fi
  steps/nnet3/chain/build_tree.sh --frame-subsampling-factor 3 \
      --context-opts "--context-width=2 --central-position=1" \
      --cmd "$train_cmd" $num_leaves ${lores_traindir} $lang $ali_dir $tree_dir
fi

# Turns out that get_egs.sh takes the chain model directory as one
# arg. So it can only be called after running some of the earliest stages of
# chain/train.py. So it's not convenient to run it here after all.
# Shame tbh.
#if [ $stage -le 6 ]; then
#	# Make training example archives:
#	if [ -f $egs_dir/cegs.1.ark ]; then
#		echo "$0: $egs_dir/cegs.1.ark already exists, refusing to overwrite egs"
#		exit 1
#	fi
#  steps/nnet3/chain/get_egs.sh \
#		--cmd "$egs_cmd" \
#		--cmvn-opts "--norm-means=false --norm-vars=false" \
#		--frame-subsampling-factor 3 \
#		--frames-per-iter 2500000 \
#		--frames-per-eg ${frames_per_eg} \
#		${egs_opts} \
#		${lores_traindir}_hires
#
#		#{data} {dir} {lat_dir} {egs_dir}
#fi
