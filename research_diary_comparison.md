# 1. Experiments comparing different parliament data combinations

- [1. Experiments comparing different parliament data combinations](#1-experiments-comparing-different-parliament-data-combinations)
  - [1.1. Datasets](#11-datasets)
    - [1.1.1. Dataset sizes](#111-dataset-sizes)
  - [1.2. Results](#12-results)
    - [1.2.1. Old parliament](#121-old-parliament)
    - [1.2.2. Old parliament cleaned](#122-old-parliament-cleaned)
    - [1.2.3. New parliament](#123-new-parliament)
    - [1.2.4. Combined](#124-combined)
    - [Test set evaluations](#test-set-evaluations)
    - [1.2.5. Comparison tables (WER)](#125-comparison-tables-wer)

## 1.1. Datasets

We use four parliament datasets in our comparison experiments. From the old parliament data, we use both
'uncleaned' and cleaned versions. This is because André published his results on the cleaned data, but
the new, **published** (in Kielipankki), parliament data is 'uncleaned'. To see how much the cleaning
procedure affects the results, we did experiments on both versions. The cleaning procedure in this case
refers to Kaldi's `steps/cleanup/clean_and_segment_data_nnet3.sh` script.

There is a cleaned version of the new parliament data too (cleaned with Peter's model), but no experiments
done using it yet. We are also considering using the best HMM-GMM to clean the new data, because that would
make our Kaldi recipes replicable and self-contained. André also cleaned his data with Kaldi using a
HMM-GMM:

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
%WER 76.23 [ 27207 / 35693, 943 ins, 7297 del, 18967 sub ] exp/andre_comparison/i/mono/decode_parl-dev-all_test_parl-train-unfiltered_varikn.bpe1750.d0.0001/wer_7_0.0
%WER 29.99 [ 10706 / 35693, 980 ins, 2980 del, 6746 sub ] exp/andre_comparison/i/tri1a/decode_parl-dev-all_test_parl-train-unfiltered_varikn.bpe1750.d0.0001/wer_13_0.0
%WER 25.25 [ 9014 / 35693, 962 ins, 2333 del, 5719 sub ] exp/andre_comparison/i/tri2a/decode_parl-dev-all_test_parl-train-unfiltered_varikn.bpe1750.d0.0001/wer_14_0.0
%WER 23.56 [ 8408 / 35693, 942 ins, 2138 del, 5328 sub ] exp/andre_comparison/i/tri3a/decode_parl-dev-all_test_parl-train-unfiltered_varikn.bpe1750.d0.0001/wer_15_0.0
%WER 26.46 [ 9445 / 35693, 993 ins, 2333 del, 6119 sub ] exp/andre_comparison/i/tri3a/decode_parl-dev-all_test_parl-train-unfiltered_varikn.bpe1750.d0.0001.si/wer_15_0.0
%WER 20.94 [ 7473 / 35693, 997 ins, 1792 del, 4684 sub ] exp/andre_comparison/i/tri4j/decode_parl-dev-all_test_parl-train-unfiltered_varikn.bpe1750.d0.0001/wer_14_0.0
%WER 23.33 [ 8328 / 35693, 1013 ins, 1940 del, 5375 sub ] exp/andre_comparison/i/tri4j/decode_parl-dev-all_test_parl-train-unfiltered_varikn.bpe1750.d0.0001.si/wer_14_0.0
%WER 13.97 [ 4986 / 35693, 778 ins, 1349 del, 2859 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl-dev-all_test_parl-train-unfiltered_varikn.bpe1750.d0.0001/wer_7_1.0
```

### 1.2.2. Old parliament cleaned

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
%WER 9.37 [ 3345 / 35693, 487 ins, 1059 del, 1799 sub ] exp/chain/tdnn_d_cleaned/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_9_0.0
%WER 65.54 [ 23392 / 35693, 781 ins, 7258 del, 15353 sub ] exp/i/mono/decode_parl-dev-all_test_varikn.bpe1750.d0.0001/wer_8_0.0
%WER 30.93 [ 11039 / 35693, 1067 ins, 2741 del, 7231 sub ] exp/i/tri1a/decode_parl-dev-all_test_varikn.bpe1750.d0.0001/wer_13_0.0
%WER 25.99 [ 9277 / 35693, 968 ins, 2319 del, 5990 sub ] exp/i/tri2a/decode_parl-dev-all_test_varikn.bpe1750.d0.0001/wer_15_0.0
%WER 24.28 [ 8666 / 35693, 1070 ins, 2039 del, 5557 sub ] exp/i/tri3a/decode_parl-dev-all_test_varikn.bpe1750.d0.0001/wer_15_0.0
%WER 27.37 [ 9770 / 35693, 1100 ins, 2259 del, 6411 sub ] exp/i/tri3a/decode_parl-dev-all_test_varikn.bpe1750.d0.0001.si/wer_13_0.0
%WER 21.12 [ 7538 / 35693, 1074 ins, 1741 del, 4723 sub ] exp/i/tri4j/decode_parl-dev-all_test_varikn.bpe1750.d0.0001/wer_14_0.0
%WER 23.86 [ 8517 / 35693, 1123 ins, 1906 del, 5488 sub ] exp/i/tri4j/decode_parl-dev-all_test_varikn.bpe1750.d0.0001.si/wer_13_0.0
%WER 14.19 [ 5066 / 35693, 661 ins, 1413 del, 2992 sub ] exp/chain/tdnn_d/decode_parl-dev-all_test_varikn.bpe1750.d0.0001/wer_8_0.0
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
%WER 10.54 [ 3761 / 35693, 804 ins, 1115 del, 1842 sub ] exp/combined_comparison/chain/tdnn_blstm_a_multigpu/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_0.0
%WER 69.17 [ 24688 / 35693, 939 ins, 6999 del, 16750 sub ] exp/combined_comparison/i/mono/decode_parl-dev-all_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001/wer_8_0.0
%WER 28.43 [ 10148 / 35693, 1023 ins, 2626 del, 6499 sub ] exp/combined_comparison/i/tri1a/decode_parl-dev-all_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001/wer_13_0.0
%WER 23.77 [ 8484 / 35693, 930 ins, 2104 del, 5450 sub ] exp/combined_comparison/i/tri2a/decode_parl-dev-all_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001/wer_14_0.0
%WER 22.20 [ 7924 / 35693, 949 ins, 1958 del, 5017 sub ] exp/combined_comparison/i/tri3a/decode_parl-dev-all_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001/wer_15_0.0
%WER 25.89 [ 9242 / 35693, 1090 ins, 2196 del, 5956 sub ] exp/combined_comparison/i/tri3a/decode_parl-dev-all_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001.si/wer_13_0.0
%WER 19.11 [ 6822 / 35693, 969 ins, 1590 del, 4263 sub ] exp/combined_comparison/i/tri4j/decode_parl-dev-all_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001/wer_15_0.0
%WER 22.11 [ 7892 / 35693, 1045 ins, 1844 del, 5003 sub ] exp/combined_comparison/i/tri4j/decode_parl-dev-all_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001.si/wer_14_0.0
%WER 13.08 [ 4668 / 35693, 781 ins, 1142 del, 2745 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-dev-all_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001/wer_8_0.0
```

### Test set evaluations

Parliament2017 test set, unseen and seen splits. Unseen and seen speaker splits do not apply for the new eduskunta2021 set.

```txt
# Seen
%WER 10.53 [ 1883 / 17881, 312 ins, 426 del, 1145 sub ] exp/i/tri4j/decode_parl-test-seen_test_parl_20M_varikn.bpe19000.d0.0001/wer_15_0.0
%WER 12.63 [ 2259 / 17881, 367 ins, 470 del, 1422 sub ] exp/i/tri4j/decode_parl-test-seen_test_parl_20M_varikn.bpe19000.d0.0001.si/wer_13_0.0
%WER 8.25 [ 1475 / 17881, 183 ins, 539 del, 753 sub ] exp/chain/tdnn_blstm_a_multigpu/decode_parl-test-seen_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_0.0
%WER 7.64 [ 1367 / 17881, 181 ins, 420 del, 766 sub ] exp/chain/tdnn_d/decode_parl-test-seen_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_0.0
%WER 7.70 [ 1376 / 17881, 187 ins, 416 del, 773 sub ] exp/chain/tdnn_d/decode_parl-test-seen_test_parl_30M_varikn.bpe19000.d0.0001/wer_7_0.0
%WER 11.69 [ 2090 / 17881, 220 ins, 628 del, 1242 sub ] exp/chain/tdnn_d/decode_parl-test-seen_test_5gram-kielipankki.bpe19000.d0.0001/wer_7_0.0
%WER 11.31 [ 2022 / 17881, 254 ins, 528 del, 1240 sub ] exp/chain/tdnn_d/decode_parl-test-seen_test_varikn.bpe1750.d0.0001/wer_8_0.0
%WER 8.32 [ 1488 / 17881, 377 ins, 368 del, 743 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl-test-seen_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_0.5
%WER 8.41 [ 1503 / 17881, 366 ins, 402 del, 735 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl-test-seen_test_parl_30M_varikn.bpe19000.d0.0001/wer_8_0.0
%WER 12.29 [ 2197 / 17881, 402 ins, 556 del, 1239 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl-test-seen_test_5gram-kielipankki.bpe19000.d0.0001/wer_7_0.0
%WER 11.46 [ 2050 / 17881, 395 ins, 479 del, 1176 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl-test-seen_test_parl-train-unfiltered_varikn.bpe1750.d0.0001/wer_7_1.0
%WER 7.57 [ 1354 / 17881, 276 ins, 402 del, 676 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-test-seen_test_parl_20M_varikn.bpe19000.d0.0001/wer_8_0.5
%WER 7.66 [ 1369 / 17881, 313 ins, 324 del, 732 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-test-seen_test_parl_30M_varikn.bpe19000.d0.0001/wer_7_0.5
%WER 11.21 [ 2005 / 17881, 277 ins, 557 del, 1171 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-test-seen_test_5gram-kielipankki.bpe19000.d0.0001/wer_7_0.5
%WER 10.11 [ 1808 / 17881, 361 ins, 363 del, 1084 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-test-seen_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001/wer_7_0.5
# Unseen
%WER 8.82 [ 1522 / 17261, 310 ins, 315 del, 897 sub ] exp/i/tri4j/decode_parl-test-unseen_test_parl_20M_varikn.bpe19000.d0.0001/wer_15_0.0
%WER 10.45 [ 1803 / 17261, 346 ins, 340 del, 1117 sub ] exp/i/tri4j/decode_parl-test-unseen_test_parl_20M_varikn.bpe19000.d0.0001.si/wer_13_0.0
%WER 6.52 [ 1125 / 17261, 170 ins, 369 del, 586 sub ] exp/chain/tdnn_blstm_a_multigpu/decode_parl-test-unseen_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_0.0
%WER 6.26 [ 1081 / 17261, 164 ins, 313 del, 604 sub ] exp/chain/tdnn_d/decode_parl-test-unseen_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_0.0
%WER 6.24 [ 1077 / 17261, 167 ins, 313 del, 597 sub ] exp/chain/tdnn_d/decode_parl-test-unseen_test_parl_30M_varikn.bpe19000.d0.0001/wer_7_0.0
%WER 10.06 [ 1736 / 17261, 220 ins, 464 del, 1052 sub ] exp/chain/tdnn_d/decode_parl-test-unseen_test_5gram-kielipankki.bpe19000.d0.0001/wer_7_0.0
%WER 9.63 [ 1662 / 17261, 272 ins, 344 del, 1046 sub ] exp/chain/tdnn_d/decode_parl-test-unseen_test_varikn.bpe1750.d0.0001/wer_7_0.0
%WER 7.11 [ 1227 / 17261, 334 ins, 293 del, 600 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl-test-unseen_test_parl_20M_varikn.bpe19000.d0.0001/wer_8_0.0
%WER 7.09 [ 1224 / 17261, 288 ins, 352 del, 584 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl-test-unseen_test_parl_30M_varikn.bpe19000.d0.0001/wer_8_0.5
%WER 11.07 [ 1911 / 17261, 315 ins, 522 del, 1074 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl-test-unseen_test_5gram-kielipankki.bpe19000.d0.0001/wer_7_1.0
%WER 10.86 [ 1875 / 17261, 379 ins, 388 del, 1108 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl-test-unseen_test_parl-train-unfiltered_varikn.bpe1750.d0.0001/wer_7_1.0
%WER 6.62 [ 1143 / 17261, 252 ins, 338 del, 553 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-test-unseen_test_parl_20M_varikn.bpe19000.d0.0001/wer_9_0.0
%WER 6.62 [ 1142 / 17261, 257 ins, 336 del, 549 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-test-unseen_test_parl_30M_varikn.bpe19000.d0.0001/wer_8_0.5
%WER 9.90 [ 1708 / 17261, 282 ins, 406 del, 1020 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-test-unseen_test_5gram-kielipankki.bpe19000.d0.0001/wer_7_0.0
%WER 9.09 [ 1569 / 17261, 288 ins, 335 del, 946 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-test-unseen_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001/wer_7_1.0
# Parl-test-all 2017 (calculated by hand)
%WER 9.69 [ 3405 / 35142, 622 ins, 741 del, 2042 sub ] exp/i/tri4j + test_parl_20M_varikn.bpe19000.d0.0001
%WER 11.56 [ 4062 / 35142, 713 ins, 810 del, 2539 sub ] exp/i/tri4j + test_parl_20M_varikn.bpe19000.d0.0001.si
%WER 7.40 [ 2600 / 35142, 353 ins, 908 del, 1339 sub ] exp/chain/tdnn_blstm_a_multigpu + test_parl_20M_varikn.bpe19000.d0.0001
%WER 6.97 [ 2448 / 35142, 345 ins, 733 del, 1370 sub ] exp/chain/tdnn_d + test_parl_20M_varikn.bpe19000.d0.0001
%WER 6.98 [ 2453 / 35142, 354 ins, 729 del, 1370 sub ] exp/chain/tdnn_d + test_parl_30M_varikn.bpe19000.d0.0001
%WER 10.89 [ 3826 / 35142, 440 ins, 1092 del, 2294 sub ] exp/chain/tdnn_d + test_5gram-kielipankki.bpe19000.d0.0001
%WER 10.48 [ 3684 / 35142, 526 ins, 872 del, 2286 sub ] exp/chain/tdnn_d + test_varikn.bpe1750.d0.0001
%WER 7.73 [ 2715 / 35142, 711 ins, 661 del, 1343 sub ] exp/andre_comparison/chain/tdnn_d + test_parl_20M_varikn.bpe19000.d0.0001
%WER 7.76 [ 2727 / 35142, 654 ins, 754 del, 1319 sub ] exp/andre_comparison/chain/tdnn_d + test_parl_30M_varikn.bpe19000.d0.0001
%WER 11.69 [ 4108 / 35142, 717 ins, 1078 del, 2313 sub ] exp/andre_comparison/chain/tdnn_d + test_5gram-kielipankki.bpe19000.d0.0001
%WER 11.17 [ 3925 / 35142, 774 ins, 867 del, 2284 sub ] exp/andre_comparison/chain/tdnn_d + test_parl-train-unfiltered_varikn.bpe1750.d0.0001
%WER 7.11 [ 2497 / 35142, 528 ins, 740 del, 1229 sub ] exp/combined_comparison/chain/tdnn_d + test_parl_20M_varikn.bpe19000.d0.0001
%WER 7.15 [ 2511 / 35142, 570 ins, 660 del, 1281 sub ] exp/combined_comparison/chain/tdnn_d + test_parl_30M_varikn.bpe19000.d0.0001
%WER 10.57 [ 3713 / 35142, 559 ins, 963 del, 2191 sub ] exp/combined_comparison/chain/tdnn_d + test_5gram-kielipankki.bpe19000.d0.0001
%WER 9.61 [ 3377 / 35142, 649 ins, 698 del, 2030 sub ] exp/combined_comparison/chain/tdnn_d + test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001
```

Parliament2021 test set.

```txt
%WER 16.59 [ 4522 / 27261, 739 ins, 705 del, 3078 sub ] exp/i/tri4j/decode_parl2021-test_test_parl_20M_varikn.bpe19000.d0.0001/wer_11_1.0
%WER 19.95 [ 5438 / 27261, 889 ins, 792 del, 3757 sub ] exp/i/tri4j/decode_parl2021-test_test_parl_20M_varikn.bpe19000.d0.0001.si/wer_11_1.0
%WER 10.23 [ 2789 / 27261, 262 ins, 853 del, 1674 sub ] exp/chain/tdnn_blstm_a_multigpu/decode_parl2021-test_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_0.5
%WER 9.82 [ 2676 / 27261, 262 ins, 718 del, 1696 sub ] exp/chain/tdnn_d/decode_parl2021-test_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_0.5
%WER 8.95 [ 2440 / 27261, 257 ins, 641 del, 1542 sub ] exp/chain/tdnn_d/decode_parl2021-test_test_parl_30M_varikn.bpe19000.d0.0001/wer_7_0.0
%WER 9.71 [ 2647 / 27261, 249 ins, 795 del, 1603 sub ] exp/chain/tdnn_d/decode_parl2021-test_test_5gram-kielipankki.bpe19000.d0.0001/wer_7_0.0
%WER 8.73 [ 2380 / 27261, 259 ins, 544 del, 1577 sub ] exp/chain/tdnn_d/decode_parl2021-test_test_varikn.bpe1750.d0.0001/wer_7_0.5
%WER 13.96 [ 3805 / 27261, 701 ins, 1054 del, 2050 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl2021-test_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_1.0
%WER 12.59 [ 3433 / 27261, 615 ins, 1028 del, 1790 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl2021-test_test_parl_30M_varikn.bpe19000.d0.0001/wer_7_1.0
%WER 13.88 [ 3784 / 27261, 418 ins, 1283 del, 2083 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl2021-test_test_5gram-kielipankki.bpe19000.d0.0001/wer_7_0.5
%WER 13.90 [ 3790 / 27261, 581 ins, 1075 del, 2134 sub ] exp/andre_comparison/chain/tdnn_d/decode_parl2021-test_test_parl-train-unfiltered_varikn.bpe1750.d0.0001/wer_7_1.0
%WER 10.26 [ 2798 / 27261, 333 ins, 677 del, 1788 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl2021-test_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_0.0
%WER 9.30 [ 2535 / 27261, 257 ins, 733 del, 1545 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl2021-test_test_parl_30M_varikn.bpe19000.d0.0001/wer_7_0.5
%WER 10.12 [ 2759 / 27261, 243 ins, 814 del, 1702 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl2021-test_test_5gram-kielipankki.bpe19000.d0.0001/wer_7_0.0
%WER 8.68 [ 2366 / 27261, 247 ins, 566 del, 1553 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl2021-test_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001/wer_7_0.5
```

Lahjoita puhetta test set.

```txt
%WER 72.22 [ 45191 / 62574, 1813 ins, 16503 del, 26875 sub ] exp/i/tri4j/decode_lp-test_test_parl_20M_varikn.bpe19000.d0.0001/wer_10_1.0
%WER 81.67 [ 51102 / 62574, 1558 ins, 24053 del, 25491 sub ] exp/i/tri4j/decode_lp-test_test_parl_20M_varikn.bpe19000.d0.0001.si/wer_10_0.0
%WER 71.13 [ 44511 / 62574, 689 ins, 24027 del, 19795 sub ] exp/chain/tdnn_blstm_a_multigpu/decode_lp-test_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_0.0
%WER 66.59 [ 41666 / 62574, 1152 ins, 16130 del, 24384 sub ] exp/chain/tdnn_d/decode_lp-test_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_0.0
%WER 66.06 [ 41334 / 62574, 1102 ins, 16216 del, 24016 sub ] exp/chain/tdnn_d/decode_lp-test_test_parl_30M_varikn.bpe19000.d0.0001/wer_7_0.0
%WER 64.33 [ 40253 / 62574, 588 ins, 18984 del, 20681 sub ] exp/chain/tdnn_d/decode_lp-test_test_5gram-kielipankki.bpe19000.d0.0001/wer_8_0.0
%WER 66.90 [ 41864 / 62574, 898 ins, 17872 del, 23094 sub ] exp/chain/tdnn_d/decode_lp-test_test_varikn.bpe1750.d0.0001/wer_8_0.0
%WER 67.30 [ 42113 / 62574, 1068 ins, 18377 del, 22668 sub ] exp/andre_comparison/chain/tdnn_d/decode_lp-test_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_0.0
%WER 66.64 [ 41699 / 62574, 1027 ins, 18343 del, 22329 sub ] exp/andre_comparison/chain/tdnn_d/decode_lp-test_test_parl_30M_varikn.bpe19000.d0.0001/wer_7_0.0
%WER 64.75 [ 40515 / 62574, 687 ins, 18920 del, 20908 sub ] exp/andre_comparison/chain/tdnn_d/decode_lp-test_test_5gram-kielipankki.bpe19000.d0.0001/wer_7_0.0
%WER 65.37 [ 40907 / 62574, 1254 ins, 14710 del, 24943 sub ] exp/combined_comparison/chain/tdnn_d/decode_lp-test_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_0.5
%WER 64.84 [ 40576 / 62574, 1443 ins, 13731 del, 25402 sub ] exp/combined_comparison/chain/tdnn_d/decode_lp-test_test_parl_30M_varikn.bpe19000.d0.0001/wer_7_0.0
%WER 62.61 [ 39180 / 62574, 724 ins, 16579 del, 21877 sub ] exp/combined_comparison/chain/tdnn_d/decode_lp-test_test_5gram-kielipankki.bpe19000.d0.0001/wer_8_0.0
```

Speecon test set.

```txt
%WER 28.01 [ 1550 / 5533, 233 ins, 271 del, 1046 sub ] exp/i/tri4j/decode_speecon-test_test_parl_20M_varikn.bpe19000.d0.0001/wer_9_1.0
%WER 37.56 [ 2078 / 5533, 336 ins, 297 del, 1445 sub ] exp/i/tri4j/decode_speecon-test_test_parl_20M_varikn.bpe19000.d0.0001.si/wer_8_1.0
%WER 21.60 [ 1195 / 5533, 115 ins, 285 del, 795 sub ] exp/chain/tdnn_blstm_a_multigpu/decode_speecon-test_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_0.5
%WER 22.05 [ 1220 / 5533, 119 ins, 301 del, 800 sub ] exp/chain/tdnn_d/decode_speecon-test_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_1.0
%WER 21.11 [ 1168 / 5533, 122 ins, 297 del, 749 sub ] exp/chain/tdnn_d/decode_speecon-test_test_parl_30M_varikn.bpe19000.d0.0001/wer_7_1.0
%WER 13.27 [ 734 / 5533, 77 ins, 249 del, 408 sub ] exp/chain/tdnn_d/decode_speecon-test_test_5gram-kielipankki.bpe19000.d0.0001/wer_9_0.0
%WER 22.79 [ 1261 / 5533, 130 ins, 299 del, 832 sub ] exp/andre_comparison/chain/tdnn_d/decode_speecon-test_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_1.0
%WER 21.16 [ 1171 / 5533, 121 ins, 301 del, 749 sub ] exp/andre_comparison/chain/tdnn_d/decode_speecon-test_test_parl_30M_varikn.bpe19000.d0.0001/wer_7_1.0
%WER 13.36 [ 739 / 5533, 62 ins, 242 del, 435 sub ] exp/andre_comparison/chain/tdnn_d/decode_speecon-test_test_5gram-kielipankki.bpe19000.d0.0001/wer_8_0.5
%WER 21.72 [ 1202 / 5533, 120 ins, 287 del, 795 sub ] exp/combined_comparison/chain/tdnn_d/decode_speecon-test_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_1.0
%WER 20.33 [ 1125 / 5533, 119 ins, 280 del, 726 sub ] exp/combined_comparison/chain/tdnn_d/decode_speecon-test_test_parl_30M_varikn.bpe19000.d0.0001/wer_7_1.0
%WER 12.72 [ 704 / 5533, 63 ins, 242 del, 399 sub ] exp/combined_comparison/chain/tdnn_d/decode_speecon-test_test_5gram-kielipankki.bpe19000.d0.0001/wer_9_0.0
```

Yle test set.

```txt
%WER 36.59 [ 13490 / 36869, 1736 ins, 2288 del, 9466 sub ] exp/i/tri4j/decode_yle-test-new_test_parl_20M_varikn.bpe19000.d0.0001/wer_10_1.0
%WER 40.38 [ 14886 / 36869, 2139 ins, 2123 del, 10624 sub ] exp/i/tri4j/decode_yle-test-new_test_parl_20M_varikn.bpe19000.d0.0001.si/wer_10_0.5
%WER 25.43 [ 9377 / 36869, 783 ins, 2190 del, 6404 sub ] exp/chain/tdnn_blstm_a_multigpu/decode_yle-test-new_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_1.0
%WER 25.22 [ 9299 / 36869, 931 ins, 1882 del, 6486 sub ] exp/chain/tdnn_d/decode_yle-test-new_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_1.0
%WER 24.73 [ 9119 / 36869, 1039 ins, 1825 del, 6255 sub ] exp/chain/tdnn_d/decode_yle-test-new_test_parl_30M_varikn.bpe19000.d0.0001/wer_7_1.0
%WER 16.87 [ 6220 / 36869, 630 ins, 1580 del, 4010 sub ] exp/chain/tdnn_d/decode_yle-test-new_test_5gram-kielipankki.bpe19000.d0.0001/wer_8_0.0
%WER 26.68 [ 9837 / 36869, 998 ins, 2099 del, 6740 sub ] exp/andre_comparison/chain/tdnn_d/decode_yle-test-new_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_1.0
%WER 25.60 [ 9440 / 36869, 994 ins, 2015 del, 6431 sub ] exp/andre_comparison/chain/tdnn_d/decode_yle-test-new_test_parl_30M_varikn.bpe19000.d0.0001/wer_7_1.0
%WER 17.11 [ 6308 / 36869, 428 ins, 2007 del, 3873 sub ] exp/andre_comparison/chain/tdnn_d/decode_yle-test-new_test_5gram-kielipankki.bpe19000.d0.0001/wer_9_0.0
%WER 25.11 [ 9257 / 36869, 1045 ins, 1620 del, 6592 sub ] exp/combined_comparison/chain/tdnn_d/decode_yle-test-new_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_0.5
%WER 24.37 [ 8984 / 36869, 1050 ins, 1712 del, 6222 sub ] exp/combined_comparison/chain/tdnn_d/decode_yle-test-new_test_parl_30M_varikn.bpe19000.d0.0001/wer_7_1.0
%WER 16.65 [ 6140 / 36869, 631 ins, 1588 del, 3921 sub ] exp/combined_comparison/chain/tdnn_d/decode_yle-test-new_test_5gram-kielipankki.bpe19000.d0.0001/wer_8_0.5
```

### 1.2.5. Comparison tables (WER)

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
| Monophone GMM         | 76.26            | 69.87           |
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

[André's paper](https://acris.aalto.fi/ws/portalfiles/portal/15742470/mansikkamaki_interspeech1115.pdf) for comparison.

Different test sets evaluated on Eduskunta2021 AMs and the in-domain 20M token LM.

| Test set              | Best HMM-GMM  | TDNN-d        | TDNN-BLSTM    |
| --------------------- | ------------- | ------------- | ------------- |
| Parl-test-seen 2017   | 10.53 / 3.66  | 7.64 / 2.78   | 8.25 / 3.22   |
| Parl-test-unseen 2017 | 8.82 / 3.35   | 6.26 / 2.53   | 6.52 / 2.73   |
| Parl-test-all 2017    | 9.69 / 3.51   | 6.97 / 2.66   | 7.40 / 2.98   |
| Parl-test 2021        | 16.59 / 3.96  | 9.82 / 2.54   | 10.23 / 3.11  |
| Lahjoita puhetta      | 72.22 / 37.46 | 66.59 / 33.73 | 71.13 / 43.03 |
| Speecon-test          | 28.01 / 5.10  | 22.05 / 3.88  | 21.60 / 4.36  |
| Yle-test              | 36.59 / 10.14 | 25.22 / 6.34  | 25.43 / 7.14  |

Different test sets evaluated on the three TDNN-d acoustic models and 20M token LM.

| Test set              | Eduskunta2021 | Eduskunta2017 | Combined      |
| --------------------- | ------------- | ------------- | ------------- |
| Parl-test-seen 2017   | 7.64 / 2.78   | 8.32 / 3.81   | 7.57 / 3.13   |
| Parl-test-unseen 2017 | 6.26 / 2.53   | 7.11 / 3.38   | 6.62 / 2.87   |
| Parl-test-all 2017    | 6.97 / 2.66   | 7.73 / 3.60   | 7.11 / 3.00   |
| Parl-test 2021        | 9.82 / 2.54   | 13.96 / 4.95  | 10.26 / 2.65  |
| Lahjoita puhetta      | 66.59 / 33.73 | 67.30 / 35.75 | 65.37 / 32.12 |
| Speecon-test          | 22.05 / 3.88  | 22.79 / 4.05  | 21.72 / 3.98  |
| Yle-test              | 25.22 / 6.34  | 26.68 / 6.97  | 25.11 / 6.29  |

Different test sets evaluated on two TDNN-d acoustic models and 30M token LM.

| Test set              | Eduskunta2021 | Eduskunta2017 | Combined      |
| --------------------- | ------------- | ------------- | ------------- |
| Parl-test-seen 2017   | 7.70 / 2.79   | 8.41 / 3.88   | 7.66 / 3.17   |
| Parl-test-unseen 2017 | 6.24 / 2.51   | 7.09 / 3.43   | 6.62 / 2.90   |
| Parl-test-all 2017    | 6.98 / 2.65   | 7.76 / 3.66   | 7.15 / 3.04   |
| Parl-test 2021        | 8.95 / 2.40   | 12.59 / 4.67  | 9.30 / 2.47   |
| Lahjoita puhetta      | 66.06 / 33.44 | 66.64 / 35.34 | 64.84 / 31.79 |
| Speecon-test          | 21.11 / 3.67  | 21.16 / 3.79  | 20.33 / 3.59  |
| Yle-test              | 24.73 / 6.38  | 25.60 / 6.75  | 24.37 / 6.31  |

Different test sets evaluated on the three TDNN-d acoustic models and Kielipankki LM.

| Test set              | Eduskunta2021 | Eduskunta2017 | Combined      |
| --------------------- | ------------- | ------------- | ------------- |
| Parl-test-seen 2017   | 11.69 / 3.75  | 12.29 / 4.72  | 11.21 / 4.09  |
| Parl-test-unseen 2017 | 10.06 / 3.34  | 11.07 / 4.35  | 9.90 / 3.64   |
| Parl-test-all 2017    | 10.89 / 3.55  | 11.69 / 4.54  | 10.57 / 3.87  |
| Parl-test 2021        | 9.71 / 2.69   | 13.88 / 4.58  | 10.12 / 2.78  |
| Lahjoita puhetta      | 64.33 / 32.32 | 64.75 / 33.55 | 62.61 / 30.63 |
| Speecon-test          | 13.27 / 2.40  | 13.36 / 2.44  | 12.72 / 2.22  |
| Yle-test              | 16.87 / 4.90  | 17.11 / 4.80  | 16.65 / 4.87  |

Parliament test sets evaluated on the three TDNN-d acoustic models and their matching transcript LMs.

| Test set              | Eduskunta2021 | Eduskunta2017 | Combined     |
| --------------------- | ------------- | ------------- | ------------ |
| Parl-test-seen 2017   | 11.31 / 3.51  | 11.46 / 4.25  | 10.11 / 3.50 |
| Parl-test-unseen 2017 | 9.63 / 3.17   | 10.86 / 4.02  | 9.09 / 3.19  |
| Parl-test-all 2017    | 10.48 / 3.35  | 11.17 / 4.14  | 9.61 / 3.34  |
| Parl-test 2021        | 8.73 / 2.23   | 13.90 / 4.28  | 8.68 / 2.23  |

Different test sets evaluated on the Eduskunta2021 TDNN-d acoustic model and different LMs.

| Test set              | 20M token     | 30M token     | Transcript   | Kielipankki   |
| --------------------- | ------------- | ------------- | ------------ | ------------- |
| Parl-test-seen 2017   | 7.64 / 2.78   | 7.70 / 2.79   | 11.31 / 3.51 | 11.69 / 3.75  |
| Parl-test-unseen 2017 | 6.26 / 2.53   | 6.24 / 2.51   | 9.63 / 3.17  | 10.06 / 3.34  |
| Parl-test-all 2017    | 6.97 / 2.66   | 6.98 / 2.65   | 10.48 / 3.35 | 10.89 / 3.55  |
| Parl-test 2021        | 9.82 / 2.54   | 8.95 / 2.40   | 8.73 / 2.23  | 9.71 / 2.69   |
| Lahjoita puhetta      | 66.59 / 33.73 | 66.06 / 33.44 | -            | 64.33 / 32.32 |
| Speecon-test          | 22.05 / 3.88  | 21.11 / 3.67  | -            | 13.27 / 2.40  |
| Yle-test              | 25.22 / 6.34  | 24.73 / 6.38  | -            | 16.87 / 4.90  |
