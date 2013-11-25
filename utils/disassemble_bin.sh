#!/bin/bash
# $File: disassemble_bin.sh
# $Date: Mon Nov 25 15:37:42 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

fin=$1
if [ -z "$1" ]
then
	echo "usage: $0 <raw bin>"
	exit
fi

mips-sde-elf-objdump -D -b binary -EL -m mips $fin
