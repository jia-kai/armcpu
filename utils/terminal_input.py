#!/usr/bin/python2
# -*- coding: utf-8 -*-
# $File: terminal_input.py
# $Date: Thu Dec 12 02:16:46 2013 +0800
# $Author: Xinyu Zhou <zxytim[at]gmail[dot]com>

DEVICE = '/dev/ttyUSB0'

import serial
import sys
import time
import os

MAGIC_CHAR = '`'

def usage():
    print "a solely terminal input."
    print "input of Magic Char {} terminates this program." . format(MAGIC_CHAR)

if os.getenv('DEVICE'):
    DEVICE = os.getenv('DEVICE')

usage()

ser = serial.Serial(DEVICE, 115201,
        stopbits=2, parity=serial.PARITY_NONE,
        timeout = 2)


class _Getch:
    """Gets a single character from standard input.  Does not echo to the
screen."""
    def __init__(self):
        try:
            self.impl = _GetchWindows()
        except ImportError:
            self.impl = _GetchUnix()

    def __call__(self): return self.impl()


class _GetchUnix:
    def __init__(self):
        import tty, sys

    def __call__(self):
        import sys, tty, termios
        fd = sys.stdin.fileno()
        old_settings = termios.tcgetattr(fd)
        try:
            tty.setraw(sys.stdin.fileno())
            ch = sys.stdin.read(1)
        finally:
            termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
        return ch


class _GetchWindows:
    def __init__(self):
        import msvcrt

    def __call__(self):
        import msvcrt
        return msvcrt.getch()


getch = _Getch()



def com_writer():
    while True:
#        data = raw_input() + '\n'
        data = getch()
        if data == MAGIC_CHAR:
            break
        print "data: ", hex(ord(data)), data
        for i in data:
            ser.write(i)
            time.sleep(0.03)

if __name__ == '__main__':
    com_writer()

# vim: foldmethod=marker

