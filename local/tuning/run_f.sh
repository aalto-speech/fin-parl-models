#!/usr/bin/env bash

# Copyright 2022 Anja Virkkunen, Aku Rouhe
# Apache 2.0

# This script runs the best iteration of the GMM experiments
# where a GMM is trained just like in the Kaldi Librispeech recipe
# but with increased data.

trainset=parl2015-2020-train
stage=1
tri_version=j
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
    [ ! -d ${traindir}_100k ] && utils/subset_data_dir.sh $traindir 100000 ${traindir}_100k
    [ ! -d ${traindir}_250k ] && utils/subset_data_dir.sh $traindir 250000 ${traindir}_250k
    # Manually enforce some rare letters:
    for subset in 2kshort 100k 250k; do
        for letter in c f q w x z å; do
            local/enforce_letter_in_data.sh $traindir "$letter" ${traindir}_${subset}
        done
    done
fi

if [ $stage -le 6 ]; then
    echo "Stage 6: Train monophone system with shortest 2000 utterances."
    steps/train_mono.sh --boost-silence 1.25 --nj 8 --cmd "$basic_cmd" \
        ${traindir}_2kshort data/lang_${trainset} exp/${trainset}/f/mono
fi

if [ $stage -le 7 ]; then
    echo "Stage 7: Evaluate monophone system."
    utils/mkgraph.sh $lmdir exp/${trainset}/f/mono \
        exp/${trainset}/f/mono/graph_${lm_name}

    steps/decode.sh --cmd "$basic_cmd" --nj 8 \
        exp/${trainset}/f/mono/graph_${lm_name} data/parl2016-dev \
        exp/${trainset}/f/mono/decode_parl2016-dev_${lm_name}
fi

if [ $stage -le 8 ]; then
    echo "Stage 8: Train first triphone system with 100k utterances."
    steps/align_si.sh --boost-silence 1.25 --nj 8 --cmd "$basic_cmd" \
        ${traindir}_100k data/lang_${trainset} \
        exp/${trainset}/f/mono exp/${trainset}/f/mono_ali_100k

    steps/train_deltas.sh --boost-silence 1.25 --cmd "$basic_cmd" \
        2000 10000 ${traindir}_100k data/lang_${trainset} \
        exp/${trainset}/f/mono_ali_100k exp/${trainset}/f/tri1a
fi

if [ $stage -le 9 ]; then
    echo "Stage 9: Evaluate 100k triphone system."
    utils/mkgraph.sh $lmdir exp/${trainset}/f/tri1a \
        exp/${trainset}/f/tri1a/graph_${lm_name}

    steps/decode.sh --cmd "$basic_cmd" --nj 8 \
        exp/${trainset}/f/tri1a/graph_${lm_name} data/parl2016-dev \
        exp/${trainset}/f/tri1a/decode_parl2016-dev_${lm_name}
fi

if [ $stage -le 10 ]; then
    echo "Stage 10: Train second triphone system with 250k utterances."
    steps/align_si.sh --nj 8 --cmd "$basic_cmd" ${traindir}_250k \
        data/lang_${trainset} exp/${trainset}/f/tri1a \
        exp/${trainset}/f/tri1a_ali_250k

    steps/train_lda_mllt.sh --cmd "$basic_cmd" \
        --splice-opts "--left-context=3 --right-context=3" \
        4000 45000 ${traindir}_250k data/lang_${trainset} \
        exp/${trainset}/f/tri1a_ali_250k exp/${trainset}/f/tri2a
fi

if [ $stage -le 11 ]; then
    echo "Stage 11: Evaluate second triphone system."
    utils/mkgraph.sh $lmdir exp/${trainset}/f/tri2a \
        exp/${trainset}/f/tri2a/graph_${lm_name}

    steps/decode.sh --cmd "$basic_cmd" --nj 8 \
        exp/${trainset}/f/tri2a/graph_${lm_name} data/parl2016-dev \
        exp/${trainset}/f/tri2a/decode_parl2016-dev_${lm_name}
fi

if [ $stage -le 12 ]; then
    echo "Stage 12: Train third triphone system with 250k utts and LDA+MLLT+SAT."
    steps/align_si.sh --nj 8 --cmd "$basic_cmd" --use-graphs true \
        ${traindir}_250k data/lang_${trainset} \
        exp/${trainset}/f/tri2a exp/${trainset}/f/tri2a_ali_250k

    steps/train_sat.sh --cmd "$basic_cmd" \
        4000 45000 ${traindir}_250k data/lang_${trainset} \
        exp/${trainset}/f/tri2a_ali_250k exp/${trainset}/f/tri3a
