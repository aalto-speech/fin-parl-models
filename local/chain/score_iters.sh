#!/usr/bin/env bash

decode_set=parl2016-dev
lm=test_parl_20M_varikn.bpe19000.d0.0001
start_iter=4000
end_iter=6000
step=500

echo "$0 $@" # Print the command line for logging

. ./cmd.sh
. ./path.sh
. parse_options.sh

set -eu

if [ $# -ne 1 ]; then
    echo "Usage: local/chain/score_iters.sh <dir>"
    echo "e.g.: $0 exp/chain/tdnn_a"
    echo
    echo "Score multiple iterations of a TDNN chain model."
    echo
    exit 1
fi

dir=$1

if [ ! -d $dir/graph_$lm ]; then
    utils/mkgraph.sh --self-loop-scale 1.0 --remove-oov data/lang_$lm $dir $dir/graph_$lm
fi

for iter in $(eval echo "{$start_iter..$end_iter..$step}"); do
    echo "Decoding iteration $iter of $dir next."
    steps/nnet3/decode.sh --acwt 1.0 --post-decode-acwt 10.0 \
        --nj 16 --cmd "$basic_cmd" --iter $iter \
        $dir/graph_$lm data/${decode_set}_hires $dir/decode_${decode_set}_${lm}_${iter}
done
