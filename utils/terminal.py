#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# $File: terminal.py
# $Date: Sun Nov 24 10:35:51 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

DEVICE = '/dev/ttyUSB0'

import serial

ser = serial.Serial(DEVICE, 115201,
        stopbits=2, parity=serial.PARITY_NONE, timeout=10)

print repr(ser.read())
