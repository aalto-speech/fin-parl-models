# Finnish parliament ASR Kaldi model recipes

This repository contains Kaldi recipes for training models using the Finnish Parliament
ASR corpus.

## Requirements

In addition to Kaldi, the recipes rely on three external tools to do subword tokenization
and language modeling.

### VariKN

VariKN is used to do n-gram language modeling. For download and installation, see the
[VariKN Github](https://github.com/vsiivola/variKN).

### SentencePiece

SentencePiece is used for subword tokenization. For download and installation, see the
[SentencePiece Github](https://github.com/google/sentencepiece).

### Subword-kaldi

[Subword-kaldi](https://github.com/aalto-speech/subword-kaldi) is included as a git
submodule in this repository. To get the submodule, run

```sh
git submodule init
git submodule update
```

## SpeechBrain models

See [this](https://github.com/aalto-speech/sb-fin-parl-models) separate repository for the SpeechBrain models.
