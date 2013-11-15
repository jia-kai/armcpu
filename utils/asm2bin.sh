#!/bin/bash
# $File: asm2bin.sh
# $Date: Fri Nov 15 18:48:10 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

AS=mips-sde-elf-as
AS_FLAGS="-EL -g -mips32"
OBJCOPY=mips-sde-elf-objcopy
OBJDUMP=mips-sde-elf-objdump

asmfile=$1
outfile=$2
deasm_dump=$3
if [ -z "$asmfile" -o -z "$outfile" ]
then
	echo "usage: $0 <asm file> <output file> [<dump disassemble>]"
	exit
fi

tmpobj=$(mktemp)

(
set -e
$AS $AS_FLAGS $asmfile -o $tmpobj
[ -z "$deasm_dump" ] || $OBJDUMP -j .text $tmpobj -D > $deasm_dump
$OBJCOPY -j .text -O binary $tmpobj $outfile
)
rm -f $tmpobj

