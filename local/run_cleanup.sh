#!/bin/bash

set -eu

stage=1
train_set=train
cleanup_affix=cleaned
clean_cmd="slurm.pl --time 12:00:00 --mem 4G"
clean_nj=120
nj=40

echo "$0 $@"  # Print the command line for logging

. cmd.sh
. path.sh
. parse_options.sh

if [ "$#" -ne 3 ]; then
	echo "Usage: local/run_cleanup.sh <data> <lang> <srcdir>"
	echo "e.g.: $0 data/train data/lang_train exp/i/tri4j"
	echo "Run the data clean up script with the best GMM."
	echo 
	exit 1
fi

data=$1
lang=$2
srcdir=$3

cleaned_data=${data}_${cleanup_affix}
dir=${srcdir}_${cleanup_affix}_work
cleaned_dir=${srcdir}_${cleanup_affix}
ali_dir=${srcdir}_ali_${train_set}_${cleanup_affix}

if [ $stage -le 1 ]; then
	steps/cleanup/clean_and_segment.sh --cmd "$clean_cmd" --nj $clean_nj \
		$data $lang $srcdir $dir $cleaned_data
fi

if [ $stage -le 2 ]; then
	steps/align_fmllr.sh --nj $nj --cmd "$basic_cmd" \
		$cleaned_data $lang $srcdir $ali_dir 
fi

if [ $stage -le 3 ]; then
	steps/train_sat.sh --cmd "$basic_cmd" --num_iters 70 \
		--realign-iters "10 20 30 40 50 60" --fmllr-iters "2 4 6 12 36 42 48" \
		14000 500000 $cleaned_data $lang $ali_dir $cleaned_dir
fi

