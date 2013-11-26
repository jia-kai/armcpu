#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# $File: terminal.py
# $Date: Tue Nov 26 22:17:12 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

DEVICE = '/dev/ttyUSB0'

import serial
import sys
import threading

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
        ser.write(data)

threads = [threading.Thread(target = i) for i in [com_reader, com_writer]]
for i in threads:
    i.start()
print 'terminal started'
for i in threads:
    i.join()

