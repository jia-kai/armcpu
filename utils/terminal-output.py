#!/usr/bin/python2
# -*- coding: utf-8 -*-
# $File: terminal-output.py
# $Date: Thu Nov 28 02:11:52 2013 +0800
# $Author: Xinyu Zhou <zxytim[at]gmail[dot]com>

DEVICE = '/dev/ttyUSB0'

import serial
import sys

if len(sys.argv) >= 2:
    DEVICE = sys.argv[1]

ser = serial.Serial(DEVICE, 115201,
        stopbits=2, parity=serial.PARITY_NONE,
        timeout = 2)

def com_reader():
    while True:
        data = ser.read()
        sys.stdout.write(data)
        sys.stdout.flush()


com_reader()
# vim: foldmethod=marker

