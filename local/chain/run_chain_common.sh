#!/usr/bin/env bash

trainset=parl2015-2020-train
gmm_str=f/tri4j
stage=1
num_leaves=6000
use_cleaned=false

# EGS OPTIONS:
egs_opts="--frames-overlap-per-eg 0 --constrained false"
frames_per_eg=150,110,100

echo "$0 $@" # Print the command line for logging

. ./cmd.sh
. ./path.sh
. ./utils/parse_options.sh

set -eu

$use_cleaned && trainset=${trainset}_cleaned
lores_traindir=data/${trainset}
gmm_dir=exp/${trainset}/${gmm_str}
ali_dir=exp/${trainset}/${gmm_str}_ali_full
gmm_lang=data/lang_${trainset}
lang=data/lang_chain_${trainset}
lat_dir=exp/${trainset}/chain/${gmm_str}_lats
tree_dir=exp/${trainset}/chain/tree

if [ $stage -le 1 ]; then
    echo "$0: Stage 1, prepare data dirs."
    # Train set
    utils/copy_data_dir.sh ${lores_traindir} ${lores_traindir}_hires
    steps/make_mfcc.sh --cmd "$basic_cmd" --nj 8 --mfcc-config conf/mfcc_hires.conf \
        ${lores_traindir}_hires
    steps/compute_cmvn_stats.sh ${lores_traindir}_hires
    # Dev set
    utils/copy_data_dir.sh data/parl2016-dev data/parl2016-dev_hires
    steps/make_mfcc.sh --cmd "$basic_cmd" --nj 8 --mfcc-config conf/mfcc_hires.conf \
        data/parl2016-dev_hires
    steps/compute_cmvn_stats.sh data/parl2016-dev_hires
    # Test 2016 set
    utils/copy_data_dir.sh data/parl2016-test data/parl2016-test_hires
    steps/make_mfcc.sh --cmd "$basic_cmd" --nj 8 --mfcc-config conf/mfcc_hires.conf \
        data/parl2016-test_hires
    steps/compute_cmvn_stats.sh data/parl2016-test_hires
    # Test 2020 set
    utils/copy_data_dir.sh data/parl2020-test data/parl2020-test_hires
    steps/make_mfcc.sh --cmd "$basic_cmd" --nj 8 --mfcc-config conf/mfcc_hires.conf \
        data/parl2020-test_hires
    steps/compute_cmvn_stats.sh data/parl2020-test_hires
fi

if [ $stage -le 2 ]; then
    if [ -f $ali_dir/ali.1.gz ]; then
        echo "$0: alignments in $ali_dir appear to already exist. Please either remove them "
        echo " ... or use a later --stage option."
        exit 1
    fi
    echo "$0: aligning with the data"
    steps/align_fmllr.sh --cmd "$train_cmd" --nj 8 \
        ${lores_traindir} $gmm_lang $gmm_dir $ali_dir || exit 1
fi

if [ $stage -le 3 ]; then
    echo "$0: creating lang directory with one state per phone."
    # Create a version of the lang/ directory that has one state per phone in the
    # topo file. [note, it really has two states.. the first one is only repeated
    # once, the second one has zero or more repeats.]
    if [ -d $lang ]; then
        if [ $lang/L.fst -nt $gmm_lang/L.fst ]; then
            echo "$0: $lang already exists, not overwriting it; continuing"
        else
            echo "$0: $lang already exists and seems to be older than ${gmm_lang}..."
            echo " ... not sure what to do. Exiting."
            exit 1
        fi
    else
        cp -r $gmm_lang $lang
        silphonelist=$(cat $lang/phones/silence.csl) || exit 1
        nonsilphonelist=$(cat $lang/phones/nonsilence.csl) || exit 1
        # Use our special topology... note that later on may have to tune this
        # topology.
        steps/nnet3/chain/gen_topo.py $nonsilphonelist $silphonelist >$lang/topo
    fi
fi

if [ $stage -le 4 ]; then
    # Get the alignments as lattices (gives the chain training more freedom).
    # use the same num-jobs as the alignments
    nj=$(cat ${ali_dir}/num_jobs) || exit 1
    steps/align_fmllr_lats.sh --cmd "$train_cmd" --nj $nj ${lores_traindir} \
        $lang $gmm_dir $lat_dir
    rm $lat_dir/fsts.*.gz # save space
fi

if [ $stage -le 5 ]; then
    # Build a tree using our new topology. We know we have alignments for the
    # speed-perturbed data (local/nnet3/run_ivector_common.sh made them), so use
    # those.
    if [ -f $tree_dir/final.mdl ]; then
        echo "$0: $tree_dir/final.mdl already exists, refusing to overwrite it."
        exit 1
    fi
    steps/nnet3/chain/build_tree.sh --frame-subsampling-factor 3 \
        --context-opts "--context-width=2 --central-position=1" \
        --cmd "$train_cmd" $num_leaves ${lores_traindir} $lang $ali_dir $tree_dir
fi
