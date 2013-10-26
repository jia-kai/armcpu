#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# $File: serial_writer.py
# $Date: Sat Oct 26 12:06:00 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

import serial   # packge pyserial
import time
import sys

ser = serial.Serial('/dev/ttyUSB0', 9600, timeout = 1)
try:
    i = 0
    tstart = time.time()
    cnt = 0
    nr_wrong = 0
    while True:
        ser.write(chr(i))
        val = ord(ser.read(1))
        i = (i + 1) % 256
        cnt += 1
        if val != i:
            nr_wrong += 1
        sys.stdout.write('speed: {:.2f} bytes/sec; err={} tot={}\r'.format(
                cnt / (time.time() - tstart), nr_wrong, cnt))
        sys.stdout.flush()
except Exception as e:
    print e
    ser.close()

