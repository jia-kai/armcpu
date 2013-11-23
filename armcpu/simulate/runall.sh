#!/bin/bash
# $File: runall.sh
# $Date: Sat Nov 23 15:04:17 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

mkdir output
for i in prog/*.s
do
	./run.sh $i
	mv transcript output/$(basename $i).transcript
done

