#!/usr/bin/env bash

tablefile="result_tables.txt"
use_wer_params_for_cer=true
am=exp/i/tri4j

. path.sh
. parse_options.sh

for testset in parl-test-seen parl-test-unseen parl2020-test lp-test speecon-test yle-test-new; do
  [ -f ${testset}_result.txt ] && echo "Found existing ${testset}_result.txt. Will not overwrite." && exit 1;
done

[ -f $tablefile ] && echo "Found existing $tablefile. Will not overwrite." && exit 1;

echo "# All test set results" >> $tablefile
for devdir in $(find $am/ -type d -iname "decode_parl-dev-all_*" | sort); do
    if [[ -d $devdir/scoring_kaldi/wer_details && -d $devdir/scoring_kaldi/cer_details ]]; then
        wer_lmwt=$(cat $devdir/scoring_kaldi/wer_details/lmwt)
        wer_wip=$(cat $devdir/scoring_kaldi/wer_details/wip)
        if [ "$use_wer_params_for_cer" = true ]; then
            cer_lmwt=$(cat $devdir/scoring_kaldi/wer_details/lmwt)
            cer_wip=$(cat $devdir/scoring_kaldi/wer_details/wip)
        else
            cer_lmwt=$(cat $devdir/scoring_kaldi/cer_details/lmwt)
            cer_wip=$(cat $devdir/scoring_kaldi/cer_details/wip)
        fi
        echo -e "\nNext handling $devdir." >> $tablefile
        echo "WER LMWT is $wer_lmwt and WIP is $wer_wip." >> $tablefile
        echo "CER LMWT is $cer_lmwt and WIP is $cer_wip." >> $tablefile
        cat $devdir/scoring_kaldi/best_wer >> $tablefile
        cat $devdir/scoring_kaldi/best_cer | sed 's/WER/CER/' >> $tablefile
        echo "| Test set | $devdir |" >> $tablefile
        echo "| -------- | ------- |" >> $tablefile
        for testset in parl-test-seen parl-test-unseen parl2020-test lp-test speecon-test yle-test-new; do
            testdir=${devdir/parl-dev-all/$testset}
            wer_file=${testdir}/wer_${wer_lmwt}_${wer_wip}
            cer_file=${testdir}/cer_${cer_lmwt}_${cer_wip}
            if [[ -f $wer_file && -f $cer_file ]]; then
                werline=$(sed -n '2p' $wer_file)
                cerline=$(sed -n '2p' $cer_file)
                wer=$(perl -ne '/\%WER (\d+\.\d+)/ && print $1' $wer_file)
                cer=$(perl -ne '/\%WER (\d+\.\d+)/ && print $1' $cer_file)
                echo $werline $wer_file >> ${testset}_result.txt
                echo $cerline $cer_file | sed 's/WER/CER/' >> ${testset}_result.txt
                echo "| $testset | $wer / $cer |" >> $tablefile
            else
                echo "| $testset | No result |" >> $tablefile
            fi
        done
    fi
done

for testset in parl-test-seen parl-test-unseen parl2020-test lp-test speecon-test yle-test-new; do
    echo >> ${testset}_result.txt
done



