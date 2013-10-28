#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# $File: controller.py
# $Date: Mon Oct 28 23:38:00 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

import serial

CMD_WRITE = '\xf3'
CMD_READ = '\x2a'

FLASH_ADDR_SIZE = 22
CHEKSUM_INIT = 0x23

class FlashController(object):
    ser = None
    checksum = 0

    def __init__(self, ser):
        self.ser = ser

    def raw_write(self, data):
        assert type(data) is str
        self.ser.write(data)
        self.update_checksum(data)

    def update_checksum(self, data):
        for i in data:
            self.checksum ^= ord(i)

    def write_addr(self, addr):
        assert addr < (1 << FLASH_ADDR_SIZE)
        data = chr(addr >> 16) + chr((addr >> 8) & 0xFF) + \
                chr(addr & 0xFF)
        self.raw_write(data)

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
        self.raw_write(cmd)
        self.reset_checksum()

    @classmethod
    def change_data_byte_order(cls, data):
        return ''.join([data[i + 1] + data[i] for i in range(0, len(data), 2)])

    def write_data(self, data, start_addr):
        if len(data) % 2:
            data += '\xff'
        data = self.change_data_byte_order(data)

        self.cmd(CMD_WRITE)
        self.write_addr(start_addr)
        self.write_addr(start_addr + len(data) / 2)
        self.verify()
        self.reset_checksum()
        self.raw_write(data)
        self.verify()

    def read_data(self, start_addr, size):
        if size % 2:
            size += 1
        size /= 2
        self.cmd(CMD_READ)
        self.write_addr(start_addr)
        self.write_addr(start_addr + size);
        self.verify()
        self.reset_checksum()
        data = self.ser.read(size * 2)
        data = self.change_data_byte_order(data)
        self.update_checksum(data)
        self.verify()
        return data


if __name__ == '__main__':
    ser = serial.Serial('/dev/ttyUSB0', 115201,
            stopbits=2, parity=serial.PARITY_NONE, timeout=1)
    ctl = FlashController(ser)
    data = 'hello, world!'
    addr = 3123
    ctl.write_data(data, addr)
    print repr(ctl.read_data(addr, len(data)))

