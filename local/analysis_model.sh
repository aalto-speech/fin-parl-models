#!/usr/bin/env bash

# Copyright 2022 Anja Virkkunen, Aku Rouhe
# Apache 2.0

# Train a 100h model for analysis and decode rest of the data with it

stage=1
analysis_set=parl2008-2020-train

echo "$0 $@"

. path.sh
. parse_options.sh

set -eu

traindir=data/${analysis_set}_40k
transcript_lm=test_${analysis_set}_40k_varikn.bpe1750.d0.0001

if [ $stage -le 1 ]; then
    echo "Make a 100 h subset (40k samples result in approx. 100 hours)."
    utils/subset_data_dir.sh --speakers data/$analysis_set 40000 $traindir
fi

if [ $stage -le 2 ]; then
    echo "Train a transcript LM from the 100 h subset."
    local/train_lm.sh --stage 0 --BPE-units 1750 --varikn-scale 0.0001 \
        --traindata $traindir \ 
    --validdata data/parl2016-dev \
        ${analysis_set}_40k \
        data/lang_$transcript_lm
fi

if [ $stage -le 3 ]; then
    echo "Train TDNN model from the 100 hours of data."
    local/chain/run_chain_common.sh --trainset ${analysis_set}_40k

    local/chain/tuning/run_tdnn_d.sh --trainset ${analysis_set}_40k --lm $transcript_lm
fi

if [ $stage -le 4 ]; then
    echo "From remaining data, select speakers not in the 100 hour subset."

    tmpdir=$(mktemp -d)
    awk '{print $1}' $traindir/spk2utt >$tmpdir/trainset_speakers.list
    awk '{print $1}' data/${analysis_set}/spk2utt >$tmpdir/all_speakers.list
    grep -vf $tmpdir/trainset_speakers.list $tmpdir/all_speakers.list >$tmpdir/non-train_speakers.list

    utils/subset_data_dir.sh --spk-list $tmpdir/non-train_speakers.list \
        data/${analysis_set}_hires \
        data/${analysis_set}_analysis_hires
    rm -r $tmpdir
fi

if [ $stage -le 5 ]; then
    echo "Decode the remaining data with an in-domain transcript LM."
    steps/nnet3/decode.sh --stage 2 --acwt 1.0 --post-decode-acwt 10.0 \
        --nj 8 --cmd "run.pl" \
        exp/${analysis_set}_40k/chain/tdnn_d/graph_$transcript_lm \
        data/${analysis_set}_analysis_hires \
        exp/${analysis_set}_40k/chain/tdnn_d/decode_${analysis_set}_analysis_$transcript_lm
fi
