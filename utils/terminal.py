#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# $File: terminal.py
# $Date: Wed Nov 27 02:24:35 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

DEVICE = '/dev/ttyUSB0'

import serial
import sys
import threading
import time

ser = serial.Serial(DEVICE, 115201,
        stopbits=2, parity=serial.PARITY_NONE)

def com_reader():
    while True:
        data = ser.read()
        sys.stdout.write(data)
        sys.stdout.flush()

def com_writer():
    while True:
        data = raw_input() + '\n'
        for i in data:
            ser.write(i)
            time.sleep(1)

threads = [threading.Thread(target = i) for i in [com_reader, com_writer]]
for i in threads:
    i.start()
print 'terminal started'
for i in threads:
    i.join()

