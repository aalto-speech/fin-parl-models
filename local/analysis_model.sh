#!/usr/bin/env bash
# Train a 100h model for analysis and decode rest of the data with it

set -euo pipefail

stage=1

. path.sh
. parse_options.sh

echo "$0 $@"

traindata_dir=data/combined_comparison/parl-train-2008-2020-kevat_40k

if [ $stage -le 1 ]; then
	echo "Make a 100 h subset (40k samples result in approx. 100 hours)."
	utils/subset_data_dir.sh --speakers data/combined_comparison/parl-train-2008-2020-kevat \
														40000 $traindata_dir 
fi

if [ $stage -le 2 ]; then
	echo "Train a transcript LM from the 100 h subset."
  local/train_lm.sh --stage 0 --BPE-units 1750 --varikn-scale 0.0001 \
										--traindata $traindata_dir \ 
										--validdata data/parl-dev-all \
										parl-train-2008-2020-kevat_40k \
										data/lang_test_parl-train-2008-2020-kevat_40k_varikn.bpe1750.d0.0001
fi

if [ $stage -le 3 ]; then
	echo "Train TDNN model from the 100 hours of data."
	local/combined_comparison/run_chain_common.sh --train-set parl-train-2008-2020-kevat_40k --nj-align 20

	local/combined_comparison/run_tdnn_d.sh --train-set parl-train-2008-2020-kevat_40k \
																					--lm test_parl-train-2008-2020-kevat_40k_varikn.bpe1750.d0.0001
fi

if [ $stage -le 4 ]; then
	echo "From remaining data, select speakers not in the 100 hour subset."

	tmpdir=$(mktemp -d)
  awk '{print $1}' $traindata_dir/spk2utt > $tmpdir/trainset_speakers.list
  awk '{print $1}' data/combined_comparison/parl-train-2008-2020-kevat/spk2utt > $tmpdir/all_speakers.list
	grep -vf $tmpdir/trainset_speakers.list $tmpdir/all_speakers.list > $tmpdir/non-train_speakers.list
  
	utils/subset_data_dir.sh --spk-list $tmpdir/non-train_speakers.list \
														data/combined_comparison/parl-train-2008-2020-kevat_hires \
														data/combined_comparison/analysis-data_hires
	rm -r $tmpdir
fi

if [ $stage -le 5 ]; then
	echo "Decode the remaining data with an in-domain transcript LM."
	steps/nnet3/decode.sh --stage 2 --acwt 1.0 --post-decode-acwt 10.0 \
												--nj 128 --cmd "slurm.pl --mem 2G --time 24:00:00" \
												exp/combined_comparison/chain/tdnn_d_40k/graph_test_parl-train-2008-2020-kevat_40k_varikn.bpe1750.d0.0001 \
												data/combined_comparison/analysis-data_hires \
												exp/combined_comparison/chain/tdnn_d_40k/decode_analysis-data_test_parl-train-2008-2020-kevat_40k_varikn.bpe1750.d0.0001
fi

if [ $stage -le 6 ]; then
	echo "Decode the remaining data with an out-of-domain LM."
	steps/nnet3/decode.sh --acwt 1.0 --post-decode-acwt 10.0 \
												--nj 128 --cmd "slurm.pl --mem 12G --time 36:00:00" \
												exp/combined_comparison/chain/tdnn_d_40k/graph_test_5gram-kielipankki.bpe19000.d0.0001 \
												data/combined_comparison/analysis-data_hires \
												exp/combined_comparison/chain/tdnn_d_40k/decode_analysis-data_test_5gram-kielipankki.bpe19000.d0.0001
fi

