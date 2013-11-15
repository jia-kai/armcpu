#!/bin/bash
# $File: asm2bin.sh
# $Date: Fri Nov 15 11:37:20 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

AS=mips-sde-elf-as
OBJCOPY=mips-sde-elf-objcopy

asmfile=$1
outfile=$2
if [ -z "$asmfile" -o -z "$outfile" ]
then
	echo "usage: $0 <asm file> <output file>"
	exit
fi

tmpobj=$(mktemp)

(
set -e
$AS $asmfile -o $tmpobj
$OBJCOPY -j .text -O binary $tmpobj $outfile
)
rm -f $tmpobj

