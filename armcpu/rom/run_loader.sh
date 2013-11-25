#!/bin/bash -e
# $File: run_loader.sh
# $Date: Mon Nov 25 16:46:18 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

MEMTRANS=../../memtrans/utils/controller.py

../../utils/asm2bin.sh bootloader.s bootloader.bin /tmp/prog.s

$MEMTRANS ram write 5M bootloader.bin
$MEMTRANS ram write 0 jumper.bin
$MEMTRANS jmp_mem_start

../../utils/terminal.py
