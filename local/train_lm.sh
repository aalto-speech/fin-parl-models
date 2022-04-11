#!/usr/bin/env bash

# Copyright 2022 Anja Virkkunen, Aku Rouhe
# Apache 2.0

# Train an n-gram language model with VariKN using BPE subwords.

stage=1
BPE_units=1750
varikn_scale=0.0001
varikn_cmd="$varikn_cmd"
varikn_extra="--clear_history --3nzer --arpa"
skip_lang=false
traindata=
validdata=

echo $0 $@

. ./cmd.sh
. ./path.sh
. parse_options.sh

set -eu

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <lm-data> <outdir>"
    echo "e.g.: $0 --BPE-units 1000 train data/lang_bpe.1000.varikn"
    echo "If you don't have LM data dir with files plain_text and plain_text.valid,"
    echo "you can specify:"
    echo "    --stage 0 --traindata <traindata> --validdata <validdata>"
    echo "to use Kaldi datadirs' text files for lm data prep."
    exit 1
fi

lmdata="$1"
outdir="$2"

lmdatadir="data/lm_$lmdata"
lmdir="exp/lm/${lmdata}_varikn.bpe${BPE_units}.d${varikn_scale}"

if [ "$stage" -le 0 ]; then
    echo "LM training data prep from Kaldi style data dirs"
    mkdir -p "$lmdatadir"
    # Need to remove first column from the text, as that is the Kaldi uttid
    local/preprocess_lm_data.py <(cut -f2- -d" " "$traindata"/text) >"$lmdatadir"/plain_text
    echo "LM dev data"
    local/preprocess_lm_data.py <(cut -f2- -d" " "$validdata"/text) >"$lmdatadir"/plain_text.valid
fi

if [ "$stage" -le 1 ]; then
    echo "Training SentencePiece BPE: $BPE_units"
    mkdir -p "$lmdir"
    $train_cmd "$lmdir"/log/spm_train_"$BPE_units".log \
        spm_train --input="$lmdatadir"/plain_text \
        --model_prefix="$lmdir"/bpe.$BPE_units \
        --vocab_size="$BPE_units" \
        --character_coverage=1.0 \
        --model_type="bpe"

    # Vocab to plain vocab ( normal SPM format is <subword> <id> )
    cut -f1 "$lmdir"/bpe.$BPE_units.vocab >"$lmdir"/bpe.$BPE_units.vocab.plain

    $train_cmd "$lmdatadir"/log/spm_encode_"$BPE_units".log \
        spm_encode --model="$lmdir"/bpe."$BPE_units".model \
        --output_format=piece \< "$lmdatadir"/plain_text \> "$lmdatadir"/text.bpe.$BPE_units
    $basic_cmd "$lmdatadir"/log/spm_encode_"$BPE_units"_valid.log \
        spm_encode --model="$lmdir"/bpe."$BPE_units".model \
        --output_format=piece \< "$lmdatadir"/plain_text.valid \> "$lmdatadir"/valid.bpe.$BPE_units
fi

if [ "$stage" -le 2 ]; then
    local/train_varikn.sh \
        --cmd "$varikn_cmd" \
        --scale "$varikn_scale" \
        --extra-args "$varikn_extra" \
        "cat $lmdatadir/text.bpe.$BPE_units" \
        "cat $lmdatadir/valid.bpe.$BPE_units" \
        "$lmdir"
fi

if [ "$stage" -le 3 ]; then
    echo "Compute perplexity"
    perplexity --arpa "$lmdir"/varikn.lm.gz \
        "$lmdatadir"/valid.bpe."$BPE_units" \
        "$lmdir"/valid_perplexity
fi

if [ "$skip_lang" = true ]; then
    echo "Skipping lang dir creation."
    exit 0
fi

dict_dir="data/local/dict_${lmdata}_bpe.$BPE_units"
phone_table="data/lang_${lmdata}/phones.txt"
if [ "$stage" -le 4 ]; then
    echo "Make SentencePiece LM."
    local/make_spm_lang.sh --phone-table $phone_table \
        "$lmdir"/bpe.${BPE_units}.vocab.plain $dict_dir $outdir
fi

if [ "$stage" -le 5 ]; then
    echo "Convert ARPA to FST."
    utils/format_lm.sh $outdir "$lmdir"/varikn.lm.gz \
        $dict_dir/lexicon.txt $outdir
fi
