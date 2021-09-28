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
```

### 1.2.5. Comparison tables (WER)

Comparison of models with different acoustic model training datasets.

| Acoustic model        | New parliament data | Old parliament data | Old cleaned  | Combined     |
| --------------------- | ------------------- | ------------------- | ------------ | ------------ |
| Monophone GMM         | 56.24               | 69.87               | 55.16        | 61.29        |
| Delta+delta-delta GMM | 21.56               | 21.43               | 21.16        | 21.34        |
| LDA+MLLT GMM          | 17.83               | 17.72               | 17.70        | 17.63        |
| LDA+MLLT+SAT GMM      | 19.38, 16.70        | 19.26, 16.77        | 19.30, 16.71 | 19.23, 16.41 |
| LDA+MLLT+SAT GMM      | 16.41, 14.34        | 16.79, 14.42        | 16.52, 14.05 | 16.21, 14.09 |
| TDNN-d                | 9.98                | 10.34               | 8.35         | -            |
