#!/bin/bash -e
# $File: compare_output.sh
# $Date: Thu Dec 12 20:51:37 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

tmpdir=/tmp/armcpu_out_compare
rm -rf $tmpdir
mkdir -p $tmpdir

NORMALIZE="sed -e 's/[Tt]ime.[0-9.]*//g' -e 's/[0-9]* ns//g' -e 's/Line: [0-9]*//g'"

for i in output/*
do
	bname=$(basename $i)
	bash -c "$NORMALIZE $i" > $tmpdir/actual-$bname
	bash -c "$NORMALIZE output_expected/$bname" > $tmpdir/expected-$bname

	diff -bc $tmpdir/{actual,expected}-$bname

	echo "$i passed"
done

rm -rf $tmpdir
