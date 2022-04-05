#!/usr/bin/env bash
# Make sure that a rare letter gets included at least once in a data subset
# WARNING: this will overwrite the data dir to modify. Normally, this is not
# a problem as the script is intended to be used with data directories which
# were created as a subset (and thus have no important files in them).

max_utt_to_add=5
subset_data_dir_opts="--shortest"  #utils/subset_data_dir.sh is used internally

. ./path.sh
. parse_options.sh

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <base-data> <letter> <data-to-modify>"    
  exit 1
fi

base="$1"
letter="$2"
dir="$3"

# Note: Number of utterances with letter, letter can appear multiple times in one utterance
num_letter_in_target=$(cut -d" " -f2- "$dir"/text | grep --count "$letter")
num_letter_in_base=$(cut -d" " -f2- "$base"/text | grep --count "$letter")

if [ $num_letter_in_target -ge $max_utt_to_add ]; then
  echo "Letter $letter already found in $num_letter_in_target utterances in $dir"
  exit 0
fi

if [ $num_letter_in_base -eq 0 ]; then
  echo "Letter $letter not even found in $base"
  exit 1
fi


to_add=$(echo $max_utt_to_add - $num_letter_in_target | bc )
[[ $num_letter_in_base -lt $max_utt_to_add ]] && to_add=$num_letter_in_base && true
tempdir=$(mktemp -d)
echo "$tempdir"
# Select the utterances from base that have the letter:
grep "[^ ]* .*$letter.*" $base/text | cut -f1 -d" " > "$tempdir"/utts_with_letter
# Filter out those utterances that were already included in target:
utils/filter_scp.pl --exclude "$dir"/text <"$tempdir"/utts_with_letter > "$tempdir"/base_only_utts_with_letter
# Get a full datadir those filtered utterances:
utils/subset_data_dir.sh --utt-list "$tempdir"/base_only_utts_with_letter "$base" "$tempdir"/with_letter
# Choose a subset of those utterances to actually be added:
utils/subset_data_dir.sh $subset_data_dir_opts "$tempdir"/with_letter $to_add "$tempdir"/subset_to_add
# Make a combined datadir, fix any issues:
utils/combine_data.sh "$tempdir"/combined "$dir" "$tempdir"/subset_to_add
utils/fix_data_dir.sh "$tempdir"/combined
# Overwrite the target:
rm -rf "$dir"
mv "$tempdir"/combined "$dir"
rm -rf "$tempdir"
