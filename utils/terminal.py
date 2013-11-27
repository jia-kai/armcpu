#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# $File: terminal.py
# $Date: Thu Nov 28 04:47:48 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>
#          Xinyu Zhou <zxytim@gmail.com>


WRITER_MUTE_STR = '`'
TERMINAL_OUTUT_MAGIC = 't'
FETCH_MAGIC = 'r'

DEVICE = '/dev/ttyUSB0'

import sys
import serial
import threading
import time
import send_file
import os

if os.getenv('DEVICE'):
    DEVICE = os.getenv('DEVICE')

ser = serial.Serial(DEVICE, 115201,
        stopbits=2, parity=serial.PARITY_NONE)

running = True
disable_input = False
def com_reader():
    global running, disable_input, DEVICE
    mode = 'normal' # or 'panic'
    while running:
        if mode == 'normal':
            data = ser.read(2)
            if len(data) == 0:
                continue
            assert len(data) == 2
            if data[0] == TERMINAL_OUTUT_MAGIC:
                console_output = data[1]
                sys.stdout.write(console_output)
                sys.stdout.flush()
            elif data[0] == FETCH_MAGIC:
                def tfmt(msg):
                    return "[local terminal] " + msg
                disable_input = True
                fpath = raw_input(tfmt("file to transfer: "))
                if send_file.send_file(ser, fpath):
                    print tfmt('transfer succeed.')
                else:
                    print tfmt('transfer failed.')
                disable_input = False
            else:
                print "unknown magic: {} {}" . format(hex(ord(data[0])), data[0])
                mode = 'panic'
        else:
            print "in panic"
            data = ser.read()
            if data == 't':
                data = ser.read()
                sys.stdout.write(data)

def com_writer():
    global running, disable_input
    while running:
        if disable_input:
            continue
        data = raw_input() + '\n'
        if data.startswith(WRITER_MUTE_STR):
            running = False
            break
        if disable_input:
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

