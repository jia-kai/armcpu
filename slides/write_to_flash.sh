#!/bin/bash -e
# $File: write_to_flash.sh
# $Date: Fri Dec 13 18:19:00 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

fin=$1

if [ -z "$fin" ]
then
	echo "usage: $0 <image file>"
	exit
fi

MEMTRANS=$(dirname $0)/../utils/memtrans/controller.py

$MEMTRANS flash erase 1m $(ls -al $fin | cut -d' ' -f 5)
$MEMTRANS flash write 1m $fin
md5sum $fin

