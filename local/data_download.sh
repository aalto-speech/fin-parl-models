#!/bin/bash

dir=$(pwd)/data/

. path.sh

echo "Downloading all corpus zips. This requires around 315G of space."

if [ ! -f $dir/fi-parliament-asr-2008-2016-part1.zip ]; then
    wget https://korp.csc.fi/download/fi-parliament-asr/fi-parliament-asr-2008-2016-part1.zip --directory-prefix=$dir | exit 1
    unzip fi-parliament-asr-2008-2016-part1.zip
fi

if [ ! -f $dir/fi-parliament-asr-2008-2016-part2.zip ]; then
    wget https://korp.csc.fi/download/fi-parliament-asr/fi-parliament-asr-2008-2016-part2.zip --directory-prefix=$dir | exit 1
    unzip fi-parliament-asr-2008-2016-part2.zip
fi

if [ ! -f $dir/fi-parliament-asr-2008-2016-part3.zip ]; then
    wget https://korp.csc.fi/download/fi-parliament-asr/fi-parliament-asr-2008-2016-part3.zip --directory-prefix=$dir | exit 1
    unzip fi-parliament-asr-2008-2016-part3.zip
fi

if [ ! -f $dir/fi-parliament-asr-2008-2016-part4.zip ]; then
    wget https://korp.csc.fi/download/fi-parliament-asr/fi-parliament-asr-2008-2016-part4.zip --directory-prefix=$dir | exit 1
    unzip fi-parliament-asr-2008-2016-part4.zip
fi

if [ ! -f $dir/fi-parliament-asr-2008-2016-part5.zip ]; then
    wget https://korp.csc.fi/download/fi-parliament-asr/fi-parliament-asr-2008-2016-part5.zip --directory-prefix=$dir | exit 1
    unzip fi-parliament-asr-2008-2016-part5.zip
fi

if [ ! -f $dir/fi-parliament-asr-2015-2020-part1.zip ]; then
    wget https://korp.csc.fi/download/fi-parliament-asr/fi-parliament-asr-2015-2020-part1.zip --directory-prefix=$dir | exit 1
    unzip $dir/fi-parliament-asr-2015-2020-part1.zip
fi

if [ ! -f $dir/fi-parliament-asr-2015-2020-part2.zip ]; then
    wget https://korp.csc.fi/download/fi-parliament-asr/fi-parliament-asr-2015-2020-part2.zip --directory-prefix=$dir | exit 1
    unzip $dir/fi-parliament-asr-2015-2020-part2.zip
fi

if [ ! -f $dir/fi-parliament-asr-2015-2020-part3.zip ]; then
    wget https://korp.csc.fi/download/fi-parliament-asr/fi-parliament-asr-2015-2020-part3.zip --directory-prefix=$dir | exit 1
    unzip $dir/fi-parliament-asr-2015-2020-part3.zip
fi

if [ ! -f $dir/fi-parliament-asr-dev-eval.zip ]; then
    wget https://korp.csc.fi/download/fi-parliament-asr/fi-parliament-asr-dev-eval.zip --directory-prefix=$dir | exit 1
    unzip $dir/fi-parliament-asr-dev-eval.zip
fi
