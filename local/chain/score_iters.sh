#!/usr/bin/env bash
set -e

decode_set=parl-dev-all

echo "$0 $@"  # Print the command line for logging

. ./cmd.sh
. ./path.sh
. ./utils/parse_options.sh

if [ $# -ne 1 ]; then
	echo "Usage: local/chain/score_iters.sh <dir>"
	echo "e.g.: $0 exp/chain/tdnn_a"
	echo
	echo "Score multiple iterations of a chain model."
	echo
	exit 1
fi

dir=$1

if [ ! -d $dir/graph_test_small ]; then
	utils/mkgraph.sh --self-loop-scale 1.0 --remove-oov data/lang_test_small $dir $dir/graph_test_small
fi

for iter in {4000..6000..500}
do
	steps/nnet3/decode.sh --acwt 1.0 --post-decode-acwt 10.0 \
		--nj 16 --cmd "$basic_cmd" --iter $iter \
		$dir/graph_test_small data/${decode_set}_hires $dir/decode_${decode_set}_test_small_${iter}
done

