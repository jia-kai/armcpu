#!/bin/bash
# $File: extract_fsm_state.sh
# $Date: Fri Nov 01 17:16:25 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

fname=$1
fout=$2

if [ -z "$fname" -o -z "$fout" ]; then
	echo "usage: $0 <file name> <output file>"
	exit
fi

grep -o '[A-Z][A-Z0-9_]*[A-Z0-9]:' $fname | tr -d : | vipe | \
	$(dirname $0)/gen_fsm.py > $fout
