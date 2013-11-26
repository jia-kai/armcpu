#!/bin/bash -e
# $File: run_loader.sh
# $Date: Tue Nov 26 09:50:30 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

MEMTRANS=../../utils/memtrans/controller.py

../../utils/asm2bin.sh bootloader.s bootloader.bin /tmp/bootloader.s

$MEMTRANS ram write 5M bootloader.bin
$MEMTRANS jmp 5M

../../utils/terminal.py
