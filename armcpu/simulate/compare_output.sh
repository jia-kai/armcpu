#!/bin/bash -e
# $File: compare_output.sh
# $Date: Thu Dec 19 20:47:49 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

tmpdir=/tmp/armcpu_out_compare
rm -rf $tmpdir
mkdir -p $tmpdir

NORMALIZE="sed -e 's/[Tt]ime.[0-9.]*//g' -e 's/[0-9]* [np]s//g' -e 's/Line: [0-9]*//g'"

for i in output/*
do
	bname=$(basename $i)
	expected_orig=output_expected/$bname

	bash -c "$NORMALIZE $i" > $tmpdir/$bname-actual
	bash -c "$NORMALIZE $expected_orig" > $tmpdir/$bname-expected

	if diff -bc $tmpdir/$bname-{expected,actual}
	then
		echo "$i passed"
	else
		echo -n "correct? "
		read r
		if [ "$r" == "y" ]
		then
			cp $i $expected_orig
		else
			exit
		fi
	fi
done

rm -rf $tmpdir
