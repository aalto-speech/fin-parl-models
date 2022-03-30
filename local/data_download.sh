#!/bin/bash

dir=$(pwd)/data/

. path.sh

echo "Downloading all corpus zips. Zips require around 315G of space."
echo "Unpacked data takes another 375G of space."
echo "Downloading and unzipping this much data will take time."

if [ ! -f $dir/fi-parliament-asr-2008-2016-part1.zip ]; then
    wget https://korp.csc.fi/download/fi-parliament-asr/fi-parliament-asr-2008-2016-part1.zip --directory-prefix=$dir | exit 1
    unzip -n $dir/fi-parliament-asr-2008-2016-part1.zip -d $dir
fi

if [ ! -f $dir/fi-parliament-asr-2008-2016-part2.zip ]; then
    wget https://korp.csc.fi/download/fi-parliament-asr/fi-parliament-asr-2008-2016-part2.zip --directory-prefix=$dir | exit 1
    unzip -n $dir/fi-parliament-asr-2008-2016-part2.zip -d $dir
fi

if [ ! -f $dir/fi-parliament-asr-2008-2016-part3.zip ]; then
    wget https://korp.csc.fi/download/fi-parliament-asr/fi-parliament-asr-2008-2016-part3.zip --directory-prefix=$dir | exit 1
    unzip -n $dir/fi-parliament-asr-2008-2016-part3.zip -d $dir
fi

if [ ! -f $dir/fi-parliament-asr-2008-2016-part4.zip ]; then
    wget https://korp.csc.fi/download/fi-parliament-asr/fi-parliament-asr-2008-2016-part4.zip --directory-prefix=$dir | exit 1
    unzip -n $dir/fi-parliament-asr-2008-2016-part4.zip -d $dir
fi

if [ ! -f $dir/fi-parliament-asr-2008-2016-part5.zip ]; then
    wget https://korp.csc.fi/download/fi-parliament-asr/fi-parliament-asr-2008-2016-part5.zip --directory-prefix=$dir | exit 1
    unzip -n $dir/fi-parliament-asr-2008-2016-part5.zip -d $dir
fi

if [ ! -f $dir/fi-parliament-asr-2015-2020-part1.zip ]; then
    wget https://korp.csc.fi/download/fi-parliament-asr/fi-parliament-asr-2015-2020-part1.zip --directory-prefix=$dir | exit 1
    unzip -n $dir/fi-parliament-asr-2015-2020-part1.zip -d $dir
fi

if [ ! -f $dir/fi-parliament-asr-2015-2020-part2.zip ]; then
    wget https://korp.csc.fi/download/fi-parliament-asr/fi-parliament-asr-2015-2020-part2.zip --directory-prefix=$dir | exit 1
    unzip -n $dir/fi-parliament-asr-2015-2020-part2.zip -d $dir
fi

if [ ! -f $dir/fi-parliament-asr-2015-2020-part3.zip ]; then
    wget https://korp.csc.fi/download/fi-parliament-asr/fi-parliament-asr-2015-2020-part3.zip --directory-prefix=$dir | exit 1
    unzip -n $dir/fi-parliament-asr-2015-2020-part3.zip -d $dir
fi

if [ ! -f $dir/fi-parliament-asr-dev-eval.zip ]; then
    wget https://korp.csc.fi/download/fi-parliament-asr/fi-parliament-asr-dev-eval.zip --directory-prefix=$dir | exit 1
    unzip -n $dir/fi-parliament-asr-dev-eval.zip -d $dir
fi

