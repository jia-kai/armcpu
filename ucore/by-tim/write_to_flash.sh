#!/bin/bash -e
# $File: write_to_flash.sh
# $Date: Thu Nov 28 02:38:40 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>


MEMTRANS=../../utils/memtrans/controller.py
OBJ=obj/ucore-kernel-initrd
[ $# = 1 ] && export DEVICE=$1

$MEMTRANS flash erase 0 $(ls -al $OBJ | cut -d' ' -f 5)
$MEMTRANS flash write 0 $OBJ
md5sum $OBJ

