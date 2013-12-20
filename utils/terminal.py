#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# $File: terminal.py
# $Date: Fri Dec 20 16:52:13 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>
#          Xinyu Zhou <zxytim@gmail.com>


WRITER_MUTE_STR = '`'
TERMINAL_OUTUT_MAGIC = 't'
FETCH_MAGIC = 'r'

DEVICE = '/dev/ttyUSB0'

from terminal_input import getch

import sys
import serial
import threading
import time
import send_file
import os
import os.path

if os.getenv('DEVICE'):
    DEVICE = os.getenv('DEVICE')

ser = serial.Serial(DEVICE, 115201,
        stopbits=2, parity=serial.PARITY_NONE)

def do_print(s):
    print s.replace('\n', '\r\n') + '\r'

running = True

def tfmt(msg):
    return "[local terminal] " + msg

def com_reader():
    global running, DEVICE
    mode = 'normal' # or 'panic'
    while running:
        if mode == 'normal':
            data = ser.read(2)
            if len(data) == 0:
                if not running:
                    return
                continue
            assert len(data) == 2
            if data[0] == TERMINAL_OUTUT_MAGIC:
                console_output = data[1]
                if console_output == '\n':
                    console_output = '\r\n'
                sys.stdout.write(console_output)
                sys.stdout.flush()
            elif data[0] == FETCH_MAGIC:
                fpath = data[1]
                while fpath[-1] != '\0':
                    fpath += ser.read(1)
                fpath = fpath[:-1]
                do_print(tfmt('requested file path: ' + fpath))
                if send_file.send_file(ser, fpath):
                    do_print(tfmt('transfer succeed.'))
                else:
                    do_print(tfmt('transfer failed.'))
            else:
                do_print(tfmt("unknown magic: {} {}" . format(
                    hex(ord(data[0])), data[0])))
        else:
            do_print("in panic")
            data = ser.read()
            if data == 't':
                data = ser.read()
                sys.stdout.write(data)

def com_writer():
    global running
    while running:
        #try:
        #    data = raw_input() + '\n'
        #except EOFError:
        #    data = '\x03\n'
        data = getch()

        if data.startswith(WRITER_MUTE_STR):
            do_print(tfmt('press ctrl+\\'))
            sys.exit()
        for i in data:
            ser.write(i)

threads = [threading.Thread(target = i) for i in [com_reader, com_writer]]
for i in threads:
    i.start()
do_print('terminal started')

for i in threads:
    i.join()

