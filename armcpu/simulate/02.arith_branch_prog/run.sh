#!/bin/bash -e
# $File: run.sh
# $Date: Sat Nov 16 17:02:24 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

[ -d work ] || vlib work

vlog +incdir+src $i src/*.v top.v ../ram_sim.v

vsim -c -do "run 100ns; quit" top

