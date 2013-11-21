#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# $File: com.py
# $Date: Thu Nov 21 21:29:29 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

DEVICE = '/dev/ttyUSB0'

import serial
import random

ser = serial.Serial(DEVICE, 115201,
        stopbits=2, parity=serial.PARITY_NONE, timeout=1)


while True:
    raw_input()
    n = random.randint(0, 255)
    print 'write: {} expect resp: {}'.format(hex(n), hex(n + 1))
    ser.write(chr(n))
    print 'got resp: {}'.format(hex(ord(ser.read())))

