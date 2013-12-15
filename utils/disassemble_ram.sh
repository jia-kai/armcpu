#!/bin/bash
# $File: disassemble_ram.sh
# $Date: Sun Dec 15 13:16:58 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

offset=$1
size=$2

if [ -z "$size" ]
then
	echo "usage: $0 <offset> <size>"
	exit
fi

ftmp=$(mktemp)
$(dirname $0)/memtrans/controller.py ram read $offset $size $ftmp
$(dirname $0)/disassemble_bin.sh $ftmp
rm -f $ftmp

