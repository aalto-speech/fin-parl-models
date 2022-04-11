#!/usr/bin/env bash

# Copyright 2022 Anja Virkkunen, Aku Rouhe
# Apache 2.0

# Prepare Kielipankki text corpus for LM training.

set -euo pipefail

kielipankki_root="data/kielipankki"

. path.sh
. parse_options.sh

lmdatadir=data/lm_kielipankki
mkdir -p $lmdatadir

local/preprocess_lm_data.py \
    <(gunzip -c "$kielipankki_root"/traindata.txt.gz | sed "/FILE:/d" | iconv -f LATIN1 -t UTF-8) \
    >"$lmdatadir"/plain_text

local/preprocess_lm_data.py \
    <(gunzip -c "$kielipankki_root"/develdata.hame0008.txt.gz "$kielipankki_root"/develdata.otava_anhava.txt.gz | sed "/FILE:/d" | iconv -f LATIN1 -t UTF-8) \
    >"$lmdatadir"/plain_text.valid
