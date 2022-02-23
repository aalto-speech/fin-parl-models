#!/bin/bash
#SBATCH --time=4:0:0
#SBATCH --mem-per-cpu=16G
#SBATCH --output=rescore_%A.out
#SBATCH -c 20
#SBATCH -p batch-csl,batch-skl

for data in parl-dev-all; do
	for am in exp/chain/tdnn_d; do
		steps/lmrescore_const_arpa.sh data/lang_test_5gram-kielipankki.bpe19000.d0.0001 \
									  data/lang_test_kielipankki.bpe19000.d0.0001_carpa \
									  data/${data}_hires \
									  ${am}/decode_${data}_test_5gram-kielipankki.bpe19000.d0.0001 \
									  ${am}/decode_${data}_test_kielipankki.bpe19000.d0.0001_rescore
	done
done

