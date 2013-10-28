#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# $File: controller.py
# $Date: Tue Oct 29 00:57:40 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

import serial
import sys
import os
import time

CMD_WRITE	= chr(0b11110000);
CMD_READ	= chr(0b00001111);
CMD_ERASE	= chr(0b00111000);
CMD_ERASE_IN_PROGRESS	= chr(0b11001100);
CMD_ERASE_FINISHED		= chr(0b00110011);

FLASH_ADDR_SIZE = 22
CHEKSUM_INIT = 0x23

class ChecksumVerifyError(Exception):
    pass

CHUNKSIZE = 4096

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
            print>>sys.stderr, \
                    'checksum validation failed: expect={} got={}'.format(
                        hex(self.checksum), get.encode('hex'))
            raise ChecksumVerifyError()

    def cmd(self, cmd, start_addr, end_addr):
        self.raw_write(cmd)
        self.reset_checksum()
        self.write_addr(start_addr)
        self.write_addr(end_addr)
        self.verify()
        self.reset_checksum()

    @classmethod
    def change_data_byte_order(cls, data):
        return ''.join([data[i + 1] + data[i] for i in range(0, len(data), 2)])

    def write_data(self, data, start_addr):
        if len(data) % 2:
            data += '\xff'
        data = self.change_data_byte_order(data)

        self.cmd(CMD_WRITE, start_addr, start_addr + len(data) / 2)
        self.raw_write(data)
        self.verify()

    def read_data(self, start_addr, size):
        if size % 2:
            size += 1
        size /= 2
        self.cmd(CMD_READ, start_addr, start_addr + size)
        data = self.ser.read(size * 2)
        data = self.change_data_byte_order(data)
        self.update_checksum(data)
        self.verify()
        return data

    def erase(self, addr):
        self.cmd(CMD_ERASE, addr, addr)
        while True:
            rst = self.ser.read(1)
            if rst == CMD_ERASE_FINISHED:
                return
            if rst != CMD_ERASE_IN_PROGRESS:
                print >>sys.stderr, \
                    'unknown signal during erase: {:!r}'.format(rst)
                raise ChecksumVerifyError()

class SpeedCalc(object):
    tot_len = None
    start_time = None
    done = 0

    def __init__(self, tot_len):
        self.tot_len = tot_len
        self.start_time = time.time()

    def trigger(self, delta):
        self.done += delta
        t = time.time() - self.start_time
        sys.stdout.write('{:.3f} KiB/sec; {:.2f}%; ETA: {:.3f}sec  \r'.format(
            self.done / t,
            float(self.done) / self.tot_len * 100,
            t * (self.tot_len - self.done) / self.done))
        sys.stdout.flush()

    def finish(self):
        sys.stdout.write('\n')


if __name__ == '__main__':
    if len(sys.argv) == 1:
        sys.exit('usage: {} read|write|erase'.format(sys.argv[0]))

    ser = serial.Serial('/dev/ttyUSB0', 115201,
            stopbits=2, parity=serial.PARITY_NONE, timeout=1)

    ctl = FlashController(ser)
    if sys.argv[1] == 'read':
        offset, size = map(int, sys.argv[2:4])
        fout_path = sys.argv[4]
        speed = SpeedCalc(size)
        with open(fout_path, 'wb') as fout:
            for i in range(0, size, CHUNKSIZE):
                cur_size = min(CHUNKSIZE, size - i)
                fout.write(ctl.read_data(offset, cur_size))
                offset += cur_size
                speed.trigger(cur_size)
        speed.finish()
    elif sys.argv[1] == 'write':
        offset, fpath = int(sys.argv[2]), sys.argv[3]
        speed = SpeedCalc(os.stat(fpath).st_size)
        with open(fpath) as fin:
            while True:
                data = fin.read(CHUNKSIZE)
                if not data:
                    break
                ctl.write_data(data, offset)
                offset += len(data)
                speed.trigger(len(data))
        speed.finish()
    elif sys.argv[1] == 'erase':
        addr = int(sys.argv[2])
        ctl.erase(addr)
        print 'erase {} finished'.format(hex(addr))

