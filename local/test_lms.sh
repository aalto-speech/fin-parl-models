#!/bin/bash

set -eu

echo "$0 $@"  # Print the command line for logging

stage=1
score_only_tdnn_d=true

[ -f path.sh ] && . ./path.sh # source the path.
. parse_options.sh || exit 1;
. cmd.sh

if [ "$#" -ne 3 ]; then
	echo "Usage: $0 <lm> <am_dir> <decode_set>"
	echo "e.g.: $0 test_varikn.bpe1750.d0.0001 exp parl-dev-all"
	echo
	echo "Decode all chain models with given language model and"
	echo "decode set."
	echo
	exit 1
fi

lm=$1
am_dir=$2
decode_set=$3

if [ $stage -le 1 ]; then
	dir=$am_dir/i/mono
	echo "Decoding set $decode_set with monophone model $dir and LM $lm next."
	utils/mkgraph.sh --remove-oov data/lang_$lm $dir $dir/graph_$lm

	# Decode with triphone model
	steps/decode.sh --nj 8 --cmd "$basic_cmd" \
				$dir/graph_$lm data/${decode_set} $dir/decode_${decode_set}_$lm
fi

if [ $stage -le 2 ]; then
	dir=$am_dir/i/tri1a
	echo "Decoding set $decode_set with first triphone model $dir and LM $lm next."
	utils/mkgraph.sh --remove-oov data/lang_$lm $dir $dir/graph_$lm

	# Decode with triphone model
	steps/decode.sh --nj 8 --cmd "$basic_cmd" \
				$dir/graph_$lm data/${decode_set} $dir/decode_${decode_set}_$lm
fi

if [ $stage -le 3 ]; then
	dir=$am_dir/i/tri2a
	echo "Decoding set $decode_set with second triphone model $dir and LM $lm next."
	utils/mkgraph.sh --remove-oov data/lang_$lm $dir $dir/graph_$lm

	# Decode with triphone model
	steps/decode.sh --nj 8 --cmd "$basic_cmd" \
				$dir/graph_$lm data/${decode_set} $dir/decode_${decode_set}_$lm
fi

if [ $stage -le 4 ]; then
	dir=$am_dir/i/tri3a
	echo "Decoding set $decode_set with third triphone model $dir and LM $lm next."
	utils/mkgraph.sh --remove-oov data/lang_$lm $dir $dir/graph_$lm

	# Decode with triphone model
	steps/decode_fmllr.sh --nj 8 --cmd "$basic_cmd" \
				$dir/graph_$lm data/${decode_set} $dir/decode_${decode_set}_$lm
fi

if [ $stage -le 5 ]; then
	dir=$am_dir/i/tri4j
	echo "Decode with the last GMM."
	utils/mkgraph.sh --remove-oov data/lang_$lm $dir $dir/graph_$lm

	steps/decode_fmllr.sh --nj 16 --cmd "$basic_cmd" \
				$dir/graph_$lm data/${decode_set} $dir/decode_${decode_set}_$lm
fi

if [ $stage -le 6 ]; then
	dir=$am_dir/chain/tdnn_d
	echo "Decoding set $decode_set with AM $dir and LM $lm next."
	utils/mkgraph.sh --self-loop-scale 1.0 --remove-oov data/lang_$lm $dir $dir/graph_$lm

	steps/nnet3/decode.sh --acwt 1.0 --post-decode-acwt 10.0 \
			--nj 16 --cmd "$basic_cmd" \
			$dir/graph_$lm data/${decode_set}_hires $dir/decode_${decode_set}_$lm
fi

if [ "$score_only_tdnn_d" = true ]; then
	echo "Skipping other DNN models."
	exit 0
fi

if [ $stage -le 7 ]; then
	for model in a b c
	do
		dir=$am_dir/chain/tdnn_$model
		echo "Decoding set $decode_set with AM $dir and LM $lm next."
		utils/mkgraph.sh --self-loop-scale 1.0 --remove-oov data/lang_$lm $dir $dir/graph_$lm

		steps/nnet3/decode.sh --acwt 1.0 --post-decode-acwt 10.0 \
				--nj 16 --cmd "$basic_cmd" \
				$dir/graph_$lm data/${decode_set}_hires $dir/decode_${decode_set}_$lm
	done
fi

if [ $stage -le 8 ]; then
	dir=$am_dir/chain/tdnn_blstm_a_multigpu
	echo "Decoding set $decode_set with AM $dir and LM $lm next."
	utils/mkgraph.sh --self-loop-scale 1.0 --remove-oov data/lang_$lm $dir $dir/graph_$lm

	steps/nnet3/decode.sh --acwt 1.0 --post-decode-acwt 10.0 \
			--nj 16 --cmd "$basic_cmd" \
			--extra-left-context 40 \
			--extra-right-context 40 \
			--extra-left-context-initial 0 \
			--extra-right-context-final 0 \
			--frames-per-chunk "140" \
			$dir/graph_$lm data/${decode_set}_hires $dir/decode_${decode_set}_$lm
fi

