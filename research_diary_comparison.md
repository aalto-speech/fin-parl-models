# 1. Experiments comparing different parliament data combinations

By Aku & Anja

- [1. Experiments comparing different parliament data combinations](#1-experiments-comparing-different-parliament-data-combinations)
  - [1.1. Datasets](#11-datasets)
    - [1.1.1. Dataset sizes](#111-dataset-sizes)
  - [1.2. Results](#12-results)
    - [1.2.1. Old parliament](#121-old-parliament)
    - [1.2.2. Old parliament cleaned](#122-old-parliament-cleaned)
    - [1.2.3. New parliament](#123-new-parliament)
    - [1.2.4. Combined](#124-combined)
    - [1.2.5. Test set evaluations](#125-test-set-evaluations)
    - [1.2.6. Development set result comparison](#126-development-set-result-comparison)
    - [1.2.7. Evaluation set comparison tables](#127-evaluation-set-comparison-tables)

## 1.1. Datasets

We use four parliament datasets in our comparison experiments. From the old parliament data, we use both
'uncleaned' and 'cleaned' versions. This is because André published his results on the cleaned data, but
the new, **published** (in Kielipankki), parliament data is 'uncleaned'. To see how much the cleaning
procedure affects the results, we did experiments on both versions. The cleaning procedure in this case
refers to Kaldi's `steps/cleanup/clean_and_segment_data_nnet3.sh` script.

There is a cleaned version of the new parliament data too (cleaned with Peter's model), but we did no
experiments using it. Instead, we cleaned the new data again with the best HMM-GMM, because that makes
our Kaldi recipes replicable and self-contained. André also cleaned his data with Kaldi using a HMM-GMM:

> After the segmentation and data division a completely independent speech recognition system was
> trained using the Kaldi toolkit [12]. At first a GMM-HMM was trained and this model was used to do
> another cleaning and segmentation step. (Mansikkaniemi et al. 2017)

The uncleaned versions of old and new parliament sets were combined in to one large dataset of over
3000 hours. Since the sets had overlap for years 2015 and 2016, samples from those years were filtered
out of the old parliament set. The new set was cleaned of any speech that appears in the development
and test sets.

### 1.1.1. Dataset sizes

Dataset sizes computed using the Kaldi `utt2dur` files.

| Dataset                        | Size in hours | Directory name (in Triton)      |
| ------------------------------ | ------------- | ------------------------------- |
| Old (André) parliament         | 1559.4523 h   | `parl-train-unfiltered`         |
| Old (André) parliament cleaned | 1385.1348 h   | `parl-train-unfiltered_cleaned` |
| New parliament                 | 1783.4233 h   | `train`                         |
| Combined                       | 3087.1670 h   | `parl-train-2008-2020-kevat`    |

## 1.2. Results

Here, we list results for each dataset and compare them in a table. The LM in this case is the n-gram
made from the 20M parliament indomain corpus. This allows comparison to André's results with a similar
LM (same data and n-gram model).

### 1.2.1. Old parliament

```txt
%WER 69.87 [ 24939 / 35693, 879 ins, 6984 del, 17076 sub ] exp/andre_comparison/i/mono/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_8_0.0
%WER 21.43 [ 7649 / 35693, 820 ins, 2281 del, 4548 sub ] exp/andre_comparison/i/tri1a/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_13_0.0
%WER 17.72 [ 6324 / 35693, 837 ins, 1795 del, 3692 sub ] exp/andre_comparison/i/tri2a/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_14_0.0
%WER 16.77 [ 5986 / 35693, 873 ins, 1583 del, 3530 sub ] exp/andre_comparison/i/tri3a/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_14_0.0
%WER 19.26 [ 6874 / 35693, 920 ins, 1788 del, 4166 sub ] exp/andre_comparison/i/tri3a/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001.si/wer_15_0.0
%WER 14.42 [ 5147 / 35693, 843 ins, 1336 del, 2968 sub ] exp/andre_comparison/i/tri4j/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_14_0.0
%WER 16.79 [ 5993 / 35693, 929 ins, 1511 del, 3553 sub ] exp/andre_comparison/i/tri4j/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001.si/wer_14_0.0
%WER 10.34 [ 3691 / 35693, 632 ins, 1290 del, 1769 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_9_0.0
%WER 10.35 [ 3694 / 35693, 725 ins, 1085 del, 1884 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl-dev-all_test_parl_30M_varikn.bpe19000.d0.0001/wer_8_0.0
%WER 76.23 [ 27207 / 35693, 943 ins, 7297 del, 18967 sub ] exp/andre_comparison/i/mono/decode_parl-dev-all_test_parl-train-unfiltered_varikn.bpe1750.d0.0001/wer_7_0.0
%WER 29.99 [ 10706 / 35693, 980 ins, 2980 del, 6746 sub ] exp/andre_comparison/i/tri1a/decode_parl-dev-all_test_parl-train-unfiltered_varikn.bpe1750.d0.0001/wer_13_0.0
%WER 25.25 [ 9014 / 35693, 962 ins, 2333 del, 5719 sub ] exp/andre_comparison/i/tri2a/decode_parl-dev-all_test_parl-train-unfiltered_varikn.bpe1750.d0.0001/wer_14_0.0
%WER 23.56 [ 8408 / 35693, 942 ins, 2138 del, 5328 sub ] exp/andre_comparison/i/tri3a/decode_parl-dev-all_test_parl-train-unfiltered_varikn.bpe1750.d0.0001/wer_15_0.0
%WER 26.46 [ 9445 / 35693, 993 ins, 2333 del, 6119 sub ] exp/andre_comparison/i/tri3a/decode_parl-dev-all_test_parl-train-unfiltered_varikn.bpe1750.d0.0001.si/wer_15_0.0
%WER 20.94 [ 7473 / 35693, 997 ins, 1792 del, 4684 sub ] exp/andre_comparison/i/tri4j/decode_parl-dev-all_test_parl-train-unfiltered_varikn.bpe1750.d0.0001/wer_14_0.0
%WER 23.33 [ 8328 / 35693, 1013 ins, 1940 del, 5375 sub ] exp/andre_comparison/i/tri4j/decode_parl-dev-all_test_parl-train-unfiltered_varikn.bpe1750.d0.0001.si/wer_14_0.0
%WER 13.97 [ 4986 / 35693, 778 ins, 1349 del, 2859 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl-dev-all_test_parl-train-unfiltered_varikn.bpe1750.d0.0001/wer_7_1.0
%WER 15.00 [ 5354 / 35693, 782 ins, 1478 del, 3094 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl-dev-all_test_5gram-kielipankki.bpe19000.d0.0001/wer_7_0.0
%WER 15.02 [ 5360 / 35693, 782 ins, 1481 del, 3097 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl-dev-all_test_kielipankki.bpe19000.d0.0001_rescore/wer_7_0.0
# After above tri4j has been used to cleanup data
%WER 14.22 [ 5076 / 35693, 837 ins, 1323 del, 2916 sub ] exp/andre_comparison/i/tri4j_recleaned/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_16_0.0
%WER 16.51 [ 5892 / 35693, 924 ins, 1407 del, 3561 sub ] exp/andre_comparison/i/tri4j_recleaned/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001.si/wer_15_0.0
%WER 8.49 [ 3032 / 35693, 470 ins, 884 del, 1678 sub ] exp/andre_comparison/chain/tdnn_d_recleaned/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_9_0.0
```

### 1.2.2. Old parliament cleaned

Results with a cleaned version of the old parliament data, where cleanup was done by André.

```txt
%WER 55.16 [ 19687 / 35693, 828 ins, 6100 del, 12759 sub ] exp/andre_comparison/i_cleaned/mono/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_9_0.0
%WER 21.16 [ 7553 / 35693, 809 ins, 2139 del, 4605 sub ] exp/andre_comparison/i_cleaned/tri1a/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_15_0.0
%WER 17.70 [ 6319 / 35693, 812 ins, 1701 del, 3806 sub ] exp/andre_comparison/i_cleaned/tri2a/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_16_0.0
%WER 16.71 [ 5965 / 35693, 851 ins, 1513 del, 3601 sub ] exp/andre_comparison/i_cleaned/tri3a/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_17_0.0
%WER 19.30 [ 6887 / 35693, 1000 ins, 1590 del, 4297 sub ] exp/andre_comparison/i_cleaned/tri3a/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001.si/wer_14_0.0
%WER 14.05 [ 5015 / 35693, 859 ins, 1198 del, 2958 sub ] exp/andre_comparison/i_cleaned/tri4j/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_16_0.0
%WER 16.52 [ 5898 / 35693, 961 ins, 1342 del, 3595 sub ] exp/andre_comparison/i_cleaned/tri4j/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001.si/wer_16_0.0
%WER 8.35 [ 2981 / 35693, 455 ins, 873 del, 1653 sub ] exp/andre_comparison/chain_cleaned/tdnn_d/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_9_0.0
```

### 1.2.3. New parliament

```txt
%WER 56.24 [ 20073 / 35693, 714 ins, 6535 del, 12824 sub ] exp/i/mono/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_8_0.0
%WER 21.56 [ 7694 / 35693, 820 ins, 2211 del, 4663 sub ] exp/i/tri1a/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_14_0.0
%WER 17.83 [ 6365 / 35693, 844 ins, 1736 del, 3785 sub ] exp/i/tri2a/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_14_0.0
%WER 16.70 [ 5961 / 35693, 857 ins, 1553 del, 3551 sub ] exp/i/tri3a/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_15_0.0
%WER 19.38 [ 6917 / 35693, 961 ins, 1682 del, 4274 sub ] exp/i/tri3a/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001.si/wer_13_0.0
%WER 14.34 [ 5117 / 35693, 803 ins, 1379 del, 2935 sub ] exp/i/tri4j/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_16_0.0
%WER 16.41 [ 5858 / 35693, 877 ins, 1466 del, 3515 sub ] exp/i/tri4j/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001.si/wer_14_0.0
%WER 9.98 [ 3562 / 35693, 502 ins, 1091 del, 1969 sub ] exp/chain/tdnn_d/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_0.0
%WER 10.02 [ 3575 / 35693, 431 ins, 1269 del, 1875 sub ] exp/chain/tdnn_d/decode_parl-dev-all_test_parl_30M_varikn.bpe19000.d0.0001/wer_8_0.0
%WER 65.54 [ 23392 / 35693, 781 ins, 7258 del, 15353 sub ] exp/i/mono/decode_parl-dev-all_test_varikn.bpe1750.d0.0001/wer_8_0.0
%WER 30.93 [ 11039 / 35693, 1067 ins, 2741 del, 7231 sub ] exp/i/tri1a/decode_parl-dev-all_test_varikn.bpe1750.d0.0001/wer_13_0.0
%WER 25.99 [ 9277 / 35693, 968 ins, 2319 del, 5990 sub ] exp/i/tri2a/decode_parl-dev-all_test_varikn.bpe1750.d0.0001/wer_15_0.0
%WER 24.28 [ 8666 / 35693, 1070 ins, 2039 del, 5557 sub ] exp/i/tri3a/decode_parl-dev-all_test_varikn.bpe1750.d0.0001/wer_15_0.0
%WER 27.37 [ 9770 / 35693, 1100 ins, 2259 del, 6411 sub ] exp/i/tri3a/decode_parl-dev-all_test_varikn.bpe1750.d0.0001.si/wer_13_0.0
%WER 21.12 [ 7538 / 35693, 1074 ins, 1741 del, 4723 sub ] exp/i/tri4j/decode_parl-dev-all_test_varikn.bpe1750.d0.0001/wer_14_0.0
%WER 23.86 [ 8517 / 35693, 1123 ins, 1906 del, 5488 sub ] exp/i/tri4j/decode_parl-dev-all_test_varikn.bpe1750.d0.0001.si/wer_13_0.0
%WER 14.19 [ 5066 / 35693, 661 ins, 1413 del, 2992 sub ] exp/chain/tdnn_d/decode_parl-dev-all_test_varikn.bpe1750.d0.0001/wer_8_0.0
%WER 14.77 [ 5272 / 35693, 681 ins, 1350 del, 3241 sub ] exp/chain/tdnn_d/decode_parl-dev-all_test_5gram-kielipankki.bpe19000.d0.0001/wer_6_0.0
%WER 14.79 [ 5279 / 35693, 681 ins, 1351 del, 3247 sub ] exp/chain/tdnn_d/decode_parl-dev-all_test_kielipankki.bpe19000.d0.0001_rescore/wer_6_0.0
%WER 21.84 [ 7794 / 35693, 1412 ins, 1578 del, 4804 sub ] exp/chain/tdnn_d/decode_parl-dev-all_test_dspcon-webcon-interpolated-conversational-lm/wer_8_0.0
# After above tri4j has been used to cleanup data
%WER 14.31 [ 5109 / 35693, 883 ins, 1289 del, 2937 sub ] exp/i/tri4j_cleaned/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_15_0.0
%WER 16.42 [ 5861 / 35693, 868 ins, 1464 del, 3529 sub ] exp/i/tri4j_cleaned/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001.si/wer_15_0.0
%WER 9.37 [ 3345 / 35693, 487 ins, 1059 del, 1799 sub ] exp/chain/tdnn_d_cleaned/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_9_0.0
```

### 1.2.4. Combined

```txt
%WER 61.29 [ 21877 / 35693, 883 ins, 6218 del, 14776 sub ] exp/combined_comparison/i/mono/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_8_0.0
%WER 21.34 [ 7617 / 35693, 844 ins, 2163 del, 4610 sub ] exp/combined_comparison/i/tri1a/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_13_0.0
%WER 17.63 [ 6291 / 35693, 803 ins, 1794 del, 3694 sub ] exp/combined_comparison/i/tri2a/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_15_0.0
%WER 16.41 [ 5858 / 35693, 829 ins, 1604 del, 3425 sub ] exp/combined_comparison/i/tri3a/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_16_0.0
%WER 19.23 [ 6864 / 35693, 984 ins, 1668 del, 4212 sub ] exp/combined_comparison/i/tri3a/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001.si/wer_13_0.0
%WER 14.09 [ 5029 / 35693, 824 ins, 1326 del, 2879 sub ] exp/combined_comparison/i/tri4j/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_16_0.0
%WER 16.21 [ 5787 / 35693, 880 ins, 1409 del, 3498 sub ] exp/combined_comparison/i/tri4j/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001.si/wer_15_0.0
%WER 10.28 [ 3668 / 35693, 718 ins, 1051 del, 1899 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_8_0.0
%WER 10.19 [ 3638 / 35693, 617 ins, 1164 del, 1857 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-dev-all_test_parl_30M_varikn.bpe19000.d0.0001/wer_8_0.5
%WER 10.54 [ 3761 / 35693, 804 ins, 1115 del, 1842 sub ] exp/combined_comparison/chain/tdnn_blstm_a_multigpu/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_0.0
%WER 69.17 [ 24688 / 35693, 939 ins, 6999 del, 16750 sub ] exp/combined_comparison/i/mono/decode_parl-dev-all_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001/wer_8_0.0
%WER 28.43 [ 10148 / 35693, 1023 ins, 2626 del, 6499 sub ] exp/combined_comparison/i/tri1a/decode_parl-dev-all_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001/wer_13_0.0
%WER 23.77 [ 8484 / 35693, 930 ins, 2104 del, 5450 sub ] exp/combined_comparison/i/tri2a/decode_parl-dev-all_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001/wer_14_0.0
%WER 22.20 [ 7924 / 35693, 949 ins, 1958 del, 5017 sub ] exp/combined_comparison/i/tri3a/decode_parl-dev-all_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001/wer_15_0.0
%WER 25.89 [ 9242 / 35693, 1090 ins, 2196 del, 5956 sub ] exp/combined_comparison/i/tri3a/decode_parl-dev-all_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001.si/wer_13_0.0
%WER 19.11 [ 6822 / 35693, 969 ins, 1590 del, 4263 sub ] exp/combined_comparison/i/tri4j/decode_parl-dev-all_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001/wer_15_0.0
%WER 22.11 [ 7892 / 35693, 1045 ins, 1844 del, 5003 sub ] exp/combined_comparison/i/tri4j/decode_parl-dev-all_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001.si/wer_14_0.0
%WER 13.08 [ 4668 / 35693, 781 ins, 1142 del, 2745 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-dev-all_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001/wer_8_0.0
%WER 14.51 [ 5178 / 35693, 700 ins, 1427 del, 3051 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-dev-all_test_5gram-kielipankki.bpe19000.d0.0001/wer_7_0.0
%WER 14.52 [ 5183 / 35693, 708 ins, 1424 del, 3051 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-dev-all_test_kielipankki.bpe19000.d0.0001_rescore/wer_7_0.0
```

### 1.2.5. Test set evaluations

Parliament2017 test set, unseen and seen splits. Unseen and seen speaker splits do not apply for the new eduskunta2021 set.

```txt
# Seen
%WER 10.55 [ 1887 / 17881, 297 ins, 437 del, 1153 sub ] exp/i/tri4j/decode_parl-test-seen_test_parl_20M_varikn.bpe19000.d0.0001/wer_16_0.0
%WER 12.65 [ 2262 / 17881, 357 ins, 488 del, 1417 sub ] exp/i/tri4j/decode_parl-test-seen_test_parl_20M_varikn.bpe19000.d0.0001.si/wer_14_0.0
%WER 8.25 [ 1475 / 17881, 183 ins, 539 del, 753 sub ] exp/chain/tdnn_blstm_a_multigpu/decode_parl-test-seen_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_0.0
%WER 7.64 [ 1367 / 17881, 181 ins, 420 del, 766 sub ] exp/chain/tdnn_d/decode_parl-test-seen_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_0.0
%WER 7.71 [ 1378 / 17881, 161 ins, 476 del, 741 sub ] exp/chain/tdnn_d/decode_parl-test-seen_test_parl_30M_varikn.bpe19000.d0.0001/wer_8_0.0
%WER 11.69 [ 2090 / 17881, 254 ins, 518 del, 1318 sub ] exp/chain/tdnn_d/decode_parl-test-seen_test_5gram-kielipankki.bpe19000.d0.0001/wer_6_0.0
%WER 11.73 [ 2098 / 17881, 254 ins, 519 del, 1325 sub ] exp/chain/tdnn_d/decode_parl-test-seen_test_kielipankki.bpe19000.d0.0001_rescore/wer_6_0.0
%WER 11.31 [ 2022 / 17881, 254 ins, 528 del, 1240 sub ] exp/chain/tdnn_d/decode_parl-test-seen_test_varikn.bpe1750.d0.0001/wer_8_0.0
%WER 8.42 [ 1506 / 17881, 331 ins, 476 del, 699 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl-test-seen_test_parl_20M_varikn.bpe19000.d0.0001/wer_9_0.0
%WER 8.41 [ 1503 / 17881, 366 ins, 402 del, 735 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl-test-seen_test_parl_30M_varikn.bpe19000.d0.0001/wer_8_0.0
%WER 12.29 [ 2197 / 17881, 402 ins, 556 del, 1239 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl-test-seen_test_5gram-kielipankki.bpe19000.d0.0001/wer_7_0.0
%WER 12.33 [ 2205 / 17881, 405 ins, 559 del, 1241 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl-test-seen_test_kielipankki.bpe19000.d0.0001_rescore/wer_7_0.0
%WER 11.46 [ 2050 / 17881, 395 ins, 479 del, 1176 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl-test-seen_test_parl-train-unfiltered_varikn.bpe1750.d0.0001/wer_7_1.0
%WER 7.58 [ 1356 / 17881, 311 ins, 352 del, 693 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-test-seen_test_parl_20M_varikn.bpe19000.d0.0001/wer_8_0.0
%WER 7.66 [ 1370 / 17881, 275 ins, 399 del, 696 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-test-seen_test_parl_30M_varikn.bpe19000.d0.0001/wer_8_0.5
%WER 11.26 [ 2014 / 17881, 322 ins, 507 del, 1185 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-test-seen_test_5gram-kielipankki.bpe19000.d0.0001/wer_7_0.0
%WER 11.25 [ 2011 / 17881, 316 ins, 509 del, 1186 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-test-seen_test_kielipankki.bpe19000.d0.0001_rescore/wer_7_0.0
%WER 10.32 [ 1845 / 17881, 362 ins, 389 del, 1094 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-test-seen_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001/wer_8_0.0
%CER 3.71 [ 4869 / 131337, 1763 ins, 2076 del, 1030 sub ] exp/i/tri4j/decode_parl-test-seen_test_parl_20M_varikn.bpe19000.d0.0001/cer_13_0.0
%CER 3.06 [ 4015 / 131337, 1559 ins, 1838 del, 618 sub ] exp/chain/tdnn_blstm_a_multigpu/decode_parl-test-seen_test_parl_20M_varikn.bpe19000.d0.0001/cer_6_0.0
%CER 2.78 [ 3653 / 131337, 1350 ins, 1715 del, 588 sub ] exp/chain/tdnn_d/decode_parl-test-seen_test_parl_20M_varikn.bpe19000.d0.0001/cer_7_0.0
%CER 2.73 [ 3587 / 131337, 1530 ins, 1431 del, 626 sub ] exp/chain/tdnn_d/decode_parl-test-seen_test_parl_30M_varikn.bpe19000.d0.0001/cer_6_0.0
%CER 3.55 [ 4657 / 131337, 1828 ins, 1963 del, 866 sub ] exp/chain/tdnn_d/decode_parl-test-seen_test_5gram-kielipankki.bpe19000.d0.0001/cer_6_0.0
%CER 3.56 [ 4670 / 131337, 1835 ins, 1973 del, 862 sub ] exp/chain/tdnn_d/decode_parl-test-seen_test_kielipankki.bpe19000.d0.0001_rescore/cer_6_0.0
%CER 3.45 [ 4527 / 131337, 1906 ins, 1699 del, 922 sub ] exp/chain/tdnn_d/decode_parl-test-seen_test_varikn.bpe1750.d0.0001/cer_6_0.5
%CER 3.81 [ 5008 / 131337, 2940 ins, 1483 del, 585 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl-test-seen_test_parl_20M_varikn.bpe19000.d0.0001/cer_7_0.5
%CER 3.89 [ 5109 / 131337, 3037 ins, 1494 del, 578 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl-test-seen_test_parl_30M_varikn.bpe19000.d0.0001/cer_7_0.5
%CER 4.70 [ 6167 / 131337, 3590 ins, 1727 del, 850 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl-test-seen_test_5gram-kielipankki.bpe19000.d0.0001/cer_6_0.0
%CER 4.61 [ 6054 / 131337, 3381 ins, 1824 del, 849 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl-test-seen_test_kielipankki.bpe19000.d0.0001_rescore/cer_6_0.5
%CER 4.25 [ 5586 / 131337, 2837 ins, 1920 del, 829 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl-test-seen_test_parl-train-unfiltered_varikn.bpe1750.d0.0001/cer_7_1.0
%CER 3.17 [ 4167 / 131337, 2364 ins, 1228 del, 575 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-test-seen_test_parl_20M_varikn.bpe19000.d0.0001/cer_7_0.0
%CER 3.22 [ 4224 / 131337, 2378 ins, 1255 del, 591 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-test-seen_test_parl_30M_varikn.bpe19000.d0.0001/cer_6_1.0
%CER 3.91 [ 5135 / 131337, 2637 ins, 1705 del, 793 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-test-seen_test_5gram-kielipankki.bpe19000.d0.0001/cer_6_0.5
%CER 3.93 [ 5160 / 131337, 2808 ins, 1563 del, 789 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-test-seen_test_kielipankki.bpe19000.d0.0001_rescore/cer_6_0.0
%CER 3.54 [ 4648 / 131337, 2202 ins, 1695 del, 751 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-test-seen_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001/cer_7_1.0
# Unseen
%WER 8.86 [ 1530 / 17261, 300 ins, 326 del, 904 sub ] exp/i/tri4j/decode_parl-test-unseen_test_parl_20M_varikn.bpe19000.d0.0001/wer_16_0.0
%WER 10.56 [ 1823 / 17261, 340 ins, 358 del, 1125 sub ] exp/i/tri4j/decode_parl-test-unseen_test_parl_20M_varikn.bpe19000.d0.0001.si/wer_14_0.0
%WER 6.52 [ 1125 / 17261, 170 ins, 369 del, 586 sub ] exp/chain/tdnn_blstm_a_multigpu/decode_parl-test-unseen_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_0.0
%WER 6.26 [ 1081 / 17261, 164 ins, 313 del, 604 sub ] exp/chain/tdnn_d/decode_parl-test-unseen_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_0.0
%WER 6.37 [ 1099 / 17261, 158 ins, 379 del, 562 sub ] exp/chain/tdnn_d/decode_parl-test-unseen_test_parl_30M_varikn.bpe19000.d0.0001/wer_8_0.0
%WER 10.06 [ 1736 / 17261, 252 ins, 393 del, 1091 sub ] exp/chain/tdnn_d/decode_parl-test-unseen_test_5gram-kielipankki.bpe19000.d0.0001/wer_6_0.0
%WER 10.07 [ 1739 / 17261, 254 ins, 394 del, 1091 sub ] exp/chain/tdnn_d/decode_parl-test-unseen_test_kielipankki.bpe19000.d0.0001_rescore/wer_6_0.0
%WER 9.70 [ 1674 / 17261, 252 ins, 414 del, 1008 sub ] exp/chain/tdnn_d/decode_parl-test-unseen_test_varikn.bpe1750.d0.0001/wer_8_0.0
%WER 7.22 [ 1246 / 17261, 296 ins, 370 del, 580 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl-test-unseen_test_parl_20M_varikn.bpe19000.d0.0001/wer_9_0.0
%WER 7.10 [ 1226 / 17261, 318 ins, 320 del, 588 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl-test-unseen_test_parl_30M_varikn.bpe19000.d0.0001/wer_8_0.0
%WER 11.19 [ 1931 / 17261, 380 ins, 438 del, 1113 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl-test-unseen_test_5gram-kielipankki.bpe19000.d0.0001/wer_7_0.0
%WER 11.19 [ 1931 / 17261, 385 ins, 438 del, 1108 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl-test-unseen_test_kielipankki.bpe19000.d0.0001_rescore/wer_7_0.0
%WER 10.86 [ 1875 / 17261, 379 ins, 388 del, 1108 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl-test-unseen_test_parl-train-unfiltered_varikn.bpe1750.d0.0001/wer_7_1.0
%WER 6.67 [ 1152 / 17261, 296 ins, 279 del, 577 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-test-unseen_test_parl_20M_varikn.bpe19000.d0.0001/wer_8_0.0
%WER 6.62 [ 1142 / 17261, 257 ins, 336 del, 549 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-test-unseen_test_parl_30M_varikn.bpe19000.d0.0001/wer_8_0.5
%WER 9.90 [ 1708 / 17261, 282 ins, 406 del, 1020 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-test-unseen_test_5gram-kielipankki.bpe19000.d0.0001/wer_7_0.0
%WER 9.93 [ 1714 / 17261, 283 ins, 407 del, 1024 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-test-unseen_test_kielipankki.bpe19000.d0.0001_rescore/wer_7_0.0
%WER 9.32 [ 1608 / 17261, 314 ins, 314 del, 980 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-test-unseen_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001/wer_8_0.0
%CER 3.35 [ 4238 / 126461, 1845 ins, 1582 del, 811 sub ] exp/i/tri4j/decode_parl-test-unseen_test_parl_20M_varikn.bpe19000.d0.0001/cer_13_0.0
%CER 2.65 [ 3346 / 126461, 1478 ins, 1387 del, 481 sub ] exp/chain/tdnn_blstm_a_multigpu/decode_parl-test-unseen_test_parl_20M_varikn.bpe19000.d0.0001/cer_6_0.0
%CER 2.53 [ 3195 / 126461, 1381 ins, 1351 del, 463 sub ] exp/chain/tdnn_d/decode_parl-test-unseen_test_parl_20M_varikn.bpe19000.d0.0001/cer_7_0.0
%CER 2.53 [ 3198 / 126461, 1559 ins, 1164 del, 475 sub ] exp/chain/tdnn_d/decode_parl-test-unseen_test_parl_30M_varikn.bpe19000.d0.0001/cer_6_0.0
%CER 3.26 [ 4126 / 126461, 1900 ins, 1532 del, 694 sub ] exp/chain/tdnn_d/decode_parl-test-unseen_test_5gram-kielipankki.bpe19000.d0.0001/cer_6_0.0
%CER 3.27 [ 4132 / 126461, 1897 ins, 1543 del, 692 sub ] exp/chain/tdnn_d/decode_parl-test-unseen_test_kielipankki.bpe19000.d0.0001_rescore/cer_6_0.0
%CER 3.16 [ 3998 / 126461, 1873 ins, 1407 del, 718 sub ] exp/chain/tdnn_d/decode_parl-test-unseen_test_varikn.bpe1750.d0.0001/cer_6_0.5
%CER 3.38 [ 4273 / 126461, 2602 ins, 1129 del, 542 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl-test-unseen_test_parl_20M_varikn.bpe19000.d0.0001/cer_7_0.5
%CER 3.43 [ 4336 / 126461, 2590 ins, 1198 del, 548 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl-test-unseen_test_parl_30M_varikn.bpe19000.d0.0001/cer_7_0.5
%CER 4.45 [ 5623 / 126461, 3372 ins, 1347 del, 904 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl-test-unseen_test_5gram-kielipankki.bpe19000.d0.0001/cer_6_0.0
%CER 4.37 [ 5522 / 126461, 3196 ins, 1448 del, 878 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl-test-unseen_test_kielipankki.bpe19000.d0.0001_rescore/cer_6_0.5
%CER 4.02 [ 5079 / 126461, 2698 ins, 1618 del, 763 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl-test-unseen_test_parl-train-unfiltered_varikn.bpe1750.d0.0001/cer_7_1.0
%CER 2.94 [ 3717 / 126461, 2210 ins, 1015 del, 492 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-test-unseen_test_parl_20M_varikn.bpe19000.d0.0001/cer_7_0.0
%CER 2.91 [ 3684 / 126461, 2167 ins, 1026 del, 491 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-test-unseen_test_parl_30M_varikn.bpe19000.d0.0001/cer_6_1.0
%CER 3.64 [ 4605 / 126461, 2436 ins, 1414 del, 755 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-test-unseen_test_5gram-kielipankki.bpe19000.d0.0001/cer_6_0.5
%CER 3.71 [ 4694 / 126461, 2626 ins, 1304 del, 764 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-test-unseen_test_kielipankki.bpe19000.d0.0001_rescore/cer_6_0.0
%CER 3.19 [ 4031 / 126461, 1956 ins, 1408 del, 667 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-test-unseen_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001/cer_7_1.0
# Parl-test-all 2017 (calculated by hand)
%WER 9.72 [ 3417 / 35142, 597 ins, 763 del, 2057 sub ] exp/i/tri4j + test_parl_20M_varikn.bpe19000.d0.0001
%WER 11.62 [ 4085 / 35142, 697 ins, 846 del, 2542 sub ] exp/i/tri4j + test_parl_20M_varikn.bpe19000.d0.0001.si
%WER 7.40 [ 2600 / 35142, 353 ins, 908 del, 1339 sub ] exp/chain/tdnn_blstm_a_multigpu + test_parl_20M_varikn.bpe19000.d0.0001
%WER 6.97 [ 2448 / 35142, 345 ins, 733 del, 1370 sub ] exp/chain/tdnn_d + test_parl_20M_varikn.bpe19000.d0.0001
%WER 7.05 [ 2477 / 35142, 319 ins, 855 del, 1303 sub ] exp/chain/tdnn_d + test_parl_30M_varikn.bpe19000.d0.0001
%WER 10.89 [ 3826 / 35142, 506 ins, 911 del, 2409 sub ] exp/chain/tdnn_d + test_5gram-kielipankki.bpe19000.d0.0001
%WER 10.92 [ 3837 / 35142, 508 ins, 913 del, 2416 sub ] exp/chain/tdnn_d + test_kielipankki.bpe19000.d0.0001_rescore
%WER 10.52 [ 3696 / 35142, 506 ins, 942 del, 2248 sub ] exp/chain/tdnn_d + test_varikn.bpe1750.d0.0001
%WER 7.83 [ 2752 / 35142, 627 ins, 846 del, 1279 sub ] exp/andre_comparison/chain/tdnn_d + test_parl_20M_varikn.bpe19000.d0.0001
%WER 7.77 [ 2729 / 35142, 684 ins, 722 del, 1323 sub ] exp/andre_comparison/chain/tdnn_d + test_parl_30M_varikn.bpe19000.d0.0001
%WER 11.75 [ 4128 / 35142, 782 ins, 994 del, 2352 sub ] exp/andre_comparison/chain/tdnn_d + test_5gram-kielipankki.bpe19000.d0.0001
%WER 11.77 [ 4136 / 35142, 790 ins, 997 del, 2349 sub ] exp/andre_comparison/chain/tdnn_d + test_kielipankki.bpe19000.d0.0001_rescore
%WER 11.17 [ 3925 / 35142, 774 ins, 867 del, 2284 sub ] exp/andre_comparison/chain/tdnn_d + test_parl-train-unfiltered_varikn.bpe1750.d0.0001
%WER 7.14 [ 2508 / 35142, 607 ins, 631 del, 1270 sub ] exp/combined_comparison/chain/tdnn_d + test_parl_20M_varikn.bpe19000.d0.0001
%WER 7.15 [ 2512 / 35142, 532 ins, 735 del, 1245 sub ] exp/combined_comparison/chain/tdnn_d + test_parl_30M_varikn.bpe19000.d0.0001
%WER 10.59 [ 3722 / 35142, 604 ins, 913 del, 2205 sub ] exp/combined_comparison/chain/tdnn_d + test_5gram-kielipankki.bpe19000.d0.0001
%WER 10.60 [ 3725 / 35142, 599 ins, 916 del, 2210 sub ] exp/combined_comparison/chain/tdnn_d + test_kielipankki.bpe19000.d0.0001_rescore
%WER 9.83 [ 3453 / 35142, 676 ins, 703 del, 2074 sub ] exp/combined_comparison/chain/tdnn_d + test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001
%CER 3.53 [ 9107 / 257798, 3608 ins, 3658 del, 1841 sub ] exp/i/tri4j + test_parl_20M_varikn.bpe19000.d0.0001
%CER 2.86 [ 7361 / 257798, 3037 ins, 3225 del, 1099 sub ] exp/chain/tdnn_blstm_a_multigpu + test_parl_20M_varikn.bpe19000.d0.0001
%CER 2.66 [ 6848 / 257798, 2731 ins, 3066 del, 1051 sub ] exp/chain/tdnn_d + test_parl_20M_varikn.bpe19000.d0.0001
%CER 2.63 [ 6785 / 257798, 3089 ins, 2595 del, 1101 sub ] exp/chain/tdnn_d + test_parl_30M_varikn.bpe19000.d0.0001
%CER 3.41 [ 8783 / 257798, 3728 ins, 3495 del, 1560 sub ] exp/chain/tdnn_d + test_5gram-kielipankki.bpe19000.d0.0001
%CER 3.41 [ 8802 / 257798, 3732 ins, 3516 del, 1554 sub ] exp/chain/tdnn_d + test_kielipankki.bpe19000.d0.0001_rescore
%CER 3.31 [ 8525 / 257798, 3779 ins, 3106 del, 1640 sub ] exp/chain/tdnn_d + test_varikn.bpe1750.d0.0001
%CER 3.60 [ 9281 / 257798, 5542 ins, 2612 del, 1127 sub ] exp/andre_comparison/chain/tdnn_d + test_parl_20M_varikn.bpe19000.d0.0001
%CER 3.66 [ 9445 / 257798, 5627 ins, 2692 del, 1126 sub ] exp/andre_comparison/chain/tdnn_d + test_parl_30M_varikn.bpe19000.d0.0001
%CER 4.57 [ 11790 / 257798, 6962 ins, 3074 del, 1754 sub ] exp/andre_comparison/chain/tdnn_d + test_5gram-kielipankki.bpe19000.d0.0001
%CER 4.49 [ 11576 / 257798, 6577 ins, 3272 del, 1727 sub ] exp/andre_comparison/chain/tdnn_d + test_kielipankki.bpe19000.d0.0001_rescore
%CER 4.14 [ 10665 / 257798, 5535 ins, 3538 del, 1592 sub ] exp/andre_comparison/chain/tdnn_d + test_parl-train-unfiltered_varikn.bpe1750.d0.0001
%CER 3.06 [ 7884 / 257798, 4574 ins, 2243 del, 1067 sub ] exp/combined_comparison/chain/tdnn_d + test_parl_20M_varikn.bpe19000.d0.0001
%CER 3.07 [ 7908 / 257798, 4545 ins, 2281 del, 1082 sub ] exp/combined_comparison/chain/tdnn_d + test_parl_30M_varikn.bpe19000.d0.0001
%CER 3.78 [ 9740 / 257798, 5073 ins, 3119 del, 1548 sub ] exp/combined_comparison/chain/tdnn_d + test_5gram-kielipankki.bpe19000.d0.0001
%CER 3.82 [ 9854 / 257798, 5434 ins, 2867 del, 1553 sub ] exp/combined_comparison/chain/tdnn_d + test_kielipankki.bpe19000.d0.0001_rescore
%CER 3.37 [ 8679 / 257798, 4158 ins, 3103 del, 1418 sub ] exp/combined_comparison/chain/tdnn_d + test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001
```

Parliament2021 test set.

```txt
%WER 17.53 [ 4780 / 27261, 729 ins, 795 del, 3256 sub ] exp/i/tri4j/decode_parl2021-test_test_parl_20M_varikn.bpe19000.d0.0001/wer_16_0.0
%WER 20.53 [ 5596 / 27261, 889 ins, 802 del, 3905 sub ] exp/i/tri4j/decode_parl2021-test_test_parl_20M_varikn.bpe19000.d0.0001.si/wer_14_0.0
%WER 10.32 [ 2814 / 27261, 314 ins, 781 del, 1719 sub ] exp/chain/tdnn_blstm_a_multigpu/decode_parl2021-test_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_0.0
%WER 9.83 [ 2680 / 27261, 289 ins, 659 del, 1732 sub ] exp/chain/tdnn_d/decode_parl2021-test_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_0.0
%WER 9.34 [ 2545 / 27261, 247 ins, 765 del, 1533 sub ] exp/chain/tdnn_d/decode_parl2021-test_test_parl_30M_varikn.bpe19000.d0.0001/wer_8_0.0
%WER 9.59 [ 2613 / 27261, 275 ins, 648 del, 1690 sub ] exp/chain/tdnn_d/decode_parl2021-test_test_5gram-kielipankki.bpe19000.d0.0001/wer_6_0.0
%WER 9.59 [ 2614 / 27261, 278 ins, 648 del, 1688 sub ] exp/chain/tdnn_d/decode_parl2021-test_test_kielipankki.bpe19000.d0.0001_rescore/wer_6_0.0
%WER 8.84 [ 2410 / 27261, 254 ins, 596 del, 1560 sub ] exp/chain/tdnn_d/decode_parl2021-test_test_varikn.bpe1750.d0.0001/wer_8_0.0
%WER 14.97 [ 4081 / 27261, 756 ins, 1238 del, 2087 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl2021-test_test_parl_20M_varikn.bpe19000.d0.0001/wer_9_0.0
%WER 13.17 [ 3589 / 27261, 750 ins, 1008 del, 1831 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl2021-test_test_parl_30M_varikn.bpe19000.d0.0001/wer_8_0.0
%WER 13.91 [ 3791 / 27261, 480 ins, 1167 del, 2144 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl2021-test_test_5gram-kielipankki.bpe19000.d0.0001/wer_7_0.0
%WER 13.89 [ 3786 / 27261, 478 ins, 1165 del, 2143 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl2021-test_test_kielipankki.bpe19000.d0.0001_rescore/wer_7_0.0
%WER 13.90 [ 3790 / 27261, 581 ins, 1075 del, 2134 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl2021-test_test_parl-train-unfiltered_varikn.bpe1750.d0.0001/wer_7_1.0
%WER 10.67 [ 2908 / 27261, 312 ins, 815 del, 1781 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl2021-test_test_parl_20M_varikn.bpe19000.d0.0001/wer_8_0.0
%WER 9.73 [ 2653 / 27261, 230 ins, 884 del, 1539 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl2021-test_test_parl_30M_varikn.bpe19000.d0.0001/wer_8_0.5
%WER 10.12 [ 2759 / 27261, 243 ins, 814 del, 1702 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl2021-test_test_5gram-kielipankki.bpe19000.d0.0001/wer_7_0.0
%WER 10.12 [ 2759 / 27261, 241 ins, 816 del, 1702 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl2021-test_test_kielipankki.bpe19000.d0.0001_rescore/wer_7_0.0
%WER 8.76 [ 2389 / 27261, 248 ins, 602 del, 1539 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl2021-test_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001/wer_8_0.0
%CER 4.18 [ 8438 / 201861, 3467 ins, 2799 del, 2172 sub ] exp/i/tri4j/decode_parl2021-test_test_parl_20M_varikn.bpe19000.d0.0001/cer_13_0.0
%CER 2.81 [ 5671 / 201861, 2674 ins, 2006 del, 991 sub ] exp/chain/tdnn_blstm_a_multigpu/decode_parl2021-test_test_parl_20M_varikn.bpe19000.d0.0001/cer_6_0.0
%CER 2.54 [ 5129 / 201861, 2258 ins, 1964 del, 907 sub ] exp/chain/tdnn_d/decode_parl2021-test_test_parl_20M_varikn.bpe19000.d0.0001/cer_7_0.0
%CER 2.27 [ 4591 / 201861, 2218 ins, 1559 del, 814 sub ] exp/chain/tdnn_d/decode_parl2021-test_test_parl_30M_varikn.bpe19000.d0.0001/cer_6_0.0
%CER 2.50 [ 5043 / 201861, 2224 ins, 1890 del, 929 sub ] exp/chain/tdnn_d/decode_parl2021-test_test_5gram-kielipankki.bpe19000.d0.0001/cer_6_0.0
%CER 2.50 [ 5039 / 201861, 2226 ins, 1893 del, 920 sub ] exp/chain/tdnn_d/decode_parl2021-test_test_kielipankki.bpe19000.d0.0001_rescore/cer_6_0.0
%CER 2.19 [ 4422 / 201861, 2268 ins, 1336 del, 818 sub ] exp/chain/tdnn_d/decode_parl2021-test_test_varikn.bpe1750.d0.0001/cer_6_0.5
%CER 5.13 [ 10357 / 201861, 5423 ins, 3611 del, 1323 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl2021-test_test_parl_20M_varikn.bpe19000.d0.0001/cer_7_0.5
%CER 4.81 [ 9713 / 201861, 5098 ins, 3459 del, 1156 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl2021-test_test_parl_30M_varikn.bpe19000.d0.0001/cer_7_0.5
%CER 4.72 [ 9536 / 201861, 4394 ins, 3590 del, 1552 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl2021-test_test_5gram-kielipankki.bpe19000.d0.0001/cer_6_0.0
%CER 4.56 [ 9202 / 201861, 3828 ins, 3891 del, 1483 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl2021-test_test_kielipankki.bpe19000.d0.0001_rescore/cer_6_0.5
%CER 4.28 [ 8630 / 201861, 3422 ins, 3920 del, 1288 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl2021-test_test_parl-train-unfiltered_varikn.bpe1750.d0.0001/cer_7_1.0
%CER 2.65 [ 5349 / 201861, 2465 ins, 1931 del, 953 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl2021-test_test_parl_20M_varikn.bpe19000.d0.0001/cer_7_0.0
%CER 2.39 [ 4833 / 201861, 2218 ins, 1810 del, 805 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl2021-test_test_parl_30M_varikn.bpe19000.d0.0001/cer_6_1.0
%CER 2.63 [ 5319 / 201861, 2328 ins, 2047 del, 944 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl2021-test_test_5gram-kielipankki.bpe19000.d0.0001/cer_6_0.5
%CER 2.60 [ 5249 / 201861, 2429 ins, 1868 del, 952 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl2021-test_test_kielipankki.bpe19000.d0.0001_rescore/cer_6_0.0
%CER 2.29 [ 4620 / 201861, 1960 ins, 1894 del, 766 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl2021-test_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001/cer_7_1.0
```

Lahjoita puhetta test set.

```txt
%WER 73.48 [ 45982 / 62574, 1326 ins, 20501 del, 24155 sub ] exp/i/tri4j/decode_lp-test_test_parl_20M_varikn.bpe19000.d0.0001/wer_16_0.0
%WER 82.36 [ 51533 / 62574, 976 ins, 28866 del, 21691 sub ] exp/i/tri4j/decode_lp-test_test_parl_20M_varikn.bpe19000.d0.0001.si/wer_14_0.0
%WER 71.13 [ 44511 / 62574, 689 ins, 24027 del, 19795 sub ] exp/chain/tdnn_blstm_a_multigpu/decode_lp-test_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_0.0
%WER 66.59 [ 41666 / 62574, 1152 ins, 16130 del, 24384 sub ] exp/chain/tdnn_d/decode_lp-test_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_0.0
%WER 66.20 [ 41426 / 62574, 906 ins, 17918 del, 22602 sub ] exp/chain/tdnn_d/decode_lp-test_test_parl_30M_varikn.bpe19000.d0.0001/wer_8_0.0
%WER 64.86 [ 40586 / 62574, 919 ins, 15831 del, 23836 sub ] exp/chain/tdnn_d/decode_lp-test_test_5gram-kielipankki.bpe19000.d0.0001/wer_6_0.0
%WER 64.85 [ 40582 / 62574, 925 ins, 15836 del, 23821 sub ] exp/chain/tdnn_d/decode_lp-test_test_kielipankki.bpe19000.d0.0001_rescore/wer_6_0.0
%WER 66.90 [ 41864 / 62574, 898 ins, 17872 del, 23094 sub ] exp/chain/tdnn_d/decode_lp-test_test_varikn.bpe1750.d0.0001/wer_8_0.0
%WER 68.85 [ 43081 / 62574, 619 ins, 23799 del, 18663 sub ] exp/andre_comparison/chain/tdnn_d/decode_lp-test_test_parl_20M_varikn.bpe19000.d0.0001/wer_9_0.0
%WER 67.26 [ 42089 / 62574, 839 ins, 20686 del, 20564 sub ] exp/andre_comparison/chain/tdnn_d/decode_lp-test_test_parl_30M_varikn.bpe19000.d0.0001/wer_8_0.0
%WER 64.75 [ 40515 / 62574, 687 ins, 18920 del, 20908 sub ] exp/andre_comparison/chain/tdnn_d/decode_lp-test_test_5gram-kielipankki.bpe19000.d0.0001/wer_7_0.0
%WER 64.73 [ 40502 / 62574, 685 ins, 18923 del, 20894 sub ] exp/andre_comparison/chain/tdnn_d/decode_lp-test_test_kielipankki.bpe19000.d0.0001_rescore/wer_7_0.0
%WER 68.41 [ 42810 / 62574, 717 ins, 21567 del, 20526 sub ] exp/andre_comparison/chain/tdnn_d/decode_lp-test_test_parl-train-unfiltered_varikn.bpe1750.d0.0001/wer_7_1.0
%WER 65.48 [ 40973 / 62574, 1146 ins, 15507 del, 24320 sub ] exp/combined_comparison/chain/tdnn_d/decode_lp-test_test_parl_20M_varikn.bpe19000.d0.0001/wer_8_0.0
%WER 65.16 [ 40774 / 62574, 964 ins, 17188 del, 22622 sub ] exp/combined_comparison/chain/tdnn_d/decode_lp-test_test_parl_30M_varikn.bpe19000.d0.0001/wer_8_0.5
%WER 62.80 [ 39294 / 62574, 935 ins, 14783 del, 23576 sub ] exp/combined_comparison/chain/tdnn_d/decode_lp-test_test_5gram-kielipankki.bpe19000.d0.0001/wer_7_0.0
%WER 62.79 [ 39289 / 62574, 936 ins, 14789 del, 23564 sub ] exp/combined_comparison/chain/tdnn_d/decode_lp-test_test_kielipankki.bpe19000.d0.0001_rescore/wer_7_0.0
%WER 64.99 [ 40665 / 62574, 1118 ins, 15549 del, 23998 sub ] exp/combined_comparison/chain/tdnn_d/decode_lp-test_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001/wer_8_0.0
%CER 40.43 [ 135712 / 335702, 18500 ins, 80655 del, 36557 sub ] exp/i/tri4j/decode_lp-test_test_parl_20M_varikn.bpe19000.d0.0001/cer_13_0.0
%CER 41.56 [ 139532 / 335702, 15807 ins, 96961 del, 26764 sub ] exp/chain/tdnn_blstm_a_multigpu/decode_lp-test_test_parl_20M_varikn.bpe19000.d0.0001/cer_6_0.0
%CER 33.73 [ 113230 / 335702, 20054 ins, 62047 del, 31129 sub ] exp/chain/tdnn_d/decode_lp-test_test_parl_20M_varikn.bpe19000.d0.0001/cer_7_0.0
%CER 32.89 [ 110401 / 335702, 21488 ins, 56744 del, 32169 sub ] exp/chain/tdnn_d/decode_lp-test_test_parl_30M_varikn.bpe19000.d0.0001/cer_6_0.0
%CER 31.84 [ 106890 / 335702, 19412 ins, 56534 del, 30944 sub ] exp/chain/tdnn_d/decode_lp-test_test_5gram-kielipankki.bpe19000.d0.0001/cer_6_0.0
%CER 31.82 [ 106828 / 335702, 19385 ins, 56475 del, 30968 sub ] exp/chain/tdnn_d/decode_lp-test_test_kielipankki.bpe19000.d0.0001_rescore/cer_6_0.0
%CER 32.97 [ 110670 / 335702, 20148 ins, 58443 del, 32079 sub ] exp/chain/tdnn_d/decode_lp-test_test_varikn.bpe1750.d0.0001/cer_6_0.5
%CER 36.37 [ 122104 / 335702, 16331 ins, 79632 del, 26141 sub ] exp/andre_comparison/chain/tdnn_d/decode_lp-test_test_parl_20M_varikn.bpe19000.d0.0001/cer_7_0.5
%CER 36.07 [ 121071 / 335702, 16398 ins, 78863 del, 25810 sub ] exp/andre_comparison/chain/tdnn_d/decode_lp-test_test_parl_30M_varikn.bpe19000.d0.0001/cer_7_0.5
%CER 32.78 [ 110032 / 335702, 17889 ins, 63897 del, 28246 sub ] exp/andre_comparison/chain/tdnn_d/decode_lp-test_test_5gram-kielipankki.bpe19000.d0.0001/cer_6_0.0
%CER 33.02 [ 110839 / 335702, 16930 ins, 66637 del, 27272 sub ] exp/andre_comparison/chain/tdnn_d/decode_lp-test_test_kielipankki.bpe19000.d0.0001_rescore/cer_6_0.5
%CER 37.42 [ 125627 / 335702, 13411 ins, 89362 del, 22854 sub ] exp/andre_comparison/chain/tdnn_d/decode_lp-test_test_parl-train-unfiltered_varikn.bpe1750.d0.0001/cer_7_1.0
%CER 32.12 [ 107844 / 335702, 23145 ins, 51443 del, 33256 sub ] exp/combined_comparison/chain/tdnn_d/decode_lp-test_test_parl_20M_varikn.bpe19000.d0.0001/cer_7_0.0
%CER 31.60 [ 106083 / 335702, 22268 ins, 51175 del, 32640 sub ] exp/combined_comparison/chain/tdnn_d/decode_lp-test_test_parl_30M_varikn.bpe19000.d0.0001/cer_6_1.0
%CER 30.42 [ 102117 / 335702, 21326 ins, 48351 del, 32440 sub ] exp/combined_comparison/chain/tdnn_d/decode_lp-test_test_5gram-kielipankki.bpe19000.d0.0001/cer_6_0.5
%CER 30.36 [ 101913 / 335702, 22608 ins, 46050 del, 33255 sub ] exp/combined_comparison/chain/tdnn_d/decode_lp-test_test_kielipankki.bpe19000.d0.0001_rescore/cer_6_0.0
%CER 32.62 [ 109508 / 335702, 17884 ins, 63537 del, 28087 sub ] exp/combined_comparison/chain/tdnn_d/decode_lp-test_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001/cer_7_1.0
```

Speecon test set.

```txt
%WER 30.00 [ 1660 / 5533, 203 ins, 292 del, 1165 sub ] exp/i/tri4j/decode_speecon-test_test_parl_20M_varikn.bpe19000.d0.0001/wer_16_0.0
%WER 39.22 [ 2170 / 5533, 306 ins, 353 del, 1511 sub ] exp/i/tri4j/decode_speecon-test_test_parl_20M_varikn.bpe19000.d0.0001.si/wer_14_0.0
%WER 21.76 [ 1204 / 5533, 125 ins, 275 del, 804 sub ] exp/chain/tdnn_blstm_a_multigpu/decode_speecon-test_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_0.0
%WER 22.19 [ 1228 / 5533, 127 ins, 292 del, 809 sub ] exp/chain/tdnn_d/decode_speecon-test_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_0.0
%WER 21.71 [ 1201 / 5533, 136 ins, 294 del, 771 sub ] exp/chain/tdnn_d/decode_speecon-test_test_parl_30M_varikn.bpe19000.d0.0001/wer_8_0.0
%WER 14.78 [ 818 / 5533, 86 ins, 247 del, 485 sub ] exp/chain/tdnn_d/decode_speecon-test_test_5gram-kielipankki.bpe19000.d0.0001/wer_6_0.0
%WER 14.78 [ 818 / 5533, 85 ins, 248 del, 485 sub ] exp/chain/tdnn_d/decode_speecon-test_test_kielipankki.bpe19000.d0.0001_rescore/wer_6_0.0
%WER 22.12 [ 1224 / 5533, 140 ins, 292 del, 792 sub ] exp/chain/tdnn_d/decode_speecon-test_test_varikn.bpe1750.d0.0001/wer_8_0.0
%WER 23.73 [ 1313 / 5533, 136 ins, 330 del, 847 sub ] exp/andre_comparison/chain/tdnn_d/decode_speecon-test_test_parl_20M_varikn.bpe19000.d0.0001/wer_9_0.0
%WER 21.60 [ 1195 / 5533, 138 ins, 290 del, 767 sub ] exp/andre_comparison/chain/tdnn_d/decode_speecon-test_test_parl_30M_varikn.bpe19000.d0.0001/wer_8_0.0
%WER 14.37 [ 795 / 5533, 71 ins, 243 del, 481 sub ] exp/andre_comparison/chain/tdnn_d/decode_speecon-test_test_5gram-kielipankki.bpe19000.d0.0001/wer_7_0.0
%WER 14.33 [ 793 / 5533, 70 ins, 243 del, 480 sub ] exp/andre_comparison/chain/tdnn_d/decode_speecon-test_test_kielipankki.bpe19000.d0.0001_rescore/wer_7_0.0
%WER 22.84 [ 1264 / 5533, 135 ins, 302 del, 827 sub ] exp/andre_comparison/chain/tdnn_d/decode_speecon-test_test_parl-train-unfiltered_varikn.bpe1750.d0.0001/wer_7_1.0
%WER 22.43 [ 1241 / 5533, 135 ins, 282 del, 824 sub ] exp/combined_comparison/chain/tdnn_d/decode_speecon-test_test_parl_20M_varikn.bpe19000.d0.0001/wer_8_0.0
%WER 20.42 [ 1130 / 5533, 121 ins, 283 del, 726 sub ] exp/combined_comparison/chain/tdnn_d/decode_speecon-test_test_parl_30M_varikn.bpe19000.d0.0001/wer_8_0.5
%WER 13.79 [ 763 / 5533, 80 ins, 241 del, 442 sub ] exp/combined_comparison/chain/tdnn_d/decode_speecon-test_test_5gram-kielipankki.bpe19000.d0.0001/wer_7_0.0
%WER 13.83 [ 765 / 5533, 81 ins, 241 del, 443 sub ] exp/combined_comparison/chain/tdnn_d/decode_speecon-test_test_kielipankki.bpe19000.d0.0001_rescore/wer_7_0.0
%WER 20.93 [ 1158 / 5533, 135 ins, 272 del, 751 sub ] exp/combined_comparison/chain/tdnn_d/decode_speecon-test_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001/wer_8_0.0
%CER 5.69 [ 2364 / 41575, 587 ins, 858 del, 919 sub ] exp/i/tri4j/decode_speecon-test_test_parl_20M_varikn.bpe19000.d0.0001/cer_13_0.0
%CER 4.22 [ 1754 / 41575, 695 ins, 499 del, 560 sub ] exp/chain/tdnn_blstm_a_multigpu/decode_speecon-test_test_parl_20M_varikn.bpe19000.d0.0001/cer_6_0.0
%CER 3.88 [ 1613 / 41575, 570 ins, 459 del, 584 sub ] exp/chain/tdnn_d/decode_speecon-test_test_parl_20M_varikn.bpe19000.d0.0001/cer_7_0.0
%CER 3.62 [ 1503 / 41575, 540 ins, 423 del, 540 sub ] exp/chain/tdnn_d/decode_speecon-test_test_parl_30M_varikn.bpe19000.d0.0001/cer_6_0.0
%CER 2.53 [ 1053 / 41575, 315 ins, 355 del, 383 sub ] exp/chain/tdnn_d/decode_speecon-test_test_5gram-kielipankki.bpe19000.d0.0001/cer_6_0.0
%CER 2.52 [ 1049 / 41575, 311 ins, 356 del, 382 sub ] exp/chain/tdnn_d/decode_speecon-test_test_kielipankki.bpe19000.d0.0001_rescore/cer_6_0.0
%CER 3.75 [ 1561 / 41575, 491 ins, 478 del, 592 sub ] exp/chain/tdnn_d/decode_speecon-test_test_varikn.bpe1750.d0.0001/cer_6_0.5
%CER 4.05 [ 1683 / 41575, 553 ins, 551 del, 579 sub ] exp/andre_comparison/chain/tdnn_d/decode_speecon-test_test_parl_20M_varikn.bpe19000.d0.0001/cer_7_0.5
%CER 3.79 [ 1577 / 41575, 512 ins, 526 del, 539 sub ] exp/andre_comparison/chain/tdnn_d/decode_speecon-test_test_parl_30M_varikn.bpe19000.d0.0001/cer_7_0.5
%CER 2.82 [ 1173 / 41575, 363 ins, 376 del, 434 sub ] exp/andre_comparison/chain/tdnn_d/decode_speecon-test_test_5gram-kielipankki.bpe19000.d0.0001/cer_6_0.0
%CER 2.73 [ 1133 / 41575, 313 ins, 395 del, 425 sub ] exp/andre_comparison/chain/tdnn_d/decode_speecon-test_test_kielipankki.bpe19000.d0.0001_rescore/cer_6_0.5
%CER 3.97 [ 1652 / 41575, 436 ins, 614 del, 602 sub ] exp/andre_comparison/chain/tdnn_d/decode_speecon-test_test_parl-train-unfiltered_varikn.bpe1750.d0.0001/cer_7_1.0
%CER 4.06 [ 1687 / 41575, 655 ins, 451 del, 581 sub ] exp/combined_comparison/chain/tdnn_d/decode_speecon-test_test_parl_20M_varikn.bpe19000.d0.0001/cer_7_0.0
%CER 3.58 [ 1488 / 41575, 549 ins, 414 del, 525 sub ] exp/combined_comparison/chain/tdnn_d/decode_speecon-test_test_parl_30M_varikn.bpe19000.d0.0001/cer_6_1.0
%CER 2.38 [ 989 / 41575, 317 ins, 361 del, 311 sub ] exp/combined_comparison/chain/tdnn_d/decode_speecon-test_test_5gram-kielipankki.bpe19000.d0.0001/cer_6_0.5
%CER 2.42 [ 1005 / 41575, 342 ins, 350 del, 313 sub ] exp/combined_comparison/chain/tdnn_d/decode_speecon-test_test_kielipankki.bpe19000.d0.0001_rescore/cer_6_0.0
%CER 3.56 [ 1479 / 41575, 458 ins, 492 del, 529 sub ] exp/combined_comparison/chain/tdnn_d/decode_speecon-test_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001/cer_7_1.0
```

Yle test set.

```txt
%WER 38.03 [ 14022 / 36869, 1575 ins, 2700 del, 9747 sub ] exp/i/tri4j/decode_yle-test-new_test_parl_20M_varikn.bpe19000.d0.0001/wer_16_0.0
%WER 41.08 [ 15145 / 36869, 1934 ins, 2424 del, 10787 sub ] exp/i/tri4j/decode_yle-test-new_test_parl_20M_varikn.bpe19000.d0.0001.si/wer_14_0.0
%WER 25.54 [ 9418 / 36869, 920 ins, 1834 del, 6664 sub ] exp/chain/tdnn_blstm_a_multigpu/decode_yle-test-new_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_0.0
%WER 25.41 [ 9367 / 36869, 1051 ins, 1712 del, 6604 sub ] exp/chain/tdnn_d/decode_yle-test-new_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_0.0
%WER 24.89 [ 9177 / 36869, 1056 ins, 1788 del, 6333 sub ] exp/chain/tdnn_d/decode_yle-test-new_test_parl_30M_varikn.bpe19000.d0.0001/wer_8_0.0
%WER 18.10 [ 6674 / 36869, 805 ins, 1295 del, 4574 sub ] exp/chain/tdnn_d/decode_yle-test-new_test_5gram-kielipankki.bpe19000.d0.0001/wer_6_0.0
%WER 18.07 [ 6663 / 36869, 805 ins, 1302 del, 4556 sub ] exp/chain/tdnn_d/decode_yle-test-new_test_kielipankki.bpe19000.d0.0001_rescore/wer_6_0.0
%WER 26.15 [ 9643 / 36869, 1137 ins, 1837 del, 6669 sub ] exp/chain/tdnn_d/decode_yle-test-new_test_varikn.bpe1750.d0.0001/wer_8_0.0
%WER 27.59 [ 10171 / 36869, 950 ins, 2431 del, 6790 sub ] exp/andre_comparison/chain/tdnn_d/decode_yle-test-new_test_parl_20M_varikn.bpe19000.d0.0001/wer_9_0.0
%WER 26.04 [ 9601 / 36869, 1051 ins, 2010 del, 6540 sub ] exp/andre_comparison/chain/tdnn_d/decode_yle-test-new_test_parl_30M_varikn.bpe19000.d0.0001/wer_8_0.0
%WER 17.63 [ 6500 / 36869, 580 ins, 1536 del, 4384 sub ] exp/andre_comparison/chain/tdnn_d/decode_yle-test-new_test_5gram-kielipankki.bpe19000.d0.0001/wer_7_0.0
%WER 17.61 [ 6493 / 36869, 577 ins, 1540 del, 4376 sub ] exp/andre_comparison/chain/tdnn_d/decode_yle-test-new_test_kielipankki.bpe19000.d0.0001_rescore/wer_7_0.0
%WER 27.58 [ 10169 / 36869, 1050 ins, 2140 del, 6979 sub ] exp/andre_comparison/chain/tdnn_d/decode_yle-test-new_test_parl-train-unfiltered_varikn.bpe1750.d0.0001/wer_7_1.0
%WER 25.49 [ 9397 / 36869, 1013 ins, 1719 del, 6665 sub ] exp/combined_comparison/chain/tdnn_d/decode_yle-test-new_test_parl_20M_varikn.bpe19000.d0.0001/wer_8_0.0
%WER 24.67 [ 9096 / 36869, 1046 ins, 1809 del, 6241 sub ] exp/combined_comparison/chain/tdnn_d/decode_yle-test-new_test_parl_30M_varikn.bpe19000.d0.0001/wer_8_0.5
%WER 17.07 [ 6293 / 36869, 751 ins, 1307 del, 4235 sub ] exp/combined_comparison/chain/tdnn_d/decode_yle-test-new_test_5gram-kielipankki.bpe19000.d0.0001/wer_7_0.0
%WER 17.04 [ 6282 / 36869, 746 ins, 1306 del, 4230 sub ] exp/combined_comparison/chain/tdnn_d/decode_yle-test-new_test_kielipankki.bpe19000.d0.0001_rescore/wer_7_0.0
%WER 24.70 [ 9106 / 36869, 1131 ins, 1654 del, 6321 sub ] exp/combined_comparison/chain/tdnn_d/decode_yle-test-new_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001/wer_8_0.0
%CER 11.15 [ 30042 / 269449, 8022 ins, 10031 del, 11989 sub ] exp/i/tri4j/decode_yle-test-new_test_parl_20M_varikn.bpe19000.d0.0001/cer_13_0.0
%CER 6.89 [ 18569 / 269449, 7616 ins, 5020 del, 5933 sub ] exp/chain/tdnn_blstm_a_multigpu/decode_yle-test-new_test_parl_20M_varikn.bpe19000.d0.0001/cer_6_0.0
%CER 6.35 [ 17116 / 269449, 7000 ins, 4340 del, 5776 sub ] exp/chain/tdnn_d/decode_yle-test-new_test_parl_20M_varikn.bpe19000.d0.0001/cer_7_0.0
%CER 6.34 [ 17074 / 269449, 7863 ins, 3703 del, 5508 sub ] exp/chain/tdnn_d/decode_yle-test-new_test_parl_30M_varikn.bpe19000.d0.0001/cer_6_0.0
%CER 4.99 [ 13439 / 269449, 5949 ins, 3329 del, 4161 sub ] exp/chain/tdnn_d/decode_yle-test-new_test_5gram-kielipankki.bpe19000.d0.0001/cer_6_0.0
%CER 4.98 [ 13423 / 269449, 5932 ins, 3349 del, 4142 sub ] exp/chain/tdnn_d/decode_yle-test-new_test_kielipankki.bpe19000.d0.0001_rescore/cer_6_0.0
%CER 6.41 [ 17280 / 269449, 7361 ins, 4052 del, 5867 sub ] exp/chain/tdnn_d/decode_yle-test-new_test_varikn.bpe1750.d0.0001/cer_6_0.5
%CER 6.97 [ 18785 / 269449, 7292 ins, 5252 del, 6241 sub ] exp/andre_comparison/chain/tdnn_d/decode_yle-test-new_test_parl_20M_varikn.bpe19000.d0.0001/cer_7_0.5
%CER 6.75 [ 18176 / 269449, 7015 ins, 5175 del, 5986 sub ] exp/andre_comparison/chain/tdnn_d/decode_yle-test-new_test_parl_30M_varikn.bpe19000.d0.0001/cer_7_0.5
%CER 4.92 [ 13255 / 269449, 5489 ins, 3438 del, 4328 sub ] exp/andre_comparison/chain/tdnn_d/decode_yle-test-new_test_5gram-kielipankki.bpe19000.d0.0001/cer_6_0.0
%CER 4.86 [ 13102 / 269449, 5152 ins, 3693 del, 4257 sub ] exp/andre_comparison/chain/tdnn_d/decode_yle-test-new_test_kielipankki.bpe19000.d0.0001_rescore/cer_6_0.5
%CER 6.77 [ 18250 / 269449, 5731 ins, 6406 del, 6113 sub ] exp/andre_comparison/chain/tdnn_d/decode_yle-test-new_test_parl-train-unfiltered_varikn.bpe1750.d0.0001/cer_7_1.0
%CER 6.31 [ 17004 / 269449, 7341 ins, 3892 del, 5771 sub ] exp/combined_comparison/chain/tdnn_d/decode_yle-test-new_test_parl_20M_varikn.bpe19000.d0.0001/cer_7_0.0
%CER 6.23 [ 16774 / 269449, 7486 ins, 3826 del, 5462 sub ] exp/combined_comparison/chain/tdnn_d/decode_yle-test-new_test_parl_30M_varikn.bpe19000.d0.0001/cer_6_1.0
%CER 4.91 [ 13223 / 269449, 6038 ins, 3170 del, 4015 sub ] exp/combined_comparison/chain/tdnn_d/decode_yle-test-new_test_5gram-kielipankki.bpe19000.d0.0001/cer_6_0.5
%CER 4.94 [ 13323 / 269449, 6357 ins, 2891 del, 4075 sub ] exp/combined_comparison/chain/tdnn_d/decode_yle-test-new_test_kielipankki.bpe19000.d0.0001_rescore/cer_6_0.0
%CER 6.15 [ 16570 / 269449, 6235 ins, 4806 del, 5529 sub ] exp/combined_comparison/chain/tdnn_d/decode_yle-test-new_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001/cer_7_1.0
```

---

### 1.2.6. Development set result comparison

Comparison of models with different acoustic model training datasets using 20M indomain corpus LM.
In the _"Eduskunta2017 André's cleanup"_ column, we use a version of the Eduskunta2017 data that
André/Peter had cleaned previously and train with it from the beginning. In contrast, the last two
rows in the table (with cleaned AMs) refer to the more common Kaldi practice of cleaning the
original data with the best GMM model (tri4) trained on that original data. The clean data is then
used to train the best GMM and TDNN model again. The latter approach is better for reproducibility
when _only_ the original data is published because it allows others to replicate the clean up procedure.

| Acoustic model                  | Eduskunta2021 | Eduskunta2017 | Eduskunta2017 André's cleanup | Combined |
| ------------------------------- | ------------- | ------------- | ----------------------------- | -------- |
| Monophone GMM (mono)            | 56.24         | 69.87         | 55.16                         | 61.29    |
| Delta+delta-delta GMM (tri1)    | 21.56         | 21.43         | 21.16                         | 21.34    |
| LDA+MLLT GMM (tri2)             | 17.83         | 17.72         | 17.70                         | 17.63    |
| LDA+MLLT+SAT GMM (tri3)         | 16.70         | 16.77         | 16.71                         | 16.41    |
| LDA+MLLT+SAT GMM (tri4)         | 14.34         | 14.42         | 14.05                         | 14.09    |
| TDNN-d                          | 9.98          | 10.34         | 8.35                          | 10.28    |
| TDNN-BLSTM                      | 10.66         | -             | -                             | 10.54    |
| LDA+MLLT+SAT GMM (tri4) cleaned | 14.31         | 14.22         | -                             | -        |
| TDNN-d cleaned                  | 9.37          | 8.49          | -                             | -        |

Next is a comparison of language models made from the transcripts of acoustic model training data
versus 20M indomain corpus.

Acoustic models trained with Eduskunta2021:

| Acoustic model        | Eduskunta2021 LM | 20M indomain LM |
| --------------------- | ---------------- | --------------- |
| Monophone GMM         | 65.54            | 56.24           |
| Delta+delta-delta GMM | 30.93            | 21.56           |
| LDA+MLLT GMM          | 25.99            | 17.83           |
| LDA+MLLT+SAT GMM      | 24.28            | 16.70           |
| LDA+MLLT+SAT GMM      | 21.12            | 14.34           |
| TDNN-d                | 14.19            | 9.98            |

Acoustic models trained with Eduskunta2017:

| Acoustic model        | Eduskunta2017 LM | 20M indomain LM |
| --------------------- | ---------------- | --------------- |
| Monophone GMM         | 76.23            | 69.87           |
| Delta+delta-delta GMM | 29.99            | 21.43           |
| LDA+MLLT GMM          | 25.25            | 17.72           |
| LDA+MLLT+SAT GMM      | 23.56            | 16.77           |
| LDA+MLLT+SAT GMM      | 20.94            | 14.42           |
| TDNN-d                | 13.97            | 10.34           |

Acoustic models trained with combined parliament data:

| Acoustic model        | Combined data LM | 20M indomain LM |
| --------------------- | ---------------- | --------------- |
| Monophone GMM         | 69.17            | 61.29           |
| Delta+delta-delta GMM | 28.43            | 21.34           |
| LDA+MLLT GMM          | 23.77            | 17.63           |
| LDA+MLLT+SAT GMM      | 22.20            | 16.41           |
| LDA+MLLT+SAT GMM      | 19.11            | 14.09           |
| TDNN-d                | 13.08            | 10.28           |

---

### 1.2.7. Evaluation set comparison tables

Multiple result tables for different evaluation sets. All results are given as WER / CER.

[André's paper](https://acris.aalto.fi/ws/portalfiles/portal/15742470/mansikkamaki_interspeech1115.pdf) for comparison.

Different test sets evaluated on Eduskunta2021 AMs and the in-domain 20M token LM.

| Test set              | Best HMM-GMM  | TDNN-d        | TDNN-BLSTM    |
| --------------------- | ------------- | ------------- | ------------- |
| Parl-test-seen 2017   | 10.55 / 3.71  | 7.64 / 2.78   | 8.25 / 3.06   |
| Parl-test-unseen 2017 | 8.86 / 3.35   | 6.26 / 2.53   | 6.52 / 2.65   |
| Parl-test-all 2017    | 9.72 / 3.53   | 6.97 / 2.66   | 7.40 / 2.86   |
| Parl-test 2021        | 17.53 / 4.18  | 9.83 / 2.54   | 10.32 / 2.81  |
| Lahjoita puhetta      | 73.48 / 40.43 | 66.59 / 33.73 | 71.13 / 41.56 |
| Speecon-test          | 30.00 / 5.69  | 22.19 / 3.88  | 21.76 / 4.22  |
| Yle-test              | 38.03 / 11.15 | 25.41 / 6.35  | 25.54 / 6.89  |

Different test sets evaluated on the three TDNN-d acoustic models and 20M token LM.

| Test set              | Eduskunta2021 | Eduskunta2017 | Combined      |
| --------------------- | ------------- | ------------- | ------------- |
| Parl-test-seen 2017   | 7.64 / 2.78   | 8.42 / 3.81   | 7.58 / 3.17   |
| Parl-test-unseen 2017 | 6.26 / 2.53   | 7.22 / 3.38   | 6.67 / 2.94   |
| Parl-test-all 2017    | 6.97 / 2.66   | 7.83 / 3.60   | 7.14 / 3.06   |
| Parl-test 2021        | 9.83 / 2.54   | 14.97 / 5.13  | 10.67 / 2.65  |
| Lahjoita puhetta      | 66.59 / 33.73 | 68.85 / 36.37 | 65.48 / 32.12 |
| Speecon-test          | 22.19 / 3.88  | 23.73 / 4.05  | 22.43 / 4.06  |
| Yle-test              | 25.41 / 6.35  | 27.59 / 6.97  | 25.49 / 6.31  |

Different test sets evaluated on two TDNN-d acoustic models and 30M token LM.

| Test set              | Eduskunta2021 | Eduskunta2017 | Combined      |
| --------------------- | ------------- | ------------- | ------------- |
| Parl-test-seen 2017   | 7.71 / 2.73   | 8.41 / 3.89   | 7.66 / 3.22   |
| Parl-test-unseen 2017 | 6.37 / 2.53   | 7.10 / 3.43   | 6.62 / 2.91   |
| Parl-test-all 2017    | 7.05 / 2.63   | 7.77 / 3.66   | 7.15 / 3.07   |
| Parl-test 2021        | 9.34 / 2.27   | 13.17 / 4.81  | 9.73 / 2.39   |
| Lahjoita puhetta      | 66.20 / 32.89 | 67.26 / 36.07 | 65.16 / 31.60 |
| Speecon-test          | 21.71 / 3.62  | 21.60 / 3.79  | 20.42 / 3.58  |
| Yle-test              | 24.89 / 6.34  | 26.04 / 6.75  | 24.67 / 6.23  |

Different test sets evaluated on the three TDNN-d acoustic models and Kielipankki 5-gram LM.

| Test set              | Eduskunta2021 | Eduskunta2017 | Combined      |
| --------------------- | ------------- | ------------- | ------------- |
| Parl-test-seen 2017   | 11.69 / 3.55  | 12.29 / 4.70  | 11.26 / 3.91  |
| Parl-test-unseen 2017 | 10.06 / 3.26  | 11.19 / 4.45  | 9.90 / 3.64   |
| Parl-test-all 2017    | 10.89 / 3.41  | 11.75 / 4.57  | 10.59 / 3.78  |
| Parl-test 2021        | 9.59 / 2.50   | 13.91 / 4.72  | 10.12 / 2.63  |
| Lahjoita puhetta      | 64.86 / 31.84 | 64.75 / 32.78 | 62.80 / 30.42 |
| Speecon-test          | 14.78 / 2.53  | 14.37 / 2.82  | 13.79 / 2.38  |
| Yle-test              | 18.10 / 4.99  | 17.63 / 4.92  | 17.07 / 4.91  |

Different test sets evaluated on the three TDNN-d acoustic models and rescored Kielipankki 10-gram LM.

| Test set              | Eduskunta2021 | Eduskunta2017 | Combined      |
| --------------------- | ------------- | ------------- | ------------- |
| Parl-test-seen 2017   | 11.73 / 3.56  | 12.33 / 4.61  | 11.25 / 3.93  |
| Parl-test-unseen 2017 | 10.07 / 3.27  | 11.19 / 4.37  | 9.93 / 3.71   |
| Parl-test-all 2017    | 10.92 / 3.41  | 11.77 / 4.49  | 10.60 / 3.82  |
| Parl-test 2021        | 9.59 / 2.50   | 13.89 / 4.56  | 10.12 / 2.60  |
| Lahjoita puhetta      | 64.85 / 31.82 | 64.73 / 33.02 | 62.79 / 30.36 |
| Speecon-test          | 14.78 / 2.52  | 14.33 / 2.73  | 13.83 / 2.42  |
| Yle-test              | 18.07 / 4.98  | 17.61 / 4.86  | 17.04 / 4.94  |

Parliament test sets evaluated on the three TDNN-d acoustic models and their matching transcript LMs.

| Test set              | Eduskunta2021 | Eduskunta2017 | Combined      |
| --------------------- | ------------- | ------------- | ------------- |
| Parl-test-seen 2017   | 11.31 / 3.45  | 11.46 / 4.25  | 10.32 / 3.54  |
| Parl-test-unseen 2017 | 9.70 / 3.16   | 10.86 / 4.02  | 9.32 / 3.19   |
| Parl-test-all 2017    | 10.52 / 3.31  | 11.17 / 4.14  | 9.83 / 3.37   |
| Parl-test 2021        | 8.84 / 2.19   | 13.90 / 4.28  | 8.76 / 2.29   |
| Lahjoita puhetta      | 66.90 / 32.97 | 68.41 / 37.42 | 64.99 / 32.62 |
| Speecon-test          | 22.12 / 3.75  | 22.84 / 3.97  | 20.93 / 3.56  |
| Yle-test              | 26.15 / 6.41  | 27.58 / 6.77  | 24.70 / 6.15  |

Different test sets evaluated on the Eduskunta2021 TDNN-d acoustic model and different LMs.

| Test set              | 20M token     | 30M token     | Transcript    | Kpankki 5-gram | Kpankki 10-gram |
| --------------------- | ------------- | ------------- | ------------- | -------------- | --------------- |
| Parl-test-seen 2017   | 7.64 / 2.78   | 7.71 / 2.73   | 11.31 / 3.45  | 11.69 / 3.55   | 11.73 / 3.56    |
| Parl-test-unseen 2017 | 6.26 / 2.53   | 6.37 / 2.53   | 9.70 /  3.16  | 10.06 / 3.26   | 10.07 / 3.27    |
| Parl-test-all 2017    | 6.97 / 2.66   | 7.05 / 2.63   | 10.52 / 3.31  | 10.89 / 3.41   | 10.92 / 3.41    |
| Parl-test 2021        | 9.83 / 2.54   | 9.34 / 2.27   | 8.84 /  2.19  | 9.59 / 2.50    | 9.59 / 2.50     |
| Lahjoita puhetta      | 66.59 / 33.73 | 66.20 / 32.89 | 66.90 / 32.97 | 64.86 / 31.84  | 64.85 / 31.82   |
| Speecon-test          | 22.19 / 3.88  | 21.71 / 3.62  | 22.12 / 3.75  | 14.78 / 2.53   | 14.78 / 2.52    |
| Yle-test              | 25.41 / 6.35  | 24.89 / 6.34  | 26.15 / 6.41  | 18.10 / 4.99   | 18.07 / 4.98    |

Different test sets evaluated with end-to-end models and matched-data HMM system (TDNN-D):

| Test set              | HMM/TDNN 2021 | HMM/TDNN 2017 | HMM/TDNN Comb | CRDNN/E2E 2021 | CRDNN/E2E 2017 | CRDNN/E2E Comb |
| --------------------- | ------------- | ------------- | ------------- | -------------- | -------------- | -------------- |
| Parl-test-seen 2017   | 11.31 / 3.45  | 11.46 / 4.25  | 10.32 / 3.54  | 13.32 / 5.47   | 12.60 / 5.88   | 10.81 / 4.26   |
| Parl-test-unseen 2017 | 9.70 / 3.16   | 10.86 / 4.02  | 9.32 / 3.19   | 12.02 / 5.05   | 11.95 / 5.48   | 10.57 / 4.39   |
| Parl-test-all 2017    | 10.52 / 3.31  | 11.17 / 4.14  | 9.83 / 3.37   | 12.68 / 5.26   | 12.28 / 5.68   | 10.69 / 4.33   |
| Parl-test 2021        | 8.84 / 2.19   | 13.90 / 4.28  | 8.76 / 2.29   | 10.30 / 3.10   | 14.80 / 4.81   | 10.15 / 3.01   |
| Lahjoita puhetta      | 66.90 / 32.97 | -             | -             | 90.06 / 80.15  | -              | -              |
| Speecon-test          | 22.12 / 3.75  | -             | -             | 25.14 / 5.66   | -              | -              |
| Yle-test              | 26.15 / 6.41  | -             | -             | 28.99 / 8.19   | -              | -              |
