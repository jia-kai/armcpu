#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# $File: com.py
# $Date: Thu Nov 21 21:40:32 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

DEVICE = '/dev/ttyUSB0'

import serial
import random

ser = serial.Serial(DEVICE, 115201,
        stopbits=2, parity=serial.PARITY_NONE, timeout=1)


while True:
    raw_input()
    n = random.randint(0, 255)
    exp = (n + 1) % 255
    print 'write: {} expect resp: {}'.format(hex(n), hex(exp))

    # should only receive first
    ser.write(chr(n) + chr(random.randint(0, 255))) 

    got = ord(ser.read())
    print 'got resp: {}'.format(hex(got))

    assert got == exp

