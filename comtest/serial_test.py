#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# $File: serial_test.py
# $Date: Sat Oct 26 20:43:11 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

import serial   # packge pyserial
import time
import sys
import random
import operator

CHUNK_SIZE = 1024

def gen_data():
    """:return: data, expected result"""
    data = [random.randrange(1, 256) for _ in range(CHUNK_SIZE)]
    expect = chr(reduce(operator.xor, data))
    return ''.join(map(chr, data)) + '\x00', expect

ser = serial.Serial('/dev/ttyUSB0', 115201,
        stopbits=1, parity=serial.PARITY_NONE, timeout=1)
try:
    tstart = time.time()
    cnt = 0
    nr_err = 0
    while True:
        data, expect = gen_data()
        ser.write(data)
        rst = ser.read()
        if rst != expect:
            nr_err += 1
        cnt += 1
        sys.stdout.write('speed: {:.2f} bytes/sec; err={} tot={}\r'.format(
                cnt * CHUNK_SIZE / (time.time() - tstart), nr_err, cnt))
        sys.stdout.flush()
except Exception as e:
    print e
    ser.close()

