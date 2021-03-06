# 1. Research diary for Finnish parliament HMM-GMM model training and tuning

By Aku & Anja

- [1. Research diary for Finnish parliament HMM-GMM model training and tuning](#1-research-diary-for-finnish-parliament-hmm-gmm-model-training-and-tuning)
  - [1.1. Ideas, plans and resources](#11-ideas-plans-and-resources)
  - [1.2. Results](#12-results)
    - [1.2.1. Exp A) 1000 h set](#121-exp-a-1000-h-set)
    - [1.2.2. Exp B) 1000 h set](#122-exp-b-1000-h-set)
    - [1.2.3. Exp C) 1000 h set](#123-exp-c-1000-h-set)
    - [1.2.4. Exp D) 1000 h set](#124-exp-d-1000-h-set)
    - [1.2.5. Exp E) 1000 h set](#125-exp-e-1000-h-set)
    - [1.2.6. Exp F) 1000 h set](#126-exp-f-1000-h-set)
    - [1.2.7. Exp G) 1000 h set](#127-exp-g-1000-h-set)
    - [1.2.8. Exp H) 1717 h set](#128-exp-h-1717-h-set)
    - [1.2.9. Exp I) 1780 h set](#129-exp-i-1780-h-set)
    - [1.2.10. WER comparison tables](#1210-wer-comparison-tables)
  - [1.3. Modeling decisions](#13-modeling-decisions)
    - [1.3.1. Lexicon](#131-lexicon)
    - [1.3.2. Language model](#132-language-model)
  - [1.4. Observations and thoughts](#14-observations-and-thoughts)
    - [1.4.1. Training speed](#141-training-speed)
    - [1.4.2. Feature extraction](#142-feature-extraction)

---

## 1.1. Ideas, plans and resources

We start our model building using Kaldi's [Librispeech recipe](https://github.com/kaldi-asr/kaldi/blob/master/egs/librispeech/s5/run.sh) as a starting point. Librispeech recipe was selected because it is designed for a large dataset. Our new Finnish parliament dataset is 1700 hours.

- We should do parameter search for at least:
    1. `numleaves`
    2. `totgauss`
    3. `num_iters` (and related params realign and fmllr iters)
- We want to ensure we have optimum, i.e. values on both sides of a selected optimum value perform worse
- [A good resource for GMM training](https://jrmeyer.github.io/asr/2019/08/17/Kaldi-troubleshooting.html) and [a related cheatsheet](https://jrmeyer.github.io/asr/2019/08/17/Kaldi-cheatsheet.html).
- Which GMMs do we want to tune? We hope that it would be enough that the last GMM is tuned rigorously. In an [Aachen Librispeech paper](http://dx.doi.org/10.21437/Interspeech.2019-1780), they train one monophone model with **full data (960 h)** and then different triphone models with **full data**. Inspired by this, we make multiple experiments.

---

## 1.2. Results

The 1000 h set refers to an uncleaned 1000 h (3794820.69 seconds of data) training set that was
picked when Anja's work on the new Finnish parliament data segmentation pipeline was ongoing.
We used it to test different training pipelines and to optimize parameters because we presume
the same pipeline and parameters will give the best results also with larger dataset.

Later, when the segmentation pipeline was finished it produced 1780 h of data instead of only
1000 h. The 1780 h set is the one published at Kielipankki. Even later, the published dataset
was cleaned with the Kaldi data cleaning script (`steps/cleanup/clean_and_segment_data_nnet3.sh`)
which cut the total audio length from 1780 h to 1717 h.

### 1.2.1. Exp A) 1000 h set

Results for experiment A when run with the 1000 h set.  

```txt
$ cat exp/a/*/decode*/scoring_kaldi/best_wer
%WER 68.53 [ 24459 / 35693, 962 ins, 6956 del, 16541 sub ] exp/a/mono/decode_parl-dev-all_test_small/wer_7_0.0
%WER 38.39 [ 13703 / 35693, 1305 ins, 3119 del, 9279 sub ] exp/a/tri1a/decode_parl-dev-all_test_small/wer_12_0.0
%WER 35.06 [ 12515 / 35693, 1348 ins, 2784 del, 8383 sub ] exp/a/tri2a/decode_parl-dev-all_test_small/wer_13_0.0
%WER 32.71 [ 11675 / 35693, 1250 ins, 2705 del, 7720 sub ] exp/a/tri3a/decode_parl-dev-all_test_small/wer_16_0.0
%WER 36.15 [ 12904 / 35693, 1308 ins, 2953 del, 8643 sub ] exp/a/tri3a/decode_parl-dev-all_test_small.si/wer_14_0.0
%WER 28.47 [ 10162 / 35693, 1350 ins, 2121 del, 6691 sub ] exp/a/tri4a/decode_parl-dev-all_test_small/wer_14_0.0
%WER 31.72 [ 11322 / 35693, 1382 ins, 2402 del, 7538 sub ] exp/a/tri4a/decode_parl-dev-all_test_small.si/wer_13_0.0
%WER 28.12 [ 10038 / 35693, 1322 ins, 2126 del, 6590 sub ] exp/a/tri4b/decode_parl-dev-all_test_small/wer_16_0.0
%WER 31.56 [ 11266 / 35693, 1390 ins, 2316 del, 7560 sub ] exp/a/tri4b/decode_parl-dev-all_test_small.si/wer_13_0.0
%WER 27.98 [ 9986 / 35693, 1365 ins, 2078 del, 6543 sub ] exp/a/tri4c/decode_parl-dev-all_test_small/wer_15_0.0
%WER 31.22 [ 11145 / 35693, 1393 ins, 2285 del, 7467 sub ] exp/a/tri4c/decode_parl-dev-all_test_small.si/wer_13_0.0
%WER 28.22 [ 10073 / 35693, 1369 ins, 2093 del, 6611 sub ] exp/a/tri4d/decode_parl-dev-all_test_small/wer_14_0.0
%WER 31.37 [ 11196 / 35693, 1396 ins, 2364 del, 7436 sub ] exp/a/tri4d/decode_parl-dev-all_test_small.si/wer_13_0.0
%WER 27.66 [ 9873 / 35693, 1375 ins, 2025 del, 6473 sub ] exp/a/tri4e/decode_parl-dev-all_test_small/wer_15_0.0
%WER 30.97 [ 11053 / 35693, 1387 ins, 2275 del, 7391 sub ] exp/a/tri4e/decode_parl-dev-all_test_small.si/wer_13_0.0
```

### 1.2.2. Exp B) 1000 h set

Results for experiment B when run with the 1000 h set.

```txt
$ cat exp/b/*/decode*/scoring_kaldi/best_wer
%WER 56.71 [ 20242 / 35693, 1007 ins, 5649 del, 13586 sub ] exp/b/mono/decode_parl-dev-all_test_small/wer_8_0.0
%WER 35.22 [ 12572 / 35693, 1238 ins, 3003 del, 8331 sub ] exp/b/tri1a/decode_parl-dev-all_test_small/wer_13_0.0
%WER 28.65 [ 10227 / 35693, 1276 ins, 2310 del, 6641 sub ] exp/b/tri2a/decode_parl-dev-all_test_small/wer_14_0.0
%WER 31.91 [ 11391 / 35693, 1360 ins, 2469 del, 7562 sub ] exp/b/tri2a/decode_parl-dev-all_test_small.si/wer_12_0.0
```

### 1.2.3. Exp C) 1000 h set

Results for experiment B when run with the 1000 h set.

```txt
$ cat exp/c/*/decode*/scoring_kaldi/best_wer
%WER 68.53 [ 24459 / 35693, 962 ins, 6956 del, 16541 sub ] exp/c/mono/decode_parl-dev-all_test_small/wer_7_0.0
%WER 35.11 [ 12533 / 35693, 1266 ins, 2903 del, 8364 sub ] exp/c/tri1a/decode_parl-dev-all_test_small/wer_13_0.0
%WER 28.85 [ 10299 / 35693, 1401 ins, 2134 del, 6764 sub ] exp/c/tri2a/decode_parl-dev-all_test_small/wer_13_0.0
%WER 32.00 [ 11422 / 35693, 1418 ins, 2354 del, 7650 sub ] exp/c/tri2a/decode_parl-dev-all_test_small.si/wer_12_0.0
```

### 1.2.4. Exp D) 1000 h set

Results for experiment D when run with the 1000 h set.

```txt
$ cat exp/d/*/decode*/scoring_kaldi/best_wer
%WER 68.53 [ 24459 / 35693, 962 ins, 6956 del, 16541 sub ] exp/d/mono/decode_parl-dev-all_test_small/wer_7_0.0
%WER 32.97 [ 11769 / 35693, 1292 ins, 2672 del, 7805 sub ] exp/d/tri1a/decode_parl-dev-all_test_small/wer_13_0.0
%WER 28.62 [ 10217 / 35693, 1382 ins, 2124 del, 6711 sub ] exp/d/tri2a/decode_parl-dev-all_test_small/wer_13_0.0
%WER 32.08 [ 11451 / 35693, 1345 ins, 2485 del, 7621 sub ] exp/d/tri2a/decode_parl-dev-all_test_small.si/wer_13_0.0
%WER 28.50 [ 10174 / 35693, 1294 ins, 2235 del, 6645 sub ] exp/d/tri2b/decode_parl-dev-all_test_small/wer_15_0.0
%WER 31.71 [ 11319 / 35693, 1407 ins, 2387 del, 7525 sub ] exp/d/tri2b/decode_parl-dev-all_test_small.si/wer_12_0.0
%WER 28.19 [ 10062 / 35693, 1399 ins, 2064 del, 6599 sub ] exp/d/tri2c/decode_parl-dev-all_test_small/wer_14_0.0
%WER 31.70 [ 11316 / 35693, 1395 ins, 2384 del, 7537 sub ] exp/d/tri2c/decode_parl-dev-all_test_small.si/wer_13_0.0
```

### 1.2.5. Exp E) 1000 h set

Results for experiment E when run with the 1000 h set.

```txt
$ cat exp/e/*/decode*/scoring_kaldi/best_wer
%WER 68.53 [ 24459 / 35693, 962 ins, 6956 del, 16541 sub ] exp/e/mono/decode_parl-dev-all_test_small/wer_7_0.0
%WER 32.97 [ 11769 / 35693, 1292 ins, 2672 del, 7805 sub ] exp/e/tri1a/decode_parl-dev-all_test_small/wer_13_0.0
%WER 30.51 [ 10890 / 35693, 1383 ins, 2271 del, 7236 sub ] exp/e/tri2a/decode_parl-dev-all_test_small/wer_13_0.0
%WER 33.91 [ 12103 / 35693, 1398 ins, 2559 del, 8146 sub ] exp/e/tri2a/decode_parl-dev-all_test_small.si/wer_12_0.0
%WER 28.85 [ 10297 / 35693, 1277 ins, 2284 del, 6736 sub ] exp/e/tri3a/decode_parl-dev-all_test_small/wer_15_0.0
%WER 32.04 [ 11435 / 35693, 1387 ins, 2380 del, 7668 sub ] exp/e/tri3a/decode_parl-dev-all_test_small.si/wer_12_0.0
```

### 1.2.6. Exp F) 1000 h set

Results for experiment F when run with the 1000 h set.

```txt
$ cat exp/f/*/decode*/scoring_kaldi/best_wer
%WER 68.53 [ 24459 / 35693, 962 ins, 6956 del, 16541 sub ] exp/f/mono/decode_parl-dev-all_test_small/wer_7_0.0
%WER 37.44 [ 13364 / 35693, 1251 ins, 3196 del, 8917 sub ] exp/f/tri1a/decode_parl-dev-all_test_small/wer_13_0.0
%WER 32.61 [ 11639 / 35693, 1366 ins, 2498 del, 7775 sub ] exp/f/tri2a/decode_parl-dev-all_test_small/wer_13_0.0
%WER 30.34 [ 10830 / 35693, 1376 ins, 2284 del, 7170 sub ] exp/f/tri3a/decode_parl-dev-all_test_small/wer_14_0.0
%WER 33.49 [ 11955 / 35693, 1412 ins, 2534 del, 8009 sub ] exp/f/tri3a/decode_parl-dev-all_test_small.si/wer_13_0.0
%WER 28.36 [ 10123 / 35693, 1358 ins, 2108 del, 6657 sub ] exp/f/tri4a/decode_parl-dev-all_test_small/wer_14_0.0
%WER 31.33 [ 11182 / 35693, 1399 ins, 2327 del, 7456 sub ] exp/f/tri4a/decode_parl-dev-all_test_small.si/wer_13_0.0
%WER 27.80 [ 9922 / 35693, 1365 ins, 2081 del, 6476 sub ] exp/f/tri4b/decode_parl-dev-all_test_small/wer_15_0.0
%WER 31.10 [ 11100 / 35693, 1403 ins, 2249 del, 7448 sub ] exp/f/tri4b/decode_parl-dev-all_test_small.si/wer_13_0.0
%WER 27.50 [ 9816 / 35693, 1341 ins, 2021 del, 6454 sub ] exp/f/tri4c/decode_parl-dev-all_test_small/wer_15_0.0
%WER 30.83 [ 11004 / 35693, 1399 ins, 2227 del, 7378 sub ] exp/f/tri4c/decode_parl-dev-all_test_small.si/wer_13_0.0
%WER 27.58 [ 9844 / 35693, 1369 ins, 2004 del, 6471 sub ] exp/f/tri4d/decode_parl-dev-all_test_small/wer_15_0.0
%WER 31.15 [ 11120 / 35693, 1392 ins, 2321 del, 7407 sub ] exp/f/tri4d/decode_parl-dev-all_test_small.si/wer_14_0.0
%WER 27.62 [ 9858 / 35693, 1378 ins, 2001 del, 6479 sub ] exp/f/tri4f/decode_parl-dev-all_test_small/wer_15_0.0
%WER 31.39 [ 11204 / 35693, 1378 ins, 2338 del, 7488 sub ] exp/f/tri4f/decode_parl-dev-all_test_small.si/wer_14_0.0
%WER 27.29 [ 9741 / 35693, 1339 ins, 2012 del, 6390 sub ] exp/f/tri4g/decode_parl-dev-all_test_small/wer_15_0.0
%WER 30.68 [ 10951 / 35693, 1347 ins, 2304 del, 7300 sub ] exp/f/tri4g/decode_parl-dev-all_test_small.si/wer_14_0.0
```

### 1.2.7. Exp G) 1000 h set

Results for experiment G when run with the 1000 h set.

```txt
$ cat exp/g/*/decode*/scoring_kaldi/best_wer
%WER 68.53 [ 24459 / 35693, 962 ins, 6956 del, 16541 sub ] exp/e/mono/decode_parl-dev-all_test_small/wer_7_0.0
%WER 37.44 [ 13364 / 35693, 1251 ins, 3196 del, 8917 sub ] exp/f/tri1a/decode_parl-dev-all_test_small/wer_13_0.0
%WER 33.70 [ 12028 / 35693, 1304 ins, 2763 del, 7961 sub ] exp/g/tri2a/decode_parl-dev-all_test_small/wer_14_0.0
%WER 31.47 [ 11233 / 35693, 1298 ins, 2574 del, 7361 sub ] exp/g/tri3a/decode_parl-dev-all_test_small/wer_15_0.0
%WER 34.75 [ 12405 / 35693, 1319 ins, 2827 del, 8259 sub ] exp/g/tri3a/decode_parl-dev-all_test_small.si/wer_15_0.0
%WER 28.38 [ 10130 / 35693, 1350 ins, 2123 del, 6657 sub ] exp/g/tri4a/decode_parl-dev-all_test_small/wer_14_0.0
%WER 31.52 [ 11252 / 35693, 1426 ins, 2311 del, 7515 sub ] exp/g/tri4a/decode_parl-dev-all_test_small.si/wer_12_0.0
```

### 1.2.8. Exp H) 1717 h set

Results for experiment H when run with the cleaned version of the published set (1717 hours). An older DNN
model trained in the research group was used in the cleaning process. Thus this cleaned set is dropped later,
because the results are not reproducible.

```txt
$ cat exp/h/*/decode*/scoring_kaldi/best_wer
%WER 66.98 [ 23907 / 35693, 1067 ins, 6595 del, 16245 sub ] exp/h/mono/decode_parl-dev-all_test_small/wer_7_0.0
%WER 37.36 [ 13336 / 35693, 1303 ins, 3128 del, 8905 sub ] exp/h/tri1a/decode_parl-dev-all_test_small/wer_13_0.0
%WER 32.45 [ 11582 / 35693, 1290 ins, 2563 del, 7729 sub ] exp/h/tri2a/decode_parl-dev-all_test_small/wer_14_0.0
%WER 30.17 [ 10768 / 35693, 1343 ins, 2312 del, 7113 sub ] exp/h/tri3a/decode_parl-dev-all_test_small/wer_15_0.0
%WER 33.55 [ 11976 / 35693, 1334 ins, 2620 del, 8022 sub ] exp/h/tri3a/decode_parl-dev-all_test_small.si/wer_14_0.0
%WER 27.23 [ 9720 / 35693, 1350 ins, 1984 del, 6386 sub ] exp/h/tri4g/decode_parl-dev-all_test_small/wer_15_0.0
%WER 30.26 [ 10800 / 35693, 1440 ins, 2121 del, 7239 sub ] exp/h/tri4g/decode_parl-dev-all_test_small.si/wer_12_0.0
%WER 26.95 [ 9618 / 35693, 1342 ins, 1926 del, 6350 sub ] exp/h/tri4h/decode_parl-dev-all_test_small/wer_15_0.0
%WER 30.15 [ 10762 / 35693, 1401 ins, 2170 del, 7191 sub ] exp/h/tri4h/decode_parl-dev-all_test_small.si/wer_13_0.0
%WER 26.63 [ 9504 / 35693, 1363 ins, 1882 del, 6259 sub ] exp/h/tri4i/decode_parl-dev-all_test_small/wer_14_0.0
%WER 29.68 [ 10595 / 35693, 1365 ins, 2161 del, 7069 sub ] exp/h/tri4i/decode_parl-dev-all_test_small.si/wer_13_0.0
%WER 26.47 [ 9447 / 35693, 1393 ins, 1808 del, 6246 sub ] exp/h/tri4j/decode_parl-dev-all_test_small/wer_13_0.0
%WER 29.59 [ 10562 / 35693, 1410 ins, 2091 del, 7061 sub ] exp/h/tri4j/decode_parl-dev-all_test_small.si/wer_12_0.0
%WER 26.44 [ 9438 / 35693, 1377 ins, 1860 del, 6201 sub ] exp/h/tri4k/decode_parl-dev-all_test_small/wer_14_0.0
%WER 29.27 [ 10448 / 35693, 1368 ins, 2132 del, 6948 sub ] exp/h/tri4k/decode_parl-dev-all_test_small.si/wer_13_0.0
```

### 1.2.9. Exp I) 1780 h set

Results for experiment I when run with the full training set published in Kielipankki (1780 hours).

```txt
$ cat exp/i/*/decode*/scoring_kaldi/best_wer
%WER 71.03 [ 25352 / 35693, 916 ins, 7315 del, 17121 sub ] exp/i/mono/decode_parl-dev-all_test_small/wer_7_0.0
%WER 37.75 [ 13475 / 35693, 1266 ins, 3178 del, 9031 sub ] exp/i/tri1a/decode_parl-dev-all_test_small/wer_13_0.0
%WER 32.60 [ 11635 / 35693, 1256 ins, 2632 del, 7747 sub ] exp/i/tri2a/decode_parl-dev-all_test_small/wer_14_0.0
%WER 30.17 [ 10769 / 35693, 1360 ins, 2334 del, 7075 sub ] exp/i/tri3a/decode_parl-dev-all_test_small/wer_14_0.0
%WER 33.65 [ 12010 / 35693, 1366 ins, 2599 del, 8045 sub ] exp/i/tri3a/decode_parl-dev-all_test_small.si/wer_13_0.0
%WER 27.32 [ 9751 / 35693, 1366 ins, 2021 del, 6364 sub ] exp/i/tri4g/decode_parl-dev-all_test_small/wer_14_0.0
%WER 30.57 [ 10910 / 35693, 1389 ins, 2221 del, 7300 sub ] exp/i/tri4g/decode_parl-dev-all_test_small.si/wer_13_0.0
%WER 26.50 [ 9460 / 35693, 1344 ins, 1954 del, 6162 sub ] exp/i/tri4j/decode_parl-dev-all_test_small/wer_14_0.0
%WER 29.60 [ 10566 / 35693, 1380 ins, 2201 del, 6985 sub ] exp/i/tri4j/decode_parl-dev-all_test_small.si/wer_13_0.0
%WER 26.56 [ 9481 / 35693, 1326 ins, 2010 del, 6145 sub ] exp/i/tri4k/decode_parl-dev-all_test_small/wer_14_0.0
%WER 29.42 [ 10501 / 35693, 1409 ins, 2102 del, 6990 sub ] exp/i/tri4k/decode_parl-dev-all_test_small.si/wer_12_0.0
%WER 56.24 [ 20073 / 35693, 714 ins, 6535 del, 12824 sub ] exp/i/mono/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_8_0.0
%WER 21.56 [ 7694 / 35693, 820 ins, 2211 del, 4663 sub ] exp/i/tri1a/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_14_0.0
%WER 17.83 [ 6365 / 35693, 844 ins, 1736 del, 3785 sub ] exp/i/tri2a/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_14_0.0
%WER 16.70 [ 5961 / 35693, 857 ins, 1553 del, 3551 sub ] exp/i/tri3a/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_15_0.0
%WER 19.38 [ 6917 / 35693, 961 ins, 1682 del, 4274 sub ] exp/i/tri3a/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001.si/wer_13_0.0
%WER 14.34 [ 5117 / 35693, 803 ins, 1379 del, 2935 sub ] exp/i/tri4j/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001/wer_16_0.0
%WER 16.41 [ 5858 / 35693, 877 ins, 1466 del, 3515 sub ] exp/i/tri4j/decode_parl-dev-all_test_parl_20M_varikn.bpe19000.d0.0001.si/wer_14_0.0
%WER 14.38 [ 5131 / 35693, 832 ins, 1347 del, 2952 sub ] exp/i/tri4j/decode_parl-dev-all_test_parl_30M_varikn.bpe19000.d0.0001/wer_15_0.0
%WER 16.63 [ 5937 / 35693, 895 ins, 1477 del, 3565 sub ] exp/i/tri4j/decode_parl-dev-all_test_parl_30M_varikn.bpe19000.d0.0001.si/wer_14_0.0
%WER 21.12 [ 7538 / 35693, 1074 ins, 1741 del, 4723 sub ] exp/i/tri4j/decode_parl-dev-all_test_varikn.bpe1750.d0.0001/wer_14_0.0
%WER 23.86 [ 8517 / 35693, 1123 ins, 1906 del, 5488 sub ] exp/i/tri4j/decode_parl-dev-all_test_varikn.bpe1750.d0.0001.si/wer_13_0.0
```

### 1.2.10. WER comparison tables

A table comparing training pipelines is presented below. A single value in parenthesis tells
the data size while three values stand for data size, number of leaves, and number of Gaussians.
The tri4 model in the first table is always trained with full data, 7000 leaves, and 150 000
Gaussians.

Glossary for shorthands:

- 'f' = full training data
- '2k_short' = Shortest 2000 samples from training data
- '5k' / '10k' / etc. = 5 000 / 10 000 / etc.

The training data used in these results is the 1000 h set described in [section 1.4](#14-results).
Language model is made from the transcripts of this same 1000 h set (called `test_small`).

| Model                    | Run A, Librispeech   | Run B              | Run C                 | Run D               | Run E               | Run F               | Run G              |
| ------------------------ | -------------------- | ------------------ | --------------------- | ------------------- | ------------------- | ------------------- | ------------------ |
| Monophone                | 68.53 (2k_short)     | 56.71 (f)          | 68.53 (2k_short)      | 68.53 (2k_short)    | 68.53 (2k_short)    | 68.53 (2k_short)    | 68.53 (2k_short)   |
| Delta+delta-delta (tri1) | 38.39 (5k,2k,10k)    | -                  | -                     | -                   | -                   | 37.44 (100k,2k,10k) | 37.44 (5k,2k,10k)  |
| LDA+MLLT (tri2)          | 35.06 (10k,2.5k,15k) | 35.22 (f,2.5k,15k) | 35.11 (250k,2.5k,15k) | 32.97 (250k,4k,45k) | 32.97 (250k,4k,45k) | 32.61 (250k,4k,45k) | 33.70 (10k,4k,45k) |
| LDA+MLLT+SAT (tri3)      | 32.71 (10k,2.5k,15k) | -                  | -                     | -                   | 30.51 (250k,4k,45k) | 30.34 (250k,4k,45k) | 31.47 (10k,4k,45k) |
| LDA+MLLT+SAT (tri4)      | 28.47                | 28.65              | 28.85                 | 28.62               | 28.85               | 28.36               | 28.38              |

Next table compares parameter optimization results for the tri4 model. The training data
and LM are the same as in above table.

| Params (#leaves, #gauss, #iters, realign iters, fmllr iters) | Run A | Run D | Run F |
| ------------------------------------------------------------ | ----- | ----- | ----- |
| 7k, 150k, 35, "10 20 30", "2 4 6 12"                         | 28.47 | 28.62 | 28.36 |
| 14k, 150k, 35, "10 20 30", "2 4 6 12"                        | 28.12 | -     | -     |
| 14k, 200k, 35, "10 20 30", "2 4 6 12"                        | 27.98 | 28.19 | 27.80 |
| 7k, 150k, 70, "10 20 30 40 50 60", "2 4 6 12 36 42 48"       | 28.22 | 28.50 | -     |
| 14k, 200k, 70, "10 20 30 40 50 60", "2 4 6 12 36 42 48"      | 27.66 | -     | 27.50 |
| 14k, 250k, 70, "10 20 30 40 50 60", "2 4 6 12 36 42 48"      | -     | -     | 27.29 |
| 21k, 200k, 70, "10 20 30 40 50 60", "2 4 6 12 36 42 48"      | -     | -     | 27.58 |
| 21k, 250k, 70, "10 20 30 40 50 60", "2 4 6 12 36 42 48"      | -     | -     | 27.28 |
| 28k, 200k, 70, "10 20 30 40 50 60", "2 4 6 12 36 42 48"      | -     | -     | 27.62 |

Further optimization of the number of Gaussians with more data. The cleaned set was created
with the Kaldi `clean_and_segment_data_nne3.sh` script using an older DNN model trained in
the research group. Thus this cleaned set is dropped later, because the results are not
reproducible.

| Model\Data                             | 1000 h (run F) | 1717 h (cleaned, run H) | 1780 h (published, run I) |
| -------------------------------------- | -------------- | ----------------------- | ------------------------- |
| Monophone (2k_short)                   | 68.53          | 66.98                   | 71.03                     |
| Delta+delta-delta, tri1 (100k,2k,10k)  | 37.44          | 37.36                   | 37.75                     |
| LDA+MLLT, tri2 (250k,4k,45k)           | 32.61          | 32.45                   | 32.60                     |
| LDA+MLLT+SAT, tri3 (250k,4k,45k)       | 30.34          | 30.17                   | 30.17                     |
| LDA+MLLT+SAT, tri4 (f,14k,250k,70iter) | 27.29          | 27.23                   | 27.32                     |
| LDA+MLLT+SAT, tri4 (f,14k,300k,70iter) | -              | 26.95                   | -                         |
| LDA+MLLT+SAT, tri4 (f,14k,400k,70iter) | -              | 26.63                   | -                         |
| LDA+MLLT+SAT, tri4 (f,14k,500k,70iter) | -              | 26.47                   | 26.50                     |
| LDA+MLLT+SAT, tri4 (f,14k,600k,70iter) | -              | 26.44                   | 26.56                     |

---

## 1.3. Modeling decisions

Choices and assumptions made during the study regarding models.

### 1.3.1. Lexicon

We chose grapheme lexicon in order to minimize outside expert knowledge and make the comparison of
HMM-GMM/DNN to E2E-models "as fair as possible". Our hypothesis is that the impact of lexicon is
small because in Finnish, only rare letters like "c" might have varying pronunciations (sometimes
pronounced like "s" and sometimes "k").

We could later try to evaluate this assumption by comparing results for different lexicon.

### 1.3.2. Language model

We chose SentencePiece byte-pair encoding (BPE) because it is now popular and ubiquituous. Can/Might
switch/compare to Morfessor also.

---

## 1.4. Observations and thoughts

### 1.4.1. Training speed

Training models with large data from the beginning takes time (run B). Librispeech approach (run A)
of training with incremental data is probably faster. In the end, also the final model performance
was better with the incremental approach.

### 1.4.2. Feature extraction

Feature extraction is surprisingly slow (we had to increase the time limit for slurm). One
hypothesis is that since the data is sorted by speaker, many sequential samples are from different
sessions which means different input files (002-2019 and 004-2016 in sample below). Assuming Kaldi
processes samples sequentially, it will access each input file once per speaker instead of
accessing each file once to read all segments related to that input file (if ordered by session).

```txt
# Sample from segments file (rows sorted by the first number in uttid)
00116-002-2019-00046015-00047012 002-2019 460.15 470.12
00116-004-2016-00504145-00505001 004-2016 5041.45 5050.01
```

However, this is not a major issue as feature extraction is done once or twice. So no need
currently to optimize this. We could perhaps omit speaker IDs from the utterance IDs (=> input
would be sorted by session) if we really wanted to avoid this issue.

---
