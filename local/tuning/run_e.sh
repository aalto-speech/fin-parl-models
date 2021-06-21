#!/bin/bash

# This script runs the third iteration of the experiments
# where we train 
# one monophone with 2k_short,
# one triphone with 250k and 
# one triphone with all the data
# 
# This is to see whether the additional triphone modeling
# steps are necessary.

release_traindir=raw_data/2015-2020-kevat
stage=5 # Assume that run_a.sh has been run before so first four stages are done already

. ./cmd.sh
. ./path.sh
. parse_options.sh

set -e -u

if [ $stage -le 1 ]; then
	echo "Stage 1: Get datadirs."
  # Prep the data locally
  mkdir -p data
  # Copy the datadir from the release directory.
  utils/copy_data_dir.sh $release_traindir data/train
	# TODO: get DEV and TEST sets from somewhere
fi

if [ $stage -le 2 ]; then
	echo "Stage 2: Prepare lexicon."
	# Prep lexicon
	local/prepare_lexicon.sh data/train data/local/dict_train data/lang_train
fi

if [ $stage -le 3 ]; then
	echo "Stage 3: Prepare language model."
	# Prepare language model
	local/train_lm.sh --stage 0 --BPE-units 1000 \
										--varikn-opts "--scale 0.05 --prune-scale 0.5" \
										--traindata data/train --validdata data/parl-dev-all \
										data/lm_data exp/varikn.bpe1000.small data/lang_test_small
fi


if [ $stage -le 4 ]; then
	echo "Stage 4: Compute features."
  # Features
  steps/make_mfcc.sh --cmd "$basic_cmd" --nj 32 data/train
  steps/compute_cmvn_stats.sh data/train
	# TODO: what are the dev and test sets called
	#steps/make_mfcc.sh --cmd "$basic_cmd" --nj 8 data/parl-dev-seen
  #steps/compute_cmvn_stats.sh data/parl-dev-seen
	#steps/make_mfcc.sh --cmd "$basic_cmd" --nj 8 data/parl-dev-unseen
  #steps/compute_cmvn_stats.sh data/parl-dev-unseen
fi

if [ $stage -le 5 ]; then
	echo "Stage 5: Make subsets."
  # Subsets
  utils/subset_data_dir.sh --shortest data/train 2000 data/train_2kshort
  utils/subset_data_dir.sh data/train 250000 data/train_250k
  # Manually enforce some rare letters:
	for subset in 2kshort 250k; do
		for letter in c f q w x z å; do 
			local/enforce_letter_in_data.sh data/train "$letter" data/train_$subset
		done
	done
fi

if [ $stage -le 6 ]; then
	echo "Stage 6: Train monophone system."
  # train a monophone system
  steps/train_mono.sh --boost-silence 1.25 --nj 20 --cmd "$basic_cmd" \
                      data/train_2kshort data/lang_train exp/e/mono
fi

if [ $stage -le 7 ]; then
	echo "Stage 7: Evaluate monophone system."
	utils/mkgraph.sh data/lang_test_small exp/e/mono exp/e/mono/graph_test_small

	# Decode with triphone model
	steps/decode.sh --cmd "$basic_cmd" --nj 16 \
									exp/e/mono/graph_test_small data/parl-dev-all \
									exp/e/mono/decode_parl-dev-all_test_small
fi

if [ $stage -le 10 ]; then
	echo "Stage 10: Train first triphone system."
	steps/align_si.sh --nj 40 --cmd "$basic_cmd" data/train_250k data/lang_train exp/e/mono exp/e/mono_ali_250k

	# train an LDA+MLLT system
	steps/train_lda_mllt.sh --cmd "$basic_cmd" --splice-opts "--left-context=3 --right-context=3" 4000 45000 \
													data/train_250k data/lang_train exp/e/mono_ali_250k exp/e/tri1a
fi

if [ $stage -le 11 ]; then
	echo "Stage 11: Evaluate first triphone system."
	utils/mkgraph.sh data/lang_test_small exp/e/tri1a exp/e/tri1a/graph_test_small

	# Decode with triphone model
	steps/decode.sh --cmd "$basic_cmd" --nj 16 \
									exp/e/tri1a/graph_test_small data/parl-dev-all \
									exp/e/tri1a/decode_parl-dev-all_test_small
fi

if [ $stage -le 12 ]; then
	echo "Stage 12: Train second triphone system with 250k utts and LDA+MLLT+SAT."
	steps/align_si.sh --nj 40 --cmd "$basic_cmd" --use-graphs true \
										data/train_250k data/lang_train exp/e/tri1a exp/e/tri1a_ali_250k

	# train an LDA+MLLT+SAT system
	steps/train_sat.sh --cmd "$basic_cmd" \
													4000 45000 \
													data/train_250k data/lang_train exp/e/tri1a_ali_250k exp/e/tri2a
fi

if [ $stage -le 13 ]; then
	echo "Stage 13: Evaluate second triphone system."
	utils/mkgraph.sh data/lang_test_small exp/e/tri2a exp/e/tri2a/graph_test_small

	# Decode with triphone model
	steps/decode_fmllr.sh --cmd "$basic_cmd" --nj 16 \
									exp/e/tri2a/graph_test_small data/parl-dev-all \
									exp/e/tri2a/decode_parl-dev-all_test_small
fi



if [ $stage -le 14 ]; then
	echo "Stage 14: Train third triphone system with LDA+MLLT+SAT."
	steps/align_fmllr.sh --nj 40 --cmd "$basic_cmd" \
										data/train data/lang_train exp/e/tri2a exp/e/tri2a_ali

	# train an LDA+MLLT+SAT system
	steps/train_sat.sh --cmd "$basic_cmd" \
													7000 150000 \
													data/train data/lang_train exp/e/tri2a_ali exp/e/tri3a
fi

if [ $stage -le 15 ]; then
	echo "Stage 15: Evaluate third triphone system."
	utils/mkgraph.sh data/lang_test_small exp/e/tri3a exp/e/tri3a/graph_test_small

	# Decode with triphone model
	steps/decode_fmllr.sh --cmd "$basic_cmd" --nj 16 \
									exp/e/tri3a/graph_test_small data/parl-dev-all \
									exp/e/tri3a/decode_parl-dev-all_test_small
fi