fi

if [ $stage -le 13 ]; then
    echo "Stage 13: Evaluate third triphone system."
    utils/mkgraph.sh $lmdir exp/${trainset}/f/tri3a \
        exp/${trainset}/f/tri3a/graph_${lm_name}

    steps/decode_fmllr.sh --cmd "$basic_cmd" --nj 8 \
        exp/${trainset}/f/tri3a/graph_${lm_name} data/parl2016-dev \
        exp/${trainset}/f/tri3a/decode_parl2016-dev_${lm_name}
fi

if [ $stage -le 14 ]; then
    num_leaves=7000
    num_gauss=150000
    num_iters=35
    realign_iters="10 20 30"
    fmllr_iters="2 4 6 12"
    if [ $tri_version == b ]; then
        num_leaves=14000
        num_gauss=200000
    fi
    if [ $tri_version == c ]; then
        num_leaves=14000
        num_gauss=200000
        num_iters=70
        realign_iters="10 20 30 40 50 60"
        fmllr_iters="2 4 6 12 36 42 48"
    fi
    if [ $tri_version == d ]; then
        num_leaves=21000
        num_gauss=200000
        num_iters=70
        realign_iters="10 20 30 40 50 60"
        fmllr_iters="2 4 6 12 36 42 48"
    fi
    if [ $tri_version == e ]; then
        num_leaves=21000
        num_gauss=250000
        num_iters=70
        realign_iters="10 20 30 40 50 60"
        fmllr_iters="2 4 6 12 36 42 48"
    fi
    if [ $tri_version == f ]; then
        num_leaves=28000
        num_gauss=200000
        num_iters=70
        realign_iters="10 20 30 40 50 60"
        fmllr_iters="2 4 6 12 36 42 48"
    fi
    if [ $tri_version == g ]; then
        num_leaves=14000
        num_gauss=250000
        num_iters=70
        realign_iters="10 20 30 40 50 60"
        fmllr_iters="2 4 6 12 36 42 48"
    fi
    if [ $tri_version == h ]; then
        num_leaves=14000
        num_gauss=300000
        num_iters=70
        realign_iters="10 20 30 40 50 60"
        fmllr_iters="2 4 6 12 36 42 48"
    fi
    if [ $tri_version == i ]; then
        num_leaves=14000
        num_gauss=400000
        num_iters=70
        realign_iters="10 20 30 40 50 60"
        fmllr_iters="2 4 6 12 36 42 48"
    fi
    if [ $tri_version == j ]; then
        num_leaves=14000
        num_gauss=500000
        num_iters=70
        realign_iters="10 20 30 40 50 60"
        fmllr_iters="2 4 6 12 36 42 48"
    fi
    if [ $tri_version == k ]; then
        num_leaves=14000
        num_gauss=600000
        num_iters=70
        realign_iters="10 20 30 40 50 60"
        fmllr_iters="2 4 6 12 36 42 48"
    fi

    echo "Stage 14: Train fourth triphone system with full data (also LDA+MLLT+SAT)."
    echo "Using configuration tri4$tri_version with $num_leaves leaves,"
    echo "$num_gauss gaussians, $num_iters iterations, $realign_iters realign iterations,"
    echo "and $fmllr_iters fmllr iterations."

    if [ ! -d exp/${trainset}/f/tri3a_ali_full ]; then
        steps/align_fmllr.sh --nj 8 --cmd "$basic_cmd" \
            $traindir data/lang_${trainset} \
            exp/${trainset}/f/tri3a exp/${trainset}/f/tri3a_ali_full
    fi

    steps/train_sat.sh --cmd "$basic_cmd" --num-iters $num_iters \
        --realign-iters "$realign_iters" --fmllr-iters "$fmllr_iters" \
        $num_leaves $num_gauss $traindir data/lang_${trainset} \
        exp/${trainset}/f/tri3a_ali_full exp/${trainset}/f/tri4$tri_version
fi

if [ $stage -le 15 ]; then
    echo "Stage 15: Evaluate fourth triphone system."
    utils/mkgraph.sh $lmdir exp/${trainset}/f/tri4$tri_version \
        exp/${trainset}/f/tri4$tri_version/graph_${lm_name}

    steps/decode_fmllr.sh --cmd "$basic_cmd" --nj 8 \
        exp/${trainset}/f/tri4$tri_version/graph_${lm_name} data/parl2016-dev \
        exp/${trainset}/f/tri4$tri_version/decode_parl2016-dev_${lm_name}
fi
