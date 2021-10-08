#!/bin/bash

# This script runs the first iteration of the experiments
# where a GMM is trained just like in the Kaldi Librispeech recipe.
# (with added decoding steps)

release_traindir=raw_data/2015-2020-kevat
stage=1
tri_version=a

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
  utils/subset_data_dir.sh data/train 5000 data/train_5k
  utils/subset_data_dir.sh data/train 10000 data/train_10k
  # Manually enforce some rare letters:
	for subset in 2kshort 5k 10k; do
		for letter in c f q w x z å; do 
			local/enforce_letter_in_data.sh data/train "$letter" data/train_$subset
		done
	done
fi

if [ $stage -le 6 ]; then
	echo "Stage 6: Train monophone system."
  # train a monophone system
  steps/train_mono.sh --boost-silence 1.25 --nj 20 --cmd "$basic_cmd" \
                      data/train_2kshort data/lang_train exp/g/mono
fi

if [ $stage -le 7 ]; then
	echo "Stage 7: Evaluate monophone system."
	utils/mkgraph.sh data/lang_test_small exp/g/mono exp/g/mono/graph_test_small

	# Decode with triphone model
	steps/decode.sh --cmd "$basic_cmd" --nj 8 \
									exp/g/mono/graph_test_small data/parl-dev-all \
									exp/g/mono/decode_parl-dev-all_test_small
fi

if [ $stage -le 8 ]; then
	echo "Stage 8: Train first triphone system with 5k utterances."
  steps/align_si.sh --boost-silence 1.25 --nj 10 --cmd "$basic_cmd" \
                    data/train_5k data/lang_train exp/g/mono exp/g/mono_ali_5k

  # train a first delta + delta-delta triphone system on a subset of 5000 utterances
  steps/train_deltas.sh --boost-silence 1.25 --cmd "$basic_cmd" \
                        2000 10000 data/train_5k data/lang_train exp/g/mono_ali_5k exp/g/tri1a
fi

if [ $stage -le 9 ]; then
	echo "Stage 9: Evaluate 5k triphone system."
	utils/mkgraph.sh data/lang_test_small exp/g/tri1a exp/g/tri1a/graph_test_small

	# Decode with triphone model
	steps/decode.sh --cmd "$basic_cmd" --nj 8 \
									exp/g/tri1a/graph_test_small data/parl-dev-all \
									exp/g/tri1a/decode_parl-dev-all_test_small
fi

if [ $stage -le 10 ]; then
	echo "Stage 10: Train second triphone system with 10k utterances."
	steps/align_si.sh --nj 10 --cmd "$basic_cmd" data/train_10k data/lang_train exp/g/tri1a exp/g/tri1a_ali_10k

	# train an LDA+MLLT system
	steps/train_lda_mllt.sh --cmd "$basic_cmd" --splice-opts "--left-context=3 --right-context=3" 4000 45000 \
													data/train_10k data/lang_train exp/g/tri1a_ali_10k exp/g/tri2a
fi

if [ $stage -le 11 ]; then
	echo "Stage 11: Evaluate second triphone system."
	utils/mkgraph.sh data/lang_test_small exp/g/tri2a exp/g/tri2a/graph_test_small

	# Decode with triphone model
	steps/decode.sh --cmd "$basic_cmd" --nj 8 \
									exp/g/tri2a/graph_test_small data/parl-dev-all \
									exp/g/tri2a/decode_parl-dev-all_test_small
fi

if [ $stage -le 12 ]; then
	echo "Stage 12: Train third triphone system with 10k utts and LDA+MLLT+SAT."
	steps/align_si.sh --nj 10 --cmd "$basic_cmd" --use-graphs true \
										data/train_10k data/lang_train exp/g/tri2a exp/g/tri2a_ali_10k

	# train an LDA+MLLT+SAT system
	steps/train_sat.sh --cmd "$basic_cmd" \
													4000 45000 \
													data/train_10k data/lang_train exp/g/tri2a_ali_10k exp/g/tri3a
fi

if [ $stage -le 13 ]; then
	echo "Stage 13: Evaluate third triphone system."
	utils/mkgraph.sh data/lang_test_small exp/g/tri3a exp/g/tri3a/graph_test_small

	# Decode with triphone model
	steps/decode_fmllr.sh --cmd "$basic_cmd" --nj 16 \
									exp/g/tri3a/graph_test_small data/parl-dev-all \
									exp/g/tri3a/decode_parl-dev-all_test_small
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
	echo "Using configuration tri4$tri_version with $num_leaves leaves, $num_gauss gaussians,"
	echo "$num_iters iterations, $realign_iters realign iterations, and $fmllr_iters fmllr iterations."

	if [ ! -d exp/g/tri3a_ali_full ]; then
		steps/align_fmllr.sh --nj 120 --cmd "$basic_cmd" \
										data/train data/lang_train exp/g/tri3a exp/g/tri3a_ali_full
	fi

	# train an LDA+MLLT+SAT system
	steps/train_sat.sh --cmd "$basic_cmd" --num-iters $num_iters \
													--realign-iters "$realign_iters" --fmllr-iters "$fmllr_iters" \
													$num_leaves $num_gauss \
													data/train data/lang_train exp/g/tri3a_ali_full exp/g/tri4$tri_version
fi

if [ $stage -le 15 ]; then
	echo "Stage 15: Evaluate fourth triphone system."
	utils/mkgraph.sh data/lang_test_small exp/g/tri4$tri_version exp/g/tri4$tri_version/graph_test_small

	# Decode with triphone model
	steps/decode_fmllr.sh --cmd "$basic_cmd" --nj 16 \
									exp/g/tri4$tri_version/graph_test_small data/parl-dev-all \
									exp/g/tri4$tri_version/decode_parl-dev-all_test_small
fi

