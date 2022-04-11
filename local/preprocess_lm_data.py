#!/usr/bin/env python3

# Copyright 2022 Anja Virkkunen, Aku Rouhe
# Apache 2.0

# Basic normalization for the LM training data.
# Remove [spk], capitals, kaldi uttid, trim whitespace.
# Concat everything into one file.

import unicodedata

def normalize(line):
    # Remove special tokens:
    line = line.replace("<UNK>", "")
    line = line.replace("[spn]", "")
    line = line.replace("[spk]", "")
    line = line.replace("[int]", "")
    line = line.replace("[fil]", "")
    # Canonical forms of letters, see e.g. the Python docs
    # https://docs.python.org/3.7/library/unicodedata.html#unicodedata.normalize
    line = unicodedata.normalize("NFKC", line)
    # Just decide that everything will be lowercase:
    line = line.lower()
    # All whitespace to one space:
    line = " ".join(line.strip().split())
    # Remove all extra characters:
    line = "".join(char for char in line if char.isalpha() or char == " ")
    return line

if __name__ == "__main__":
    import argparse
    import fileinput
    import sys
    parser = argparse.ArgumentParser()
    parser.add_argument("files", nargs = "*", help = "Files to operate on. If not given, read from stdin.")
    parser.add_argument("--outfile", default = "", help = "Path to write to. If not given, write to stdout instead.")
    args = parser.parse_args()
    if args.outfile:
        with open(args.outfile, "w") as fo:
            for line in fileinput.input(args.files,openhook=fileinput.hook_encoded("utf-8")):
                print(normalize(line), file = fo)
    else:
        for line in fileinput.input(args.files,openhook=fileinput.hook_encoded("utf-8")):
            print(normalize(line))
