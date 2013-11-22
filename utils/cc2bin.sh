#!/bin/bash
# $File: cc2bin.sh
# $Date: Fri Nov 22 22:32:03 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

SECTION=.text.startup._ZN4Main4mainEv
CC=mips-sde-elf-g++
CC_FLAGS="-EL -mips32 -c -O2"
OBJCOPY=mips-sde-elf-objcopy
OBJDUMP=mips-sde-elf-objdump

ccfile=$1
outfile=$2
deasm_dump=$3
[ -z "$deasm_dump" ] && deasm_dump=/dev/stdout
if [ -z "$ccfile" -o -z "$outfile" ]
then
	echo "usage: $0 <cc file> <output file> [<dump disassemble>]"
	exit
fi

tmpobj=$(mktemp)

rst=0
(
set -e
echo $CC $CC_FLAGS $ccfile -o $tmpobj
$CC $CC_FLAGS $ccfile -o $tmpobj
[ -z "$deasm_dump" ] || $OBJDUMP -j $SECTION $tmpobj -D > $deasm_dump
$OBJCOPY -j $SECTION -O binary $tmpobj $outfile
) || rst=1
rm -f $tmpobj

exit $rst
