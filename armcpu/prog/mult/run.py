#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# $File: run.py
# $Date: Sat Nov 23 21:31:18 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

DEVICE = '/dev/ttyUSB0'

import serial

ser = serial.Serial(DEVICE, 115201,
        stopbits=2, parity=serial.PARITY_NONE, timeout=1)

def write_int32(n):
    ser.write(''.join(chr((n >> i) & 0xFF) for i in range(0, 32, 8)))

def read_int64():
    s = ser.read(8)
    #print 'raw value: {!r}'.format(s)
    val = sum(ord(s[i]) << (i * 8) for i in range(8))
    if val > 2 ** 63:
        val -= 2 ** 64
    return val

while True:
    a = int(raw_input())
    write_int32(a)
    b = int(raw_input())
    write_int32(b)
    p0 = read_int64()
    print 'got {}, expect {}, right={}'.format(p0, a * b, p0 == a * b)
