#!/bin/bash -e
# $File: exec_asm.sh
# $Date: Fri Dec 20 12:16:43 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

src=$1

ASM2BIN=$(dirname $0)/asm2bin.sh
MEMTRANS=$(dirname $0)/memtrans/controller.py

if [ -z "$src" ]
then
	echo "usage: $0 <source file>"
	exit
fi

$ASM2BIN $src /tmp/prog
$MEMTRANS ram write 0 /tmp/prog
$MEMTRANS jmp 0

