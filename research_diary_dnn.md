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

## 1.1. TODOs

- [ ] Run selected models with old parliament data
- [ ] Run selected models with combination of old and new parliament data
- [x] Analyze errors of decoded train set 
- [x] Decode different iterations
- [x] TDNN-BLSTM model
- [x] Draft tdnn training pipeline
  - [x] Feature extraction
  - [x] First model configuration
  - [x] Decoding and scoring
- [x] Tune tdnn training pipeline
- [x] Improve LM
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
```
%WER 18.07 [ 6451 / 35693, 901 ins, 1440 del, 4110 sub ] exp/chain/tdnn_a/decode_parl-dev-all_test_small/wer_7_0.0
```

After 8 epochs (including evaluations every 500 iterations starting from iteration 4000):
```
%WER 21.81 [ 7784 / 35693, 908 ins, 1952 del, 4924 sub ] exp/chain/tdnn_a/decode_parl-dev-all_test_small_4000/wer_8_0.0
%WER 21.45 [ 7655 / 35693, 915 ins, 2045 del, 4695 sub ] exp/chain/tdnn_a/decode_parl-dev-all_test_small_4500/wer_8_0.0
%WER 21.39 [ 7636 / 35693, 837 ins, 2130 del, 4669 sub ] exp/chain/tdnn_a/decode_parl-dev-all_test_small_5000/wer_8_0.0
%WER 20.96 [ 7481 / 35693, 779 ins, 2305 del, 4397 sub ] exp/chain/tdnn_a/decode_parl-dev-all_test_small_5500/wer_8_0.0
%WER 20.01 [ 7141 / 35693, 810 ins, 2085 del, 4246 sub ] exp/chain/tdnn_a/decode_parl-dev-all_test_small_6000/wer_8_0.0
%WER 17.46 [ 6232 / 35693, 785 ins, 1583 del, 3864 sub ] exp/chain/tdnn_a/decode_parl-dev-all_test_small/wer_8_0.0
%WER 14.50 [ 5174 / 35693, 647 ins, 1494 del, 3033 sub ] exp/chain/tdnn_a/decode_parl-dev-all_test_varikn.bpe1750.d0.0001/wer_8_0.0
%WER 10.10 [ 3605 / 35693, 421 ins, 1321 del, 1863 sub ] exp/chain/tdnn_a/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_8_0.0
```

### 1.4.2. Exp B) Large chain model (21 layers, 26.7 million params)

```
%WER 21.97 [ 7843 / 35693, 853 ins, 2115 del, 4875 sub ] exp/chain/tdnn_b/decode_parl-dev-all_test_small_4000/wer_8_0.0
%WER 20.91 [ 7462 / 35693, 897 ins, 1980 del, 4585 sub ] exp/chain/tdnn_b/decode_parl-dev-all_test_small_4500/wer_8_0.0
%WER 20.98 [ 7489 / 35693, 805 ins, 2083 del, 4601 sub ] exp/chain/tdnn_b/decode_parl-dev-all_test_small_5000/wer_8_0.0
%WER 20.74 [ 7402 / 35693, 762 ins, 2281 del, 4359 sub ] exp/chain/tdnn_b/decode_parl-dev-all_test_small_5500/wer_8_0.0
%WER 19.68 [ 7024 / 35693, 789 ins, 2105 del, 4130 sub ] exp/chain/tdnn_b/decode_parl-dev-all_test_small_6000/wer_8_0.0
%WER 17.11 [ 6108 / 35693, 828 ins, 1506 del, 3774 sub ] exp/chain/tdnn_b/decode_parl-dev-all_test_small/wer_7_0.5 
%WER 9.97 [ 3559 / 35693, 423 ins, 1266 del, 1870 sub ] exp/chain/tdnn_b/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_8_0.0
```

### 1.4.3. Exp C) Small chain model (12 layers, 7.5 million params)

```
%WER 22.14 [ 7903 / 35693, 888 ins, 2059 del, 4956 sub ] exp/chain/tdnn_c/decode_parl-dev-all_test_small_4000/wer_8_0.0
%WER 21.76 [ 7768 / 35693, 905 ins, 2090 del, 4773 sub ] exp/chain/tdnn_c/decode_parl-dev-all_test_small_4500/wer_8_0.0
%WER 21.61 [ 7715 / 35693, 822 ins, 2182 del, 4711 sub ] exp/chain/tdnn_c/decode_parl-dev-all_test_small_5000/wer_8_0.0
%WER 21.29 [ 7599 / 35693, 926 ins, 1961 del, 4712 sub ] exp/chain/tdnn_c/decode_parl-dev-all_test_small_5500/wer_7_0.0
%WER 20.88 [ 7452 / 35693, 945 ins, 1848 del, 4659 sub ] exp/chain/tdnn_c/decode_parl-dev-all_test_small_6000/wer_7_0.0
%WER 18.91 [ 6751 / 35693, 866 ins, 1753 del, 4132 sub ] exp/chain/tdnn_c/decode_parl-dev-all_test_small/wer_8_0.0
%WER 10.24 [ 3655 / 35693, 442 ins, 1349 del, 1864 sub ] exp/chain/tdnn_c/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_8_0.0
```

### 1.4.4. Exp D) Rerun of TDNN-a experiment with 8 epochs from the beginning

