#!/bin/bash -e
# $File: run_loader.sh
# $Date: Mon Nov 25 17:03:21 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

MEMTRANS=../../utils/memtrans/controller.py

../../utils/asm2bin.sh jumper.s jumper.bin /tmp/jumper.s
../../utils/asm2bin.sh bootloader.s bootloader.bin /tmp/bootloader.s

$MEMTRANS ram write 5M bootloader.bin
$MEMTRANS ram write 0 jumper.bin
$MEMTRANS jmp_mem_start

../../utils/terminal.py
