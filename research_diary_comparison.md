# 1. Experiments comparing different parliament data combinations

- [1. Experiments comparing different parliament data combinations](#1-experiments-comparing-different-parliament-data-combinations)
  - [1.1. Datasets](#11-datasets)
    - [1.1.1. Dataset sizes](#111-dataset-sizes)
  - [1.2. Results](#12-results)
    - [1.2.1. Old parliament](#121-old-parliament)
    - [1.2.2. Old parliament cleaned](#122-old-parliament-cleaned)
    - [1.2.3. New parliament](#123-new-parliament)
    - [1.2.4. Combined](#124-combined)
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
%WER 69.17 [ 24688 / 35693, 939 ins, 6999 del, 16750 sub ] exp/combined_comparison/i/mono/decode_parl-dev-all_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001/wer_8_0.0
%WER 28.43 [ 10148 / 35693, 1023 ins, 2626 del, 6499 sub ] exp/combined_comparison/i/tri1a/decode_parl-dev-all_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001/wer_13_0.0
%WER 23.77 [ 8484 / 35693, 930 ins, 2104 del, 5450 sub ] exp/combined_comparison/i/tri2a/decode_parl-dev-all_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001/wer_14_0.0
%WER 22.20 [ 7924 / 35693, 949 ins, 1958 del, 5017 sub ] exp/combined_comparison/i/tri3a/decode_parl-dev-all_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001/wer_15_0.0
%WER 25.89 [ 9242 / 35693, 1090 ins, 2196 del, 5956 sub ] exp/combined_comparison/i/tri3a/decode_parl-dev-all_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001.si/wer_13_0.0
%WER 19.11 [ 6822 / 35693, 969 ins, 1590 del, 4263 sub ] exp/combined_comparison/i/tri4j/decode_parl-dev-all_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001/wer_15_0.0
%WER 22.11 [ 7892 / 35693, 1045 ins, 1844 del, 5003 sub ] exp/combined_comparison/i/tri4j/decode_parl-dev-all_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001.si/wer_14_0.0
%WER 13.08 [ 4668 / 35693, 781 ins, 1142 del, 2745 sub ] exp/combined_comparison/chain/tdnn_d/decode_parl-dev-all_test_parl-train-2008-2020-kevat_varikn.bpe1750.d0.0001/wer_8_0.0
```

### 1.2.5. Comparison tables (WER)

Comparison of models with different acoustic model training datasets using 20M indomain corpus LM.
In the _"Eduskunta2017 André's cleanup"_ column, we use a version of the Eduskunta2017 data that
André/Peter had cleaned previously and train with it from the beginning. In contrast, the last two
rows in the table (with cleaned AMs) refer to the more common Kaldi practice of cleaning the
original data with the best GMM model (tri4) trained on that original data. The clean data is then
used to train the best GMM and TDNN model again. The latter approach is better for reproducibility
when _only_ the original data is published because it allows others to replicate the clean up procedure.

| Acoustic model                  | Eduskunta2021 | Eduskunta2017 | Eduskunta2017 André's cleanup | Combined     |
| ------------------------------- | ------------- | ------------- | ----------------------------- | ------------ |
| Monophone GMM (mono)            | 56.24         | 69.87         | 55.16                         | 61.29        |
| Delta+delta-delta GMM (tri1)    | 21.56         | 21.43         | 21.16                         | 21.34        |
| LDA+MLLT GMM (tri2)             | 17.83         | 17.72         | 17.70                         | 17.63        |
| LDA+MLLT+SAT GMM (tri3)         | 19.38, 16.70  | 19.26, 16.77  | 19.30, 16.71                  | 19.23, 16.41 |
| LDA+MLLT+SAT GMM (tri4)         | 16.41, 14.34  | 16.79, 14.42  | 16.52, 14.05                  | 16.21, 14.09 |
| TDNN-d                          | 9.98          | 10.34         | 8.35                          | 10.28        |
| LDA+MLLT+SAT GMM (tri4) cleaned | 16.42, 14.31  | 16.51, 14.22  | -                             | -            |
| TDNN-d cleaned                  | 9.37          | ?             | -                             | -            |

Next is a comparison of language models made from the transcripts of acoustic model training data
versus 20M indomain corpus.

Acoustic models trained with Eduskunta2021:

| Acoustic model        | Eduskunta2021 LM | 20M indomain LM |
| --------------------- | ---------------- | --------------- |
| Monophone GMM         | 65.54            | 56.24           |
| Delta+delta-delta GMM | 30.93            | 21.56           |
| LDA+MLLT GMM          | 25.99            | 17.83           |
| LDA+MLLT+SAT GMM      | 27.37, 24.28     | 19.38, 16.70    |
| LDA+MLLT+SAT GMM      | 23.86, 21.12     | 16.41, 14.34    |
| TDNN-d                | 14.19            | 9.98            |

Acoustic models trained with Eduskunta2017:

| Acoustic model        | Eduskunta2017 LM | 20M indomain LM |
| --------------------- | ---------------- | --------------- |
| Monophone GMM         | 76.26            | 69.87           |
| Delta+delta-delta GMM | 29.99            | 21.43           |
| LDA+MLLT GMM          | 25.25            | 17.72           |
| LDA+MLLT+SAT GMM      | 26.46, 23.56     | 19.26, 16.77    |
| LDA+MLLT+SAT GMM      | 23.33, 20.94     | 16.79, 14.42    |
| TDNN-d                | 13.97            | 10.34           |

Acoustic models trained with combined parliament data:

| Acoustic model        | Combined data LM | 20M indomain LM |
| --------------------- | ---------------- | --------------- |
| Monophone GMM         | 69.17            | 61.29           |
| Delta+delta-delta GMM | 28.43            | 21.34           |
| LDA+MLLT GMM          | 23.77            | 17.63           |
| LDA+MLLT+SAT GMM      | 25.89, 22.20     | 19.23, 16.41    |
| LDA+MLLT+SAT GMM      | 22.11, 19.11     | 16.21, 14.09    |
| TDNN-d                | 13.08            | 10.28           |
