#!/usr/bin/env python3

# Copyright 2022 Anja Virkkunen, Aku Rouhe
# Apache 2.0

import fileinput
import argparse

parser = argparse.ArgumentParser(
    "Take a word list and spit out a lexicon.txt (character phone units)"
)
parser.add_argument("input", help="Path to file or - for stdin")
parser.add_argument("--unk-token", help="Unknown token symbol", default="<UNK>")
parser.add_argument("--spoken-noise", help="Phone for spoken noise", default="SPN")
args = parser.parse_args()

translation_mapping = {
  "'": "",
  "à": "a",
  "æ": "ä",
  "č": "c",
  "é": "e",
  "í": "i",
  "ñ": "nj",
  "ó": "o",
  "ø": "ö",
  "š": "sh",
  "ú": "u",
  "ü": "u",
  "ý": "y",
}
translation = str.maketrans(translation_mapping)

for line in fileinput.input(args.input, openhook=fileinput.hook_encoded("utf-8")):
    word = line.strip()
    if not word:
        continue
    elif word == args.unk_token:
        print(word, args.spoken_noise)
    else:
        print(word, " ".join(word.translate(translation)))

