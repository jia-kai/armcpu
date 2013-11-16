#!/bin/bash -e
# $File: run.sh
# $Date: Sat Nov 16 17:28:29 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

[ -d work ] || vlib work

vlog +incdir+src $i src/*.v top.v ../ram_sim.v

vsim -c -do "run 60ns; quit" top

