#!/usr/bin/env bash

# Copyright 2022 Anja Virkkunen, Aku Rouhe
# Apache 2.0

# This script trains the other in-domain LMs used for evaluation.
# Expects that run.sh has been executed at least once up to stage 3
# to get the validation data for LMs.

stage=1
lm_valid_data=data/lm_parl2015-2020-train/plain_text.valid

echo "$0 $@"

. ./cmd.sh
. ./path.sh
. parse_options.sh

set -eu

[ ! -f $lm_valid_data ] && echo "$0: LM validation data at $lm_valid_data does not exist" && exit 1

if [ $stage -le 1 ]; then
    echo "Stage 1: Prepare in-domain language model from 2008-2016 full 20M token session transcript data."
    mkdir -p data/lm_parl_20M

    sed -e 's:^<s> ::' -e 's: </s>::' data/fi-parliament-asr/2008-2016set/parl-transcripts.train |
        local/preprocess_lm_data.py - >data/lm_parl_20M/plain_text
    # Get existing validation data
    cp $lm_valid_data data/lm_parl_20M

    local/train_lm.sh --phone-table data/lang_parl2015-2020-train/phones.txt \
        --BPE-units 19000 --varikn-scale 0.0001 \
        parl_20M data/lang_test_parl_20M_varikn.bpe19000.d0.0001
fi

if [ $stage -le 2 ]; then
    echo "Stage 2: Prepare in-domain language model from 2008-2020 full 30M token session transcript data."
    mkdir -p data/lm_parl_30M

    cat data/fi-parliament-asr/2008-2016set/parl-transcripts.train \
        data/fi-parliament-asr/2015-2020set/parl-full-transcripts-78-2016-104-2020.train |
        sed -e 's:^<s> ::' -e 's: </s>::' |
        local/preprocess_lm_data.py - >data/lm_parl_30M/plain_text
    # Get existing validation data
    cp $lm_valid_data data/lm_parl_30M

    local/train_lm.sh --phone-table data/lang_parl2015-2020-train/phones.txt \
        --BPE-units 19000 --varikn-scale 0.0001 \
        parl_30M data/lang_test_parl_30M_varikn.bpe19000.d0.0001
fi
