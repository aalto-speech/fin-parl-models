#!/usr/bin/env bash

# This script runs the first iteration of the experiments
# where a GMM is trained just like in the Kaldi Librispeech recipe.
# (with added decoding steps)

trainset=parl2015-2020-train
stage=5 # Assume that run.sh has been run before so the first four stages are done already
tri_version=a
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
    [ ! -d ${traindir}_5k ] && utils/subset_data_dir.sh $traindir 100000 ${traindir}_5k
    [ ! -d ${traindir}_10k ] && utils/subset_data_dir.sh $traindir 250000 ${traindir}_10k
    # Manually enforce some rare letters:
    for subset in 2kshort 5k 10k; do
        for letter in c f q w x z å; do
            local/enforce_letter_in_data.sh $traindir "$letter" ${traindir}_${subset}
        done
    done
fi

if [ $stage -le 6 ]; then
    echo "Stage 6: Train monophone system with shortest 2000 utterances."
    steps/train_mono.sh --boost-silence 1.25 --nj 8 --cmd "$basic_cmd" \
        ${traindir}_2kshort data/lang_${trainset} exp/${trainset}/g/mono
fi

if [ $stage -le 7 ]; then
    echo "Stage 7: Evaluate monophone system."
    utils/mkgraph.sh $lmdir exp/${trainset}/g/mono \
        exp/${trainset}/g/mono/graph_${lm_name}

    steps/decode.sh --cmd "$basic_cmd" --nj 8 \
        exp/${trainset}/g/mono/graph_${lm_name} data/parl2016-dev \
        exp/${trainset}/g/mono/decode_parl2016-dev_${lm_name}
fi

if [ $stage -le 8 ]; then
    echo "Stage 8: Train first triphone system with 5k utterances."
    steps/align_si.sh --boost-silence 1.25 --nj 8 --cmd "$basic_cmd" \
        ${traindir}_5k data/lang_${trainset} \
        exp/${trainset}/g/mono exp/${trainset}/g/mono_ali_5k

    steps/train_deltas.sh --boost-silence 1.25 --cmd "$basic_cmd" \
        2000 10000 ${traindir}_5k data/lang_${trainset} \
        exp/${trainset}/g/mono_ali_5k exp/${trainset}/g/tri1a
fi

if [ $stage -le 9 ]; then
    echo "Stage 9: Evaluate 5k triphone system."
    utils/mkgraph.sh $lmdir exp/${trainset}/g/tri1a \
        exp/${trainset}/g/tri1a/graph_${lm_name}

    steps/decode.sh --cmd "$basic_cmd" --nj 8 \
        exp/${trainset}/g/tri1a/graph_${lm_name} data/parl2016-dev \
        exp/${trainset}/g/tri1a/decode_parl2016-dev_${lm_name}
fi

if [ $stage -le 10 ]; then
    echo "Stage 10: Train second triphone system with 10k utterances."
    steps/align_si.sh --nj 8 --cmd "$basic_cmd" ${traindir}_10k \
        data/lang_${trainset} exp/${trainset}/g/tri1a \
        exp/${trainset}/g/tri1a_ali_10k

    steps/train_lda_mllt.sh --cmd "$basic_cmd" \
        --splice-opts "--left-context=3 --right-context=3" \
        4000 45000 ${traindir}_10k data/lang_${trainset} \
        exp/${trainset}/g/tri1a_ali_10k exp/${trainset}/g/tri2a
fi

if [ $stage -le 11 ]; then
    echo "Stage 11: Evaluate second triphone system."
    utils/mkgraph.sh $lmdir exp/${trainset}/g/tri2a \
        exp/${trainset}/g/tri2a/graph_${lm_name}

    steps/decode.sh --cmd "$basic_cmd" --nj 8 \
        exp/${trainset}/g/tri2a/graph_${lm_name} data/parl2016-dev \
        exp/${trainset}/g/tri2a/decode_parl2016-dev_${lm_name}
fi

if [ $stage -le 12 ]; then
    echo "Stage 12: Train third triphone system with 10k utts and LDA+MLLT+SAT."
    steps/align_si.sh --nj 8 --cmd "$basic_cmd" --use-graphs true \
        ${traindir}_10k data/lang_${trainset} \
        exp/${trainset}/g/tri2a exp/${trainset}/g/tri2a_ali_10k

    steps/train_sat.sh --cmd "$basic_cmd" \
        4000 45000 ${traindir}_10k data/lang_${trainset} \
        exp/${trainset}/g/tri2a_ali_10k exp/${trainset}/g/tri3a
fi

if [ $stage -le 13 ]; then
    echo "Stage 13: Evaluate third triphone system."
    utils/mkgraph.sh $lmdir exp/${trainset}/g/tri3a \
        exp/${trainset}/g/tri3a/graph_${lm_name}

    steps/decode_fmllr.sh --cmd "$basic_cmd" --nj 8 \
        exp/${trainset}/g/tri3a/graph_${lm_name} data/parl2016-dev \
        exp/${trainset}/g/tri3a/decode_parl2016-dev_${lm_name}
fi

if [ $stage -le 14 ]; then
    num_leaves=7000
    num_gauss=150000
    num_iters=35
    realign_iters="10 20 30"
    fmllr_iters="2 4 6 12"
    if [ $tri_version == b ]; then
        num_leaves=14000
        num_gauss=150000
    fi
    if [ $tri_version == c ]; then
        num_leaves=14000
        num_gauss=200000
    fi
    if [ $tri_version == d ]; then
        num_iters=70
        realign_iters="10 20 30 40 50 60"
        fmllr_iters="2 4 6 12 36 42 48"
    fi
    if [ $tri_version == e ]; then
        num_leaves=14000
        num_gauss=200000
        num_iters=70
        realign_iters="10 20 30 40 50 60"
        fmllr_iters="2 4 6 12 36 42 48"
    fi

    echo "Stage 14: Train fourth triphone system with full data (also LDA+MLLT+SAT)."
    echo "Using configuration tri4$tri_version with $num_leaves leaves,"
    echo "$num_gauss gaussians, $num_iters iterations, $realign_iters realign iterations,"
    echo "and $fmllr_iters fmllr iterations."

    if [ ! -d exp/${trainset}/g/tri3a_ali_full ]; then
        steps/align_fmllr.sh --nj 8 --cmd "$basic_cmd" \
            $traindir data/lang_${trainset} \
            exp/${trainset}/g/tri3a exp/${trainset}/g/tri3a_ali_full
    fi

    steps/train_sat.sh --cmd "$basic_cmd" --num-iters $num_iters \
        --realign-iters "$realign_iters" --fmllr-iters "$fmllr_iters" \
        $num_leaves $num_gauss $traindir data/lang_${trainset} \
        exp/${trainset}/g/tri3a_ali_full exp/${trainset}/g/tri4$tri_version
fi

if [ $stage -le 15 ]; then
    echo "Stage 15: Evaluate fourth triphone system."
    utils/mkgraph.sh $lmdir exp/${trainset}/g/tri4$tri_version \
        exp/${trainset}/g/tri4$tri_version/graph_${lm_name}

    steps/decode_fmllr.sh --cmd "$basic_cmd" --nj 8 \
        exp/${trainset}/g/tri4$tri_version/graph_${lm_name} data/parl2016-dev \
        exp/${trainset}/g/tri4$tri_version/decode_parl2016-dev_${lm_name}
fi
