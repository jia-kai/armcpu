#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# $File: serial_writer.py
# $Date: Sat Oct 26 16:48:07 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

import serial   # packge pyserial
import time
import sys
import random
import operator

CHUNK_SIZE = 10

def gen_data():
    """:return: data, expected result"""
    data = [random.randrange(1, 256) for _ in range(CHUNK_SIZE)]
    expect = chr(reduce(operator.xor, data))
    return ''.join(map(chr, data)) + '\x00', expect

ser = serial.Serial('/dev/ttyUSB0', 9600, # why 115200 won't work?
        stopbits=1,
        parity=serial.PARITY_EVEN, timeout=1)
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
        sys.stdout.write('speed: {:.2f} bytes/sec; err={} tot={} d={} rst={}\r'.format(
                cnt * CHUNK_SIZE / (time.time() - tstart), nr_err, cnt,
                data.encode('hex'), rst.encode('hex')))
        sys.stdout.flush()
except Exception as e:
    print e
    ser.close()

