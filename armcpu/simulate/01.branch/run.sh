#!/bin/bash -e
# $File: run.sh
# $Date: Fri Nov 15 10:44:22 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

[ -d work ] || vlib work

vlog +incdir+src $i src/*.v top.v

vsim -c -do "run 20ns" top

