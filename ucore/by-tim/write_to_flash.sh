#!/bin/bash -e
# $File: write_to_flash.sh
# $Date: Wed Nov 27 12:45:13 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

MEMTRANS=../../utils/memtrans/controller.py
OBJ=obj/ucore-kernel-initrd

$MEMTRANS flash erase 0 $(ls -al $OBJ | cut -d' ' -f 5)
$MEMTRANS flash write 0 $OBJ
md5sum $OBJ

