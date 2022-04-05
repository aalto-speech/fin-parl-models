#!/usr/bin/env bash

# Copyright 2022 Anja Virkkunen, Aku Rouhe
# Apache 2.0

# Run clean up script with the best HMM-GMM model (f/tri4j).

stage=1
suffix=cleaned
clean_cmd="run.pl"
clean_nj=120
nj=40
evaluate_gmm=false
lm=test_parl_20M_varikn.bpe19000.d0.0001

echo "$0 $@" # Print the command line for logging

. ./cmd.sh
. ./path.sh
. parse_options.sh

set -eu

if [ "$#" -ne 3 ]; then
    echo "Usage: local/run_cleanup.sh <trainset> <lang> <gmmstr>"
    echo "e.g.: $0 train data/lang_train f/tri4j"
    echo "Run the data clean up script with the best GMM."
    echo
    exit 1
fi

trainset=$1
lang=$2
gmmstr=$3

data=data/${trainset}
cleaned_data=data/${trainset}_${suffix}
gmmdir=exp/${trainset}/$gmmstr
dir=exp/${trainset}/${gmmstr}_${suffix}_work
ali_dir=exp/${trainset}/${gmmstr}_ali_full_${suffix}
cleaned_dir=exp/${trainset}_${suffix}/${gmmdir}

if [ $stage -le 1 ]; then
    echo "Step 1: Run clean up script."
    steps/cleanup/clean_and_segment_data.sh --cmd "$clean_cmd" --nj $clean_nj \
        $data $lang $gmmdir $dir $cleaned_data
fi

if [ $stage -le 2 ]; then
    echo "Step 2: Align cleaned data."
    steps/align_fmllr.sh --nj $nj --cmd "$basic_cmd" \
        $cleaned_data $lang $gmmdir $ali_dir
fi

if [ $stage -le 3 ]; then
    echo "Step 3: Train a new GMM with cleaned data using experiment f/tri4j parameters."
    steps/train_sat.sh --cmd "$basic_cmd" --num_iters 70 \
        --realign-iters "10 20 30 40 50 60" --fmllr-iters "2 4 6 12 36 42 48" \
        14000 500000 $cleaned_data $lang $ali_dir $cleaned_dir
fi

if [ "$evaluate_gmm" = true ]; then
    echo "Evaluate GMM."
    utils/mkgraph.sh data/lang_$lm $cleaned_dir $cleaned_dir/graph_$lm

    steps/decode_fmllr.sh --cmd "$basic_cmd" --nj 16 \
        $cleaned_dir/graph_$lm data/parl2016-dev $cleaned_dir/decode_parl2016-dev_$lm
fi
