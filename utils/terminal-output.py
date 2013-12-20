#!/usr/bin/python2
# -*- coding: utf-8 -*-
# $File: terminal-output.py
# $Date: Thu Nov 28 02:46:02 2013 +0800
# $Author: Xinyu Zhou <zxytim[at]gmail[dot]com>

DEVICE = '/dev/ttyUSB0'

import serial
import sys
import os

if os.getenv('DEVICE'):
    DEVICE = os.getenv('DEVICE')

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

