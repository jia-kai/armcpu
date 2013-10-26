#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# $File: serial_reader.py
# $Date: Sat Oct 26 18:25:01 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

import serial   # packge pyserial
import time

ser = serial.Serial('/dev/ttyUSB0', 115200,
        stopbits=2, parity=serial.PARITY_NONE, timeout=1)

print ser.read(50).encode('hex')
