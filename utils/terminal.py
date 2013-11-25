#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# $File: terminal.py
# $Date: Mon Nov 25 16:46:28 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

DEVICE = '/dev/ttyUSB0'

import serial

ser = serial.Serial(DEVICE, 115201,
        stopbits=2, parity=serial.PARITY_NONE)

print 'terminal started'
print repr(ser.read())
