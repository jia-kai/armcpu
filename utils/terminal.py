#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# $File: terminal.py
# $Date: Tue Nov 26 11:40:59 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

DEVICE = '/dev/ttyUSB0'

import serial
import sys
import gevent

ser = serial.Serial(DEVICE, 115201,
        stopbits=2, parity=serial.PARITY_NONE)

def com_reader():
    while True:
        data = ser.read()
        sys.stdout.write(data)
        sys.stdout.flush()

def com_writer():
    while True:
        data = raw_input() + '\r\n'
        ser.write(data)

jobs = map(gevent.spawn, [com_reader, com_writer])
print 'terminal started'
gevent.joinall(jobs)

