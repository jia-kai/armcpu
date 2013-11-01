#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# $File: test.py
# $Date: Fri Nov 01 22:07:45 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

from ctllib import MemtransController
import serial

ser = serial.Serial('/dev/ttyUSB0', 115201,
        stopbits=2, parity=serial.PARITY_NONE, timeout=1)

class SingleStepMemtransController(MemtransController):
    def _do_write_data(self, data):
        for i in data:
            raw_input('write {!r} {} {}'.format(i, hex(ord(i)), bin(ord(i))))
            self.ser.write(i)

#ctl = SingleStepMemtransController(ser)
ctl = MemtransController(ser)

for i in range(1, 512):
    print i
    ctl.write_flash('\x00' * 20, i * 1024 - 10)

ctl.erase_flash(0)

for i in range(1, 512):
    data = ctl.read_flash(i * 1024 - 10, 20)
    print i, repr(data)

#ctl.erase_flash(0)
#ctl.write_flash(data, 0)
#print repr(ctl.read_flash(0, len(data)))

ctl.write_ram(data, 0)
#print repr(ctl.read_ram(0, len(data)))
#print repr(ctl.read_ram(0, 4))
print repr(ctl.read_ram(0, 32))
