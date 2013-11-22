#!/bin/bash -e
# $File: check_instr.sh
# $Date: Fri Nov 22 23:14:54 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

if [ ! -z "$1" ]
then
	../../utils/asm2bin.sh $1 prog.bin /tmp/prog.s
	cat /tmp/prog.s
	simu=$(grep -o 'simu: [0-9]\+ns' $1 | cut -d ' ' -f 2)
	[ ! -z "$simu" ] && SIMU_TIME=$simu
fi

./compile.sh

vsim -c -do "run 10000ns; quit" check_instr

