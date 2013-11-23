#!/bin/bash -e
# $File: runall.sh
# $Date: Sat Nov 23 19:43:23 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

[ -d output ] || mkdir output
for i in prog/*.s
do
	./run.sh $i
	mv transcript output/$(basename $i).transcript
done

