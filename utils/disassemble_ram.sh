#!/bin/bash
# $File: disassemble_ram.sh
# $Date: Mon Nov 25 16:59:29 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

offset=$1
size=$2

if [ -z "$size" ]
then
	echo "usage: $0 <offset> <size>"
	exit
fi

ftmp=$(mktemp)
./memtrans/controller.py ram read $offset $size $ftmp
./disassemble_bin.sh $ftmp
rm -f $ftmp

