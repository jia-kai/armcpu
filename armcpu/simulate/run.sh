#!/bin/bash -e
# $File: run.sh
# $Date: Sat Nov 16 19:55:27 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

if [ ! -z "$1" ]
then
	../../utils/asm2bin.sh $1 prog.bin /tmp/prog.s
	cat /tmp/prog.s
fi

[ -d work ] || vlib work

[ -z "$SIMU_TIME" ] && SIMU_TIME=60ns

vlog +incdir+src $i src/*.v top.v ram_sim.v

vsim -c -do "run $SIMU_TIME; quit" top

