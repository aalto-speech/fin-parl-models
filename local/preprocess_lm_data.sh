#!/bin/bash

# basic normalization for the LM training data
# remove [spk], capitals, kaldi uttid, trim whitespace
# concat everything into one file

lm_data_dir='data/lm_prep'

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <text-files> <outfile-name>"
  exit 1
fi

text_files="$1"
outfile_name=$2

mkdir -p $lm_data_dir

# The cut statement removes uttid
# The awk one looks weird but it trims whitespace.
cat $text_files | \
  cut -f 2- -d " " | \
  sed -e "s/\[spk\]//g" -e "s/<UNK>//g" \
    -e "s/\[int\]//g" -e "s/\[fil\]//g" |\
  tr '[:upper:]' '[:lower:]' |\
  awk '{$1=$1;print}' > $lm_data_dir/$outfile_name
