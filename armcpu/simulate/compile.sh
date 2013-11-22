#!/bin/bash -e
# $File: compile.sh
# $Date: Fri Nov 22 22:49:36 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

[ -d work ] || vlib work

[ -z "$SIMU_TIME" ] && SIMU_TIME=60ns

vlog +incdir+src +define+SIMULATION=1  $i src/*.v top.v ram_sim.v check_instr.v
