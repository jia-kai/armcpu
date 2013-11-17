#!/bin/bash -e
# $File: run.sh
# $Date: Sun Nov 17 15:55:12 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

if [ ! -z "$1" ]
then
	../../utils/asm2bin.sh $1 prog.bin /tmp/prog.s
	cat /tmp/prog.s
	if simu=$(grep -o 'simu: [0-9]\+ns' $1 | cut -d ' ' -f 2)
	then
		echo "simu time: $simu"
		SIMU_TIME=$simu
	fi
fi

[ -d work ] || vlib work

[ -z "$SIMU_TIME" ] && SIMU_TIME=60ns

vlog +incdir+src $i src/*.v top.v ram_sim.v

vsim -c -do "run $SIMU_TIME; quit" top

