#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# $File: send.py
# $Date: Mon Oct 28 11:13:18 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

import serial

CMD_WRITE = '\xf3'

FLASH_ADDR_SIZE = 22
CHEKSUM_INIT = 0x23

class Writer(object):
    ser = None
    checksum = 0

    def __init__(self, ser):
        self.ser = ser

    def write(self, data):
        assert type(data) is str
        self.ser.write(data)
        for i in data:
            self.checksum ^= ord(i)

    def write_addr(self, addr):
        assert addr < (1 << FLASH_ADDR_SIZE)
        data = chr(addr >> 16) + chr((addr >> 8) & 0xFF) + \
                chr(addr & 0xFF)
        self.write(data)

    def reset_checksum(self):
        self.checksum = CHEKSUM_INIT

    def verify(self):
        get = self.ser.read(1)
        if get != chr(self.checksum):
            print 'checksum validation failed: expect={} got={}'.format(
                    hex(self.checksum), get.encode('hex'))
            return False

        return True

    def cmd(self, cmd):
        self.write(cmd)
        self.reset_checksum()


def write_data(ser, data, start_addr):
    if len(data) % 2:
        data += '\xff'
    data = ''.join([data[i + 1] + data[i] for i in range(0, len(data), 2)])

    writer = Writer(ser)
    writer.cmd(CMD_WRITE)
    writer.write_addr(start_addr)
    writer.write_addr(start_addr + len(data) / 2)
    writer.verify()
    writer.reset_checksum()
    writer.write(data)
    writer.verify()


if __name__ == '__main__':
    ser = serial.Serial('/dev/ttyUSB0', 115201,
            stopbits=2, parity=serial.PARITY_NONE, timeout=1)
    write_data(ser, 'hello, world!', 256)

