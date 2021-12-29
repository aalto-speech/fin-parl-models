# 1. Research diary for Finnish parliament model training

By Aku & Anja

- [1. Research diary for Finnish parliament model training](#1-research-diary-for-finnish-parliament-model-training)
  - [1.1. TODOs](#11-todos)
  - [1.2. Ideas, plans and resources](#12-ideas-plans-and-resources)
    - [1.2.1. First model](#121-first-model)
  - [1.3. Research questions](#13-research-questions)
  - [1.4. Results](#14-results)
    - [1.4.1. Exp A) Plain chain model (17 layers, 18.8 million params)](#141-exp-a-plain-chain-model-17-layers-188-million-params)
    - [1.4.2. Exp B) Large chain model (21 layers, 26.7 million params)](#142-exp-b-large-chain-model-21-layers-267-million-params)
    - [1.4.3. Exp C) Small chain model (12 layers, 7.5 million params)](#143-exp-c-small-chain-model-12-layers-75-million-params)
    - [1.4.4. Exp D) Rerun of TDNN-a experiment with 8 epochs from the beginning](#144-exp-d-rerun-of-tdnn-a-experiment-with-8-epochs-from-the-beginning)
    - [1.4.5. Exp A2) TDNN-BLSTM chain model (3 TDNN + 3 BLSTM layers, 46.1 million params)](#145-exp-a2-tdnn-blstm-chain-model-3-tdnn--3-blstm-layers-461-million-params)
    - [1.4.6. Best GMM for comparison](#146-best-gmm-for-comparison)
    - [1.4.7. WER comparison tables](#147-wer-comparison-tables)
  - [1.5. Modeling decisions](#15-modeling-decisions)
    - [1.5.1. Chain models](#151-chain-models)
    - [1.5.2. Lexicon](#152-lexicon)
    - [1.5.3. Language model](#153-language-model)
    - [1.5.4. Features](#154-features)
  - [1.6. Observations, thoughts and issues](#16-observations-thoughts-and-issues)
    - [1.6.1. About egs](#161-about-egs)
    - [1.6.2. Cuda problems](#162-cuda-problems)
      - [_Missing libcuda.so_](#missing-libcudaso)
      - [_Bash not found on DGX_](#bash-not-found-on-dgx)

## 1.1. TODOs

- [x] Run selected models with old parliament data
- [x] Run selected models with combination of old and new parliament data
- [x] Analyze errors of decoded train set
- [x] Decode different iterations
- [x] TDNN-BLSTM model
- [x] Draft tdnn training pipeline
  - [x] Feature extraction
  - [x] First model configuration
  - [x] Decoding and scoring
- [x] Tune tdnn training pipeline
- [x] Improve LM
- [ ] Data analysis with combined TDNN model
- [ ] Add dev and test sets to `run.sh`
- [ ] Check that data subsets have all the letters (i.e. do we need to define more rare letters?)

---

## 1.2. Ideas, plans and resources

We start our model building using [Librispeech recipe](https://github.com/kaldi-asr/kaldi/blob/master/egs/librispeech/s5/run.sh) in Kaldi as a starting point. Librispeech recipe was selected because it is designed for a large dataset. Our new Finnish parliament dataset is over 1700 hours.

- Train both a model with ivectors/speed perturbation and without. Start from model without ivectors and augmentation.
- Use more Mel bins (80) than Librispeech (40 is kinda few)

### 1.2.1. First model

Trained first model successfully for 4 epochs/3083 iters.

---

## 1.3. Research questions

1. How good baseline model we can train by finetuning the basic Librispeech recipe for the Finnish parliament data?
2. Is an expert/rule-based lexicon better than a simple grapheme lexicon for Finnish?

---

## 1.4. Results

The best HMM-GMM model was an LDA+MLLT+SAT model trained on the Kielipankki data (`exp/i/tri4j`)
with 14k leaves, 0.5 million Gaussians for 70 iterations. The WER for the best model was 26.5 %
on the `parl-all-dev` set and `test_small` language model. This model was used to create the
alignments for the DNN training.

All models are trained with the new (uncleaned) parliament data published in Kielipankki.

### 1.4.1. Exp A) Plain chain model (17 layers, 18.8 million params)

After 4 epochs:

```txt
%WER 18.07 [ 6451 / 35693, 901 ins, 1440 del, 4110 sub ] exp/chain/tdnn_a/decode_parl-dev-all_test_small/wer_7_0.0
```

After 8 epochs (including evaluations every 500 iterations starting from iteration 4000):

```txt
%WER 21.81 [ 7784 / 35693, 908 ins, 1952 del, 4924 sub ] exp/chain/tdnn_a/decode_parl-dev-all_test_small_4000/wer_8_0.0
%WER 21.45 [ 7655 / 35693, 915 ins, 2045 del, 4695 sub ] exp/chain/tdnn_a/decode_parl-dev-all_test_small_4500/wer_8_0.0
%WER 21.39 [ 7636 / 35693, 837 ins, 2130 del, 4669 sub ] exp/chain/tdnn_a/decode_parl-dev-all_test_small_5000/wer_8_0.0
%WER 20.96 [ 7481 / 35693, 779 ins, 2305 del, 4397 sub ] exp/chain/tdnn_a/decode_parl-dev-all_test_small_5500/wer_8_0.0
%WER 20.01 [ 7141 / 35693, 810 ins, 2085 del, 4246 sub ] exp/chain/tdnn_a/decode_parl-dev-all_test_small_6000/wer_8_0.0
%WER 17.46 [ 6232 / 35693, 785 ins, 1583 del, 3864 sub ] exp/chain/tdnn_a/decode_parl-dev-all_test_small/wer_8_0.0
%WER 14.50 [ 5174 / 35693, 647 ins, 1494 del, 3033 sub ] exp/chain/tdnn_a/decode_parl-dev-all_test_varikn.bpe1750.d0.0001/wer_8_0.0
%WER 10.10 [ 3605 / 35693, 421 ins, 1321 del, 1863 sub ] exp/chain/tdnn_a/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_8_0.0
%WER 10.11 [ 3608 / 35693, 426 ins, 1336 del, 1846 sub ] exp/chain/tdnn_a/decode_parl-dev-all_test_parl_30M_varikn.bpe19000.d0.0001/wer_8_0.0
%CER 5.60 [ 14224 / 254165, 5444 ins, 5562 del, 3218 sub ] exp/chain/tdnn_a/decode_parl-dev-all_test_small/cer_6_0.5
%CER 4.98 [ 12662 / 254165, 4844 ins, 5358 del, 2460 sub ] exp/chain/tdnn_a/decode_parl-dev-all_test_varikn.bpe1750.d0.0001/cer_7_0.0
%CER 4.01 [ 10189 / 254165, 3794 ins, 4822 del, 1573 sub ] exp/chain/tdnn_a/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/cer_7_0.0
%CER 4.02 [ 10223 / 254165, 4018 ins, 4513 del, 1692 sub ] exp/chain/tdnn_a/decode_parl-dev-all_test_parl_30M_varikn.bpe19000.d0.0001/cer_6_0.5
```

### 1.4.2. Exp B) Large chain model (21 layers, 26.7 million params)

```txt
%WER 21.97 [ 7843 / 35693, 853 ins, 2115 del, 4875 sub ] exp/chain/tdnn_b/decode_parl-dev-all_test_small_4000/wer_8_0.0
%WER 20.91 [ 7462 / 35693, 897 ins, 1980 del, 4585 sub ] exp/chain/tdnn_b/decode_parl-dev-all_test_small_4500/wer_8_0.0
%WER 20.98 [ 7489 / 35693, 805 ins, 2083 del, 4601 sub ] exp/chain/tdnn_b/decode_parl-dev-all_test_small_5000/wer_8_0.0
%WER 20.74 [ 7402 / 35693, 762 ins, 2281 del, 4359 sub ] exp/chain/tdnn_b/decode_parl-dev-all_test_small_5500/wer_8_0.0
%WER 19.68 [ 7024 / 35693, 789 ins, 2105 del, 4130 sub ] exp/chain/tdnn_b/decode_parl-dev-all_test_small_6000/wer_8_0.0
%WER 17.11 [ 6108 / 35693, 828 ins, 1506 del, 3774 sub ] exp/chain/tdnn_b/decode_parl-dev-all_test_small/wer_7_0.5
%WER 14.34 [ 5118 / 35693, 656 ins, 1456 del, 3006 sub ] exp/chain/tdnn_b/decode_parl-dev-all_test_varikn.bpe1750.d0.0001/wer_8_0.0
%WER 9.97 [ 3559 / 35693, 423 ins, 1266 del, 1870 sub ] exp/chain/tdnn_b/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_8_0.
%WER 10.06 [ 3591 / 35693, 436 ins, 1260 del, 1895 sub ] exp/chain/tdnn_b/decode_parl-dev-all_test_parl_30M_varikn.bpe19000.d0.0001/wer_8_0.0
%CER 5.46 [ 13883 / 254165, 5417 ins, 5401 del, 3065 sub ] exp/chain/tdnn_b/decode_parl-dev-all_test_small/cer_6_0.5
%CER 4.87 [ 12386 / 254165, 5265 ins, 4538 del, 2583 sub ] exp/chain/tdnn_b/decode_parl-dev-all_test_varikn.bpe1750.d0.0001/cer_6_0.0
%CER 3.97 [ 10078 / 254165, 4115 ins, 4224 del, 1739 sub ] exp/chain/tdnn_b/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/cer_6_0.0
%CER 3.96 [ 10068 / 254165, 4068 ins, 4227 del, 1773 sub ] exp/chain/tdnn_b/decode_parl-dev-all_test_parl_30M_varikn.bpe19000.d0.0001/cer_6_0.0
```

### 1.4.3. Exp C) Small chain model (12 layers, 7.5 million params)

```txt
%WER 22.14 [ 7903 / 35693, 888 ins, 2059 del, 4956 sub ] exp/chain/tdnn_c/decode_parl-dev-all_test_small_4000/wer_8_0.0
%WER 21.76 [ 7768 / 35693, 905 ins, 2090 del, 4773 sub ] exp/chain/tdnn_c/decode_parl-dev-all_test_small_4500/wer_8_0.0
%WER 21.61 [ 7715 / 35693, 822 ins, 2182 del, 4711 sub ] exp/chain/tdnn_c/decode_parl-dev-all_test_small_5000/wer_8_0.0
%WER 21.29 [ 7599 / 35693, 926 ins, 1961 del, 4712 sub ] exp/chain/tdnn_c/decode_parl-dev-all_test_small_5500/wer_7_0.0
%WER 20.88 [ 7452 / 35693, 945 ins, 1848 del, 4659 sub ] exp/chain/tdnn_c/decode_parl-dev-all_test_small_6000/wer_7_0.0
%WER 18.91 [ 6751 / 35693, 866 ins, 1753 del, 4132 sub ] exp/chain/tdnn_c/decode_parl-dev-all_test_small/wer_8_0.0
%WER 15.19 [ 5421 / 35693, 584 ins, 1833 del, 3004 sub ] exp/chain/tdnn_c/decode_parl-dev-all_test_varikn.bpe1750.d0.0001/wer_9_0.0
%WER 10.24 [ 3655 / 35693, 442 ins, 1349 del, 1864 sub ] exp/chain/tdnn_c/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_8_0.0
%WER 10.22 [ 3647 / 35693, 430 ins, 1369 del, 1848 sub ] exp/chain/tdnn_c/decode_parl-dev-all_test_parl_30M_varikn.bpe19000.d0.0001/wer_8_0.0
%CER 5.82 [ 14783 / 254165, 5666 ins, 5662 del, 3455 sub ] exp/chain/tdnn_c/decode_parl-dev-all_test_small/cer_6_0.0
%CER 5.08 [ 12920 / 254165, 4547 ins, 5780 del, 2593 sub ] exp/chain/tdnn_c/decode_parl-dev-all_test_varikn.bpe1750.d0.0001/cer_7_0.0
%CER 4.05 [ 10283 / 254165, 3935 ins, 4555 del, 1793 sub ] exp/chain/tdnn_c/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/cer_6_0.0
%CER 4.03 [ 10231 / 254165, 3878 ins, 4562 del, 1791 sub ] exp/chain/tdnn_c/decode_parl-dev-all_test_parl_30M_varikn.bpe19000.d0.0001/cer_6_0.0
```

### 1.4.4. Exp D) Rerun of TDNN-a experiment with 8 epochs from the beginning

This model was trained with up to 4 GPUs (Kaldi starts with one, and increases GPUs one by one).

```txt
%WER 20.45 [ 7299 / 35693, 831 ins, 2032 del, 4436 sub ] exp/chain/tdnn_d/decode_parl-dev-all_test_small_1200/wer_8_0.0
%WER 19.76 [ 7052 / 35693, 795 ins, 1988 del, 4269 sub ] exp/chain/tdnn_d/decode_parl-dev-all_test_small_1300/wer_8_0.0
%WER 19.64 [ 7009 / 35693, 831 ins, 1914 del, 4264 sub ] exp/chain/tdnn_d/decode_parl-dev-all_test_small_1400/wer_8_0.0
%WER 18.03 [ 6437 / 35693, 753 ins, 1860 del, 3824 sub ] exp/chain/tdnn_d/decode_parl-dev-all_test_small_1500/wer_8_0.0
%WER 17.70 [ 6318 / 35693, 859 ins, 1508 del, 3951 sub ] exp/chain/tdnn_d/decode_parl-dev-all_test_small_1600/wer_7_0.0
%WER 17.42 [ 6217 / 35693, 807 ins, 1549 del, 3861 sub ] exp/chain/tdnn_d/decode_parl-dev-all_test_small_1700/wer_7_0.0
%WER 16.73 [ 5971 / 35693, 803 ins, 1455 del, 3713 sub ] exp/chain/tdnn_d/decode_parl-dev-all_test_small/wer_7_0.5
%WER 14.19 [ 5066 / 35693, 661 ins, 1413 del, 2992 sub ] exp/chain/tdnn_d/decode_parl-dev-all_test_varikn.bpe1750.d0.0001/wer_8_0.0
%WER 9.98 [ 3562 / 35693, 502 ins, 1091 del, 1969 sub ] exp/chain/tdnn_d/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_0.0
%WER 10.02 [ 3575 / 35693, 431 ins, 1269 del, 1875 sub ] exp/chain/tdnn_d/decode_parl-dev-all_test_parl_30M_varikn.bpe19000.d0.0001/wer_8_0.0
%WER 14.77 [ 5272 / 35693, 681 ins, 1350 del, 3241 sub ] exp/chain/tdnn_d/decode_parl-dev-all_test_5gram-kielipankki.bpe19000.d0.0001/wer_6_0.0
%WER 21.84 [ 7794 / 35693, 1412 ins, 1578 del, 4804 sub ] exp/chain/tdnn_d/decode_parl-dev-all_test_dspcon-webcon-interpolated-conversational-lm/wer_8_0.0
%WER 5.39 [ 13707 / 254165, 5554 ins, 5142 del, 3011 sub ] exp/chain/tdnn_d/decode_parl-dev-all_test_small/cer_6_0.5
%WER 4.86 [ 12348 / 254165, 5131 ins, 4695 del, 2522 sub ] exp/chain/tdnn_d/decode_parl-dev-all_test_varikn.bpe1750.d0.0001/cer_6_0.5
%WER 3.95 [ 10049 / 254165, 3928 ins, 4474 del, 1647 sub ] exp/chain/tdnn_d/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/cer_7_0.0
%WER 3.98 [ 10128 / 254165, 4296 ins, 4040 del, 1792 sub ] exp/chain/tdnn_d/decode_parl-dev-all_test_parl_30M_varikn.bpe19000.d0.0001/cer_6_0.0
%WER 5.00 [ 12705 / 254165, 4958 ins, 5140 del, 2607 sub ] exp/chain/tdnn_d/decode_parl-dev-all_test_5gram-kielipankki.bpe19000.d0.0001/cer_6_0.0
%WER 5.76 [ 14640 / 254165, 5747 ins, 5532 del, 3361 sub ] exp/chain/tdnn_d/decode_parl-dev-all_test_dspcon-webcon-interpolated-conversational-lm/cer_6_0.0
```

### 1.4.5. Exp A2) TDNN-BLSTM chain model (3 TDNN + 3 BLSTM layers, 46.1 million params)

Started training with one GPU, but since the model is so large it is slow to train, increased the GPU count to four.

```txt
%WER 16.11 [ 5750 / 35693, 746 ins, 1547 del, 3457 sub ] exp/chain/tdnn_blstm_a_multigpu/decode_parl-dev-all_test_small/wer_6_1.0
%WER 14.34 [ 5118 / 35693, 706 ins, 1402 del, 3010 sub ] exp/chain/tdnn_blstm_a_multigpu/decode_parl-dev-all_test_varikn.bpe1750.d0.0001/wer_7_0.0
%WER 10.66 [ 3805 / 35693, 484 ins, 1296 del, 2025 sub ] exp/chain/tdnn_blstm_a_multigpu/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_0.0
%WER 10.58 [ 3775 / 35693, 468 ins, 1307 del, 2000 sub ] exp/chain/tdnn_blstm_a_multigpu/decode_parl-dev-all_test_parl_30M_varikn.bpe19000.d0.0001/wer_7_0.0
%WER 14.78 [ 5275 / 35693, 743 ins, 1305 del, 3227 sub ] exp/chain/tdnn_blstm_a_multigpu/decode_parl-dev-all_test_5gram-kielipankki.bpe19000.d0.0001/wer_5_0.0
%WER 21.12 [ 7540 / 35693, 1318 ins, 1602 del, 4620 sub ] exp/chain/tdnn_blstm_a_multigpu/decode_parl-dev-all_test_dspcon-webcon-interpolated-conversational-lm/wer_7_0.0
%CER 5.54 [ 14070 / 254165, 5643 ins, 5580 del, 2847 sub ] exp/chain/tdnn_blstm_a_multigpu/decode_parl-dev-all_test_small/cer_5_1.0
%CER 5.20 [ 13214 / 254165, 5624 ins, 5064 del, 2526 sub ] exp/chain/tdnn_blstm_a_multigpu/decode_parl-dev-all_test_varikn.bpe1750.d0.0001/cer_6_0.0
%CER 4.25 [ 10810 / 254165, 4211 ins, 4870 del, 1729 sub ] exp/chain/tdnn_blstm_a_multigpu/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/cer_6_0.0
%CER 4.29 [ 10903 / 254165, 4251 ins, 4882 del, 1770 sub ] exp/chain/tdnn_blstm_a_multigpu/decode_parl-dev-all_test_parl_30M_varikn.bpe19000.d0.0001/cer_6_0.0
%CER 5.34 [ 13562 / 254165, 5545 ins, 5444 del, 2573 sub ] exp/chain/tdnn_blstm_a_multigpu/decode_parl-dev-all_test_5gram-kielipankki.bpe19000.d0.0001/cer_5_0.0
%CER 6.28 [ 15954 / 254165, 6543 ins, 5994 del, 3417 sub ] exp/chain/tdnn_blstm_a_multigpu/decode_parl-dev-all_test_dspcon-webcon-interpolated-conversational-lm/cer_5_0.0
```

### 1.4.6. Best GMM for comparison

```txt
%WER 29.60 [ 10566 / 35693, 1380 ins, 2201 del, 6985 sub ] exp/i/tri4j/decode_parl-dev-all_test_small.si/wer_13_0.0
%WER 26.50 [ 9460 / 35693, 1344 ins, 1954 del, 6162 sub ] exp/i/tri4j/decode_parl-dev-all_test_small/wer_14_0.0
%WER 23.86 [ 8517 / 35693, 1123 ins, 1906 del, 5488 sub ] exp/i/tri4j/decode_parl-dev-all_test_varikn.bpe1750.d0.0001.si/wer_13_0.0
%WER 21.12 [ 7538 / 35693, 1074 ins, 1741 del, 4723 sub ] exp/i/tri4j/decode_parl-dev-all_test_varikn.bpe1750.d0.0001/wer_14_0.0
%WER 16.41 [ 5858 / 35693, 877 ins, 1466 del, 3515 sub ] exp/i/tri4j/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001.si/wer_14_0.0
%WER 14.34 [ 5117 / 35693, 803 ins, 1379 del, 2935 sub ] exp/i/tri4j/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_16_0.0
%WER 16.63 [ 5937 / 35693, 895 ins, 1477 del, 3565 sub ] exp/i/tri4j/decode_parl-dev-all_test_parl_30M_varikn.bpe19000.d0.0001.si/wer_14_0.0
%WER 14.38 [ 5131 / 35693, 832 ins, 1347 del, 2952 sub ] exp/i/tri4j/decode_parl-dev-all_test_parl_30M_varikn.bpe19000.d0.0001/wer_15_0.0
%WER 36.92 [ 13178 / 35693, 1867 ins, 2171 del, 9140 sub ] exp/i/tri4j/decode_parl-dev-all_test_dspcon-webcon-interpolated-conversational-lm.si/wer_15_0.0
%WER 33.34 [ 11900 / 35693, 1958 ins, 1809 del, 8133 sub ] exp/i/tri4j/decode_parl-dev-all_test_dspcon-webcon-interpolated-conversational-lm/wer_15_0.0
%CER 8.36 [ 21242 / 254165, 6328 ins, 9580 del, 5334 sub ] exp/i/tri4j/decode_parl-dev-all_test_small/cer_11_0.0
%CER 7.21 [ 18315 / 254165, 5658 ins, 8375 del, 4282 sub ] exp/i/tri4j/decode_parl-dev-all_test_varikn.bpe1750.d0.0001/cer_12_0.0
%CER 5.71 [ 14522 / 254165, 4921 ins, 6649 del, 2952 sub ] exp/i/tri4j/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/cer_13_0.0
%CER 5.69 [ 14473 / 254165, 5123 ins, 6504 del, 2846 sub ] exp/i/tri4j/decode_parl-dev-all_test_parl_30M_varikn.bpe19000.d0.0001/cer_12_0.0
%CER 9.34 [ 23751 / 254165, 6328 ins, 11431 del, 5992 sub ] exp/i/tri4j/decode_parl-dev-all_test_dspcon-webcon-interpolated-conversational-lm/cer_11_0.0
```

### 1.4.7. WER comparison tables

LM comparisons for Eduskunta2021 acoustic models on parl-dev-all set (WER/CER):

| Acoustic model            | Eduskunta2021 transcripts | 20M token in-domain | 30M token in-domain | Kielipankki 5-gram | Anssi's conversational LM | Partial transcripts |
| ------------------------- | ------------------------- | ------------------- | ------------------- | ------------------ | ------------------------- | ------------------- |
| GMM i/tri4j               | 21.12 / 7.21              | 14.34 / 5.71        | 14.38 / 5.69        | ?                  | 33.34 / 9.34              | 26.50 / 8.36        |
| TDNN-a (Librispeech)      | 14.50 / 4.98              | 10.10 / 4.01        | 10.11 / 4.02        | -                  | -                         | 17.46 / 5.60        |
| TDNN-b (large)            | 14.34 / 4.87              | 9.97 / 3.97         | 10.06 / 3.96        | -                  | -                         | 17.11 / 5.46        |
| TDNN-c (small)            | 15.19 / 5.08              | 10.24 / 4.05        | 10.22 / 4.03        | -                  | -                         | 18.91 / 5.82        |
| TDNN-d (retrained TDNN-a) | 14.19 / 4.86              | 9.98 / 3.95         | 10.02 / 3.98        | 14.77 / 5.00       | 21.84 / 5.76              | 16.73 / 5.39        |
| TDNN-BLSTM                | 14.34 / 5.20              | 10.66 / 4.25        | 10.58 / 4.29        | 14.78 / 5.34       | 21.12 / 6.28              | 16.11 / 5.54        |

---

## 1.5. Modeling decisions

Choices and assumptions made during the study regarding models.

### 1.5.1. Chain models

Our first model is as plain as possible chain model without ivectors and augmentations (speed
pertubations). We'll finetune the plain model and then add ivectors/augmentations to see their
contribution to the model performance.

### 1.5.2. Lexicon

We chose grapheme lexicon in order to minimize outside expert knowledge and make the comparison of
HMM-GMM/DNN to E2E-models "as fair as possible". Our hypothesis is that the impact of lexicon is
small because in Finnish, only rare letters like "c" might have varying pronunciations (sometimes
pronounced like "s" and sometimes "k").

We could later try to evaluate this assumption by comparing results for different lexicon.

### 1.5.3. Language model

We chose SentencePiece byte-pair encoding (BPE) because it is now popular and ubiquituous. Can/Might
switch/compare to Morfessor also.

RNN-LM lattice rescoring left out for now, prepared to implement it later if reviewers ask.

### 1.5.4. Features

We will first train and tune a stripped chain model without i-vectors and speed perturbation, and
then see whether i-vectors and/or speed perturbation improve results. We want to train the stripped
chain model because it is more straightforward to compare it to the E2E models when there are no
"extras".

For MFCCs, we chose 80 Mel bins and low cut-off frequency of 20 Hz. Maybe the low frequencies will
have some useful information. Also considered using 40-80 Hz.

---

## 1.6. Observations, thoughts and issues

### 1.6.1. About egs

We thought we could prepare egs in the feature extraction stage before calling train.py. However,
`get_egs.sh` script expects `chain_dir` as an argument, because it uses some initial config file in
that directory.

Reusing egs is possible **in some cases**, at least if the left and right context in egs creation
are equal or bigger to those during training. So if we create egs with left/right context of 40
then we can train models with context 40 or smaller. Egs need to be recreated when we add ivectors,
augmentation or change MFCC configuration.

### 1.6.2. Cuda problems

#### _Missing libcuda.so_

CPU nodes do not have `libcuda.so`. Yet, Kaldi's nnet initialization code still depends on it
even if it doesn't use GPU. For now, we hotfixed the issue by copying the `libcuda.so` to our
project root. We have [discussed this with Triton admins](https://version.aalto.fi/gitlab/AaltoScienceIT/triton/-/issues/1078)
and there is also a similar issue on [Kaldi Github](https://github.com/kaldi-asr/kaldi/issues/4576).
We will follow the issues and see if a better solution comes up.

#### _Bash not found on DGX_

The DGX nodes have a different OS compared to all other nodes on Triton. For this reason, slurm
scripts need to have the following shebang `#!/bin/bash -l` if run on DGX nodes. We added the
option `-l` to the `slurm.pl` script (around line 385) that writes the slurm scripts.
Read more [here](https://scicomp.aalto.fi/triton/usage/dgx/?highlight=dgx#basic-required-slurm-options).

---
