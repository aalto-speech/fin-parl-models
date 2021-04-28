#!/bin/bash

release_traindir=/scratch/elec/puhe/c/eduskunta_new/datasets/kaldi-format/2015-2020-kevat
stage=1


. ./cmd.sh
. ./path.sh
. parse_options.sh

set -e -u

if [ $stage -le 1 ]; then
  # Prep the data locally
  mkdir -p data
  # Copy the datadir from the release directory.
  utils/copy_data_dir.sh $release_traindir data/train
fi

if [ $stage -le 2 ]; then
	# Prep lexicon
	local/prepare_lexicon.sh data/train data/lang_train
fi

if [ $stage -le 3 ]; then
  # Features
  steps/make_mfcc.sh --cmd "$basic_cmd" --nj 32 data/train
  steps/compute_cmvn_stats.sh data/train
fi

if [ $stage -le 4 ]; then
  # Subsets
  utils/subset_data_dir.sh --shortest data/train 2000 data/train_2kshort
  # Manually enforce the letter "q" gets included:
  local/enforce_letter_in_data.sh data/train "c" data/train_2kshort
  local/enforce_letter_in_data.sh data/train "q" data/train_2kshort
  local/enforce_letter_in_data.sh data/train "z" data/train_2kshort
  utils/subset_data_dir.sh data/train 5000 data/train_5k
  local/enforce_letter_in_data.sh data/train "c" data/train_5k
  local/enforce_letter_in_data.sh data/train "q" data/train_5k
  local/enforce_letter_in_data.sh data/train "z" data/train_5k
  #utils/subset_data_dir.sh data/train 10000 data/train_10k
fi

if [ $stage -le 5 ]; then
  # train a monophone system
  steps/train_mono.sh --boost-silence 1.25 --nj 20 --cmd "$basic_cmd" \
                      data/train_2kshort data/lang_train exp/mono
fi

if [ $stage -le 6 ]; then
  steps/align_si.sh --boost-silence 1.25 --nj 10 --cmd "$basic_cmd" \
                    data/train_5k data/lang_train exp/mono exp/mono_ali_5k

  # train a first delta + delta-delta triphone system on a subset of 5000 utterances
  steps/train_deltas.sh --boost-silence 1.25 --cmd "$basic_cmd" \
                        2000 10000 data/train_5k data/lang_train exp/mono_ali_5k exp/tri1
fi
