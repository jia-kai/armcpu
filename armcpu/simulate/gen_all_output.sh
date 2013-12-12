#!/bin/bash -e
# $File: gen_all_output.sh
# $Date: Thu Dec 12 20:38:29 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

rm -rf output
mkdir output

for i in prog/*.s
do
	./run.sh $i
	mv transcript output/$(basename $i).transcript
done

