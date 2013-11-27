#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# $File: terminal.py
# $Date: Thu Nov 28 02:03:48 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

WRITER_MUTE_STR = '`'
active = True

DEVICE = '/dev/ttyUSB0'

import sys
import serial
import threading
import time

if len(sys.argv) >= 2:
    DEVICE = sys.argv[1]

ser = serial.Serial(DEVICE, 115201,
        stopbits=2, parity=serial.PARITY_NONE,
        timeout = 2)

running = True
def com_reader():
    global running, active
    while running:
        if active == False:
            continue
        data = ser.read()
        if not data:
            continue
        sys.stdout.write(data)
        sys.stdout.flush()

def com_writer():
    global running, active
    while running:
        data = raw_input() + '\n'
        if data.startswith(WRITER_MUTE_STR):
            statestr = 'active' if active else 'inactive'
            print "receiving magic string, writer state: {}" . format(
                    statestr)
            active = not active
            running = False
            break
        if active:
            continue
        for i in data:
            ser.write(i)
            time.sleep(0.03)

threads = [threading.Thread(target = i) for i in [com_reader, com_writer]]
for i in threads:
    i.start()
print 'terminal started'

for i in threads:
    i.join()

