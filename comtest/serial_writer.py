#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# $File: serial_writer.py
# $Date: Sat Oct 26 20:10:19 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

import serial   # packge pyserial
import random

ser = serial.Serial('/dev/ttyUSB0', 115201,
        stopbits=2,
        parity=serial.PARITY_NONE, timeout=1)
print ser

while True:
    s = raw_input()
    if not s:
        nr = 1
    else:
        nr = int(s)
    data = ''.join([chr(random.randrange(0, 256)) for _ in range(nr)])
    print len(data), data.encode('hex')
    ser.write(data)
