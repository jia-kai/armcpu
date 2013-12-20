#!/bin/bash -e
# $File: compile.sh
# $Date: Fri Dec 20 13:39:11 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

[ -d work ] || vlib work

[ -z "$SIMU_TIME" ] && SIMU_TIME=60ns

[ -z "$START_FROM_ROM" ] && DEFS="$DEFS +define+START_FROM_RAM=1"

vlog +incdir+src +define+SIMULATION=1 $DEFS \
   	$i src/*.v top.v ram_sim.v check_instr.v multiplier.v vga_ram_sim.v
