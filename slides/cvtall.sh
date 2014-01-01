#!/bin/bash -e
# $File: cvtall.sh
# $Date: Wed Jan 01 23:06:46 2014 +0800
# $Author: jiakai <jia.kai66@gmail.com>

rm -rf bin
mkdir bin

datadir=finalpre

for algo in dither tc256
do
	for i in $datadir/*.png
	do
		i=$(basename $i)
		echo $i
		./tc256/tc256 $datadir/$i $algo bin/$algo-${i/png/bin}
	done

	cat bin/$algo-*.bin > bin/$algo-diskimg

done

cat bin/{dither,tc256}-diskimg > bin/diskimg
