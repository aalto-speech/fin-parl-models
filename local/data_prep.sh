#!/bin/bash

# Copyright 2022 Anja Virkkunen, Aku Rouhe
# Apache 2.0

# Prepare kaldi data files for the Finnish parliament ASR corpus.
# Corpus is downloaded with 'local/data_download.sh' script.

stage=1

echo "$0 $@" # Print the command line for logging

. utils/parse_options.sh

set -eu
export LC_ALL=C

if [ $stage -le 1 ]; then
    echo "Preparing kaldi files for different data sets. This will take a while."

    for set in 2008-2016-train 2015-2020-train 2016-dev 2016-test 2020-test; do
        echo "Preparing data for set $set."
        dir=data/parl$set
        mkdir -p $dir

        if [[ $set == *-dev || $set == *-test ]]; then
            raw_data_dir=data/fi-parliament-asr/dev-eval/$set
        else
            raw_data_dir=data/fi-parliament-asr/${set/-train/set}
        fi

        echo "Creating $dir/text."
        find -L $raw_data_dir -iname "*.trn" -type f -print0 |
            xargs -0 sh -c 'for arg do echo -n "$arg "; cat $arg; done' _ >$dir/text || exit 1

        echo "Creating $dir/wav.scp."
        find -L $raw_data_dir -iname "*.wav" -type f -print0 |
            xargs -0 sh -c 'for arg do echo "$arg $PWD/$arg"; done' _ >$dir/wav.scp || exit 1

        if [[ $set == 2008-2016-train ]]; then
            echo "Filtering duplicates in 2008-2016 set."
            grep -Fvf $raw_data_dir/dropped_duplicates.list $dir/wav.scp | sponge $dir/wav.scp

            sed 's/\.wav//' $raw_data_dir/dropped_duplicates.list |
                grep -Fvf - $dir/text | sponge $dir/text
        fi

        sed 's/.*\/\(.*\)\.trn /\1 /' $dir/text | awk '{ gsub("_","-",$1); print $0 }' |
            sort | sponge $dir/text

        sed 's/.*\/\(.*\)\.wav /\1 /' $dir/wav.scp | awk '{ gsub("_","-",$1); print $0 }' |
            sort | sponge $dir/wav.scp

        echo "Creating $dir/utt2spk and $dir/spk2utt."
        if [[ $set == *2016* ]]; then
            awk '{ print $1 }' $dir/text |
                awk -F- '{ printf $0" ";
                            for(i=1;i<=NF-1;i++) printf("%s%s", $i, (i==NF-1) ? "\n" : "-")
                        }' >$dir/utt2spk
        else
            awk '{ print $1 }' $dir/text | awk -F- '{ print $0" "$1 }' >$dir/utt2spk
        fi
        cat $dir/utt2spk | utils/utt2spk_to_spk2utt.pl >$dir/spk2utt
    done
fi

if [ $stage -le 2 ]; then
    echo "Preparing data for combined 2008-2020 train set."
    utts2008_2014=2008-2014-utt.list
    subset_dir=data/parl2008-2014-train
    dir=data/parl2008-2020-train

    sed 's/^.*\///' data/fi-parliament-asr/2008-2016set/2008-2014-samples.list |
        sed 's/\.wav//' |
        sed 's/_/-/g' >$utts2008_2014

    mkdir -p $dir
    sort -u $utts2008_2014 |
        utils/subset_data_dir.sh --utt-list - data/parl2008-2016-train $subset_dir
    utils/combine_data.sh $dir $subset_dir data/parl2015-2020-train

    # Clean up
    rm -r $utts2008_2014 $subset_dir
fi
