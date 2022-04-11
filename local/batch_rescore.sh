#!/usr/bin/env bash

# Copyright 2022 Anja Virkkunen, Aku Rouhe
# Apache 2.0

# Rescore decoding results.

for decoded_data in parl2016-dev parl2016-test parl2020-test; do
    for am_train_data in parl2015-2020-train parl2008-2016-train parl2008-2020-train; do
        am=exp/${am_train_data}/chain/tdnn_d
        steps/lmrescore_const_arpa.sh data/lang_test_5gram-kielipankki.bpe19000.d0.0001 \
            data/lang_test_kielipankki.bpe19000.d0.0001_carpa \
            data/${decoded_data}_hires \
            ${am}/decode_${decoded_data}_test_5gram-kielipankki.bpe19000.d0.0001 \
            ${am}/decode_${decoded_data}_test_kielipankki.bpe19000.d0.0001_rescore
    done
done