This model was trained with up to 4 GPUs (Kaldi starts with one, and increases GPUs one by one).

```
%WER 20.45 [ 7299 / 35693, 831 ins, 2032 del, 4436 sub ] exp/chain/tdnn_d/decode_parl-dev-all_test_small_1200/wer_8_0.0
%WER 19.76 [ 7052 / 35693, 795 ins, 1988 del, 4269 sub ] exp/chain/tdnn_d/decode_parl-dev-all_test_small_1300/wer_8_0.0
%WER 19.64 [ 7009 / 35693, 831 ins, 1914 del, 4264 sub ] exp/chain/tdnn_d/decode_parl-dev-all_test_small_1400/wer_8_0.0
%WER 18.03 [ 6437 / 35693, 753 ins, 1860 del, 3824 sub ] exp/chain/tdnn_d/decode_parl-dev-all_test_small_1500/wer_8_0.0
%WER 17.70 [ 6318 / 35693, 859 ins, 1508 del, 3951 sub ] exp/chain/tdnn_d/decode_parl-dev-all_test_small_1600/wer_7_0.0
%WER 17.42 [ 6217 / 35693, 807 ins, 1549 del, 3861 sub ] exp/chain/tdnn_d/decode_parl-dev-all_test_small_1700/wer_7_0.0
%WER 16.73 [ 5971 / 35693, 803 ins, 1455 del, 3713 sub ] exp/chain/tdnn_d/decode_parl-dev-all_test_small/wer_7_0.5
%WER 9.98 [ 3562 / 35693, 502 ins, 1091 del, 1969 sub ] exp/chain/tdnn_d/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_0.0
```

### 1.4.5. Exp A2) TDNN-BLSTM chain model (3 TDNN + 3 BLSTM layers, 46.1 million params)

Started training with one GPU, but since the model is so large it is slow to train, increased the GPU count to four.

```
%WER 16.25 [ 5800 / 35693, 702 ins, 1705 del, 3393 sub ] exp/chain/tdnn_blstm_a_multigpu/decode_parl-dev-all_test_small/wer_7_0.5
%WER 10.66 [ 3805 / 35693, 484 ins, 1296 del, 2025 sub ] exp/chain/tdnn_blstm_a_multigpu/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_7_0.0
```

### 1.4.6. Best GMM for comparison

```
%WER 29.60 [ 10566 / 35693, 1380 ins, 2201 del, 6985 sub ] exp/i/tri4j/decode_parl-dev-all_test_small.si/wer_13_0.0
%WER 26.50 [ 9460 / 35693, 1344 ins, 1954 del, 6162 sub ] exp/i/tri4j/decode_parl-dev-all_test_small/wer_14_0.0
%WER 23.86 [ 8517 / 35693, 1123 ins, 1906 del, 5488 sub ] exp/i/tri4j/decode_parl-dev-all_test_varikn.bpe1750.d0.0001.si/wer_13_0.0
%WER 21.12 [ 7538 / 35693, 1074 ins, 1741 del, 4723 sub ] exp/i/tri4j/decode_parl-dev-all_test_varikn.bpe1750.d0.0001/wer_14_0.0
%WER 16.41 [ 5858 / 35693, 877 ins, 1466 del, 3515 sub ] exp/i/tri4j/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001.si/wer_14_0.0
%WER 14.34 [ 5117 / 35693, 803 ins, 1379 del, 2935 sub ] exp/i/tri4j/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_16_0.0
```

### 1.4.7. WER comparison tables

LM comparison:

| Acoustic model            | Initial LM (from partial transcripts) | LM from all new eduskunta data transcripts | LM from André's 20M indomain corpus |
| ------------------------- | ------------------------------------- | ------------------------------------------ | ----------------------------------- |
| GMM i/tri4j               | 29.6, 26.5                            | 23.86, 21.12                               | 16.41, 14.34                        |
| TDNN-a (Librispeech)      | 17.46                                 | 14.5                                       | 10.1                                |
| TDNN-b (large)            | 17.11                                 | 14.34                                      | 9.97                                |
| TDNN-c (small)            | 18.91                                 | 15.19                                      | 10.24                               |
| TDNN-d (retrained TDNN-a) | 16.73                                 | 14.19                                      | 9.98                                |
| TDNN-BLSTM                | 16.25                                 | 14.34                                      | 10.66                               |

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

1. *Missing libcuda.so*

CPU nodes do not have `libcuda.so`. Yet, Kaldi's nnet initialization code still depends on it
even if it doesn't use GPU. For now, we hotfixed the issue by copying the `libcuda.so` to our
project root. We have [discussed this with Triton admins](https://version.aalto.fi/gitlab/AaltoScienceIT/triton/-/issues/1078)
and there is also a similar issue on [Kaldi Github](https://github.com/kaldi-asr/kaldi/issues/4576).
We will follow the issues and see if a better solution comes up.

2. *Bash not found on DGX*

The DGX nodes have a different OS compared to all other nodes on Triton. For this reason, slurm
scripts need to have the following shebang `#!/bin/bash -l` if run on DGX nodes. We added the
option `-l` to the `slurm.pl` script (around line 385) that writes the slurm scripts.
Read more [here](https://scicomp.aalto.fi/triton/usage/dgx/?highlight=dgx#basic-required-slurm-options).

---
