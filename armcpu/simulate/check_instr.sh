#!/bin/bash -e
# $File: check_instr.sh
# $Date: Tue Nov 26 10:57:24 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

if [ ! -z "$1" ]
then
	../../utils/asm2bin.sh $1 prog.bin /tmp/prog.s
	cat /tmp/prog.s
	simu=$(grep -o 'simu: [0-9]\+ns' $1 | cut -d ' ' -f 2)
	[ ! -z "$simu" ] && SIMU_TIME=$simu
fi

./compile.sh

vsim -c -do "run 1000000ns; quit" check_instr

