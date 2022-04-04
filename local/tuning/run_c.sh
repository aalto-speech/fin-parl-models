#!/bin/bash

# This script runs the third iteration of the experiments
# where we train
# one monophone with 2k_short,
# one triphone with 250k and
# one triphone with all the data

trainset=parl2015-2020-train
stage=5 # Assume that run.sh has been run before so the first four stages are done already
lm_BPE=1750
lm_scale=0.0001
# Use the run_cleanup.sh script to clean data
use_cleaned=false

. ./cmd.sh
. ./path.sh
. parse_options.sh

set -eu

$use_cleaned && trainset=${trainset}_cleaned
traindir=data/${trainset}
lm_name="test_${trainset}_varikn.bpe${lm_BPE}.d${lm_scale}"
lmdir="data/lang_${lm_name}"

if [[ $stage -le 1 && ! -d $traindir ]]; then
    echo "Stage 1: Preparing all data."
    if [[ $use_cleaned == false ]]; then
        local/data_download.sh
        local/data_prep.sh
    else
        echo "Cleaned data dir $traindir does not exist." &&
            echo "Create cleaned data with local/run_cleanup.sh script." &&
            exit 1
    fi
fi

if [ $stage -le 2 ]; then
    echo "Stage 2: Prepare lexicon."
    local/prepare_lexicon.sh $traindir data/local/dict_${trainset} data/lang_${trainset}
fi

if [ $stage -le 3 ]; then
    echo "Stage 3: Prepare language model."
    local/train_lm.sh --stage 0 --BPE-units $lm_BPE --varikn-scale $lm_scale \
        --traindata $traindir --validdata data/parl2016-dev \
        $trainset $lmdir
fi

if [ $stage -le 4 ]; then
    echo "Stage 4: Compute features."
    steps/make_mfcc.sh --cmd "$basic_cmd" --nj 8 $traindir
    steps/compute_cmvn_stats.sh $traindir
    steps/make_mfcc.sh --cmd "$basic_cmd" --nj 8 data/parl2016-dev
    steps/compute_cmvn_stats.sh data/parl2016-dev
    steps/make_mfcc.sh --cmd "$basic_cmd" --nj 8 data/parl2016-test
    steps/compute_cmvn_stats.sh data/parl2016-test
    steps/make_mfcc.sh --cmd "$basic_cmd" --nj 8 data/parl2020-test
    steps/compute_cmvn_stats.sh data/parl2020-test
fi

if [ $stage -le 5 ]; then
    echo "Stage 5: Make subsets."
    [ ! -d ${traindir}_2kshort ] &&
        utils/subset_data_dir.sh --shortest $traindir 2000 ${traindir}_2kshort
    [ ! -d ${traindir}_250k ] && utils/subset_data_dir.sh $traindir 250000 ${traindir}_250k
    # Manually enforce some rare letters:
    for subset in 2kshort 250k; do
        for letter in c f q w x z å; do
            local/enforce_letter_in_data.sh $traindir "$letter" ${traindir}_${subset}
        done
    done
fi

if [ $stage -le 6 ]; then
    echo "Stage 6: Train monophone system with shortest 2000 utterances."
    steps/train_mono.sh --boost-silence 1.25 --nj 8 --cmd "$basic_cmd" \
        ${traindir}_2kshort data/lang_${trainset} exp/${trainset}/c/mono
fi

if [ $stage -le 7 ]; then
    echo "Stage 7: Evaluate monophone system."
    utils/mkgraph.sh $lmdir exp/${trainset}/c/mono \
        exp/${trainset}/c/mono/graph_${lm_name}

    steps/decode.sh --cmd "$basic_cmd" --nj 8 \
        exp/${trainset}/c/mono/graph_${lm_name} data/parl2016-dev \
        exp/${trainset}/c/mono/decode_parl2016-dev_${lm_name}
fi

if [ $stage -le 8 ]; then
    echo "Stage 8: Train first triphone system with 250k utterances."
    steps/align_si.sh --nj 8 --cmd "$basic_cmd" ${traindir}_250k \
        data/lang_${trainset} exp/${trainset}/c/mono \
        exp/${trainset}/c/mono_ali_250k

    steps/train_lda_mllt.sh --cmd "$basic_cmd" \
        --splice-opts "--left-context=3 --right-context=3" \
        2500 15000 ${traindir}_250k data/lang_${trainset} \
        exp/${trainset}/c/mono_ali_250k exp/${trainset}/c/tri1a
fi

if [ $stage -le 9 ]; then
    echo "Stage 9: Evaluate first triphone system."
    utils/mkgraph.sh $lmdir exp/${trainset}/c/tri1a \
        exp/${trainset}/c/tri1a/graph_${lm_name}

    steps/decode.sh --cmd "$basic_cmd" --nj 8 \
        exp/${trainset}/c/tri1a/graph_${lm_name} data/parl2016-dev \
        exp/${trainset}/c/tri1a/decode_parl2016-dev_${lm_name}
fi

if [ $stage -le 10 ]; then
    echo "Stage 10: Train second triphone system with LDA+MLLT+SAT."
    steps/align_si.sh --nj 8 --cmd "$basic_cmd" --use-graphs true \
        ${traindir} data/lang_${trainset} \
        exp/${trainset}/c/tri1a exp/${trainset}/c/tri1a_ali

    steps/train_sat.sh --cmd "$basic_cmd" \
        7000 150000 ${traindir} data/lang_${trainset} \
        exp/${trainset}/c/tri1a_ali exp/${trainset}/c/tri2a
fi

if [ $stage -le 11 ]; then
    echo "Stage 11: Evaluate second triphone system."
    utils/mkgraph.sh $lmdir exp/${trainset}/c/tri2a \
        exp/${trainset}/c/tri2a/graph_${lm_name}

    steps/decode_fmllr.sh --cmd "$basic_cmd" --nj 8 \
        exp/${trainset}/c/tri2a/graph_${lm_name} data/parl2016-dev \
        exp/${trainset}/c/tri2a/decode_parl2016-dev_${lm_name}
fi
