#!/usr/bin/python2
# -*- coding: utf-8 -*-
# $File: send_file.py
# $Date: Thu Nov 28 02:07:33 2013 +0800
# $Author: Xinyu Zhou <zxytim[at]gmail[dot]com>

DEVICE = '/dev/ttyUSB0'

import serial
import sys
import os
import time

CHUNKSIZE = 4096

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
        sys.stdout.write('{:.3f} KiB/sec; {:.2f}%; ETA: {:.3f}sec; passed: {:.3f}sec  \r'.format(
            self.done / t / 1024,
            float(self.done) / self.tot_len * 100,
            t * (self.tot_len - self.done) / self.done,
            t))
        sys.stdout.flush()

    def finish(self):
        sys.stdout.write('\n')

CHECKSUM_INIT = 0x23

class WriteChecksumSerial(object):
    def __init__(self, ser):
        # checksum acts like a synchronizer
        self.checksum = CHECKSUM_INIT
        self.reset_checksum()
        self.ser = ser

    def reset_checksum(self):
        self.checksum = CHECKSUM_INIT

    def _do_write(self, data):
        self.ser.write(data)

    def _update_checksum(self, data):
        for i in data:
            self.checksum ^= ord(i)

    def write(self, data):
        self._do_write(data)
        self._update_checksum(data)

    def read(self, size = 1):
        return self.ser.read(size)


def main():
    if len(sys.argv) != 2 and len(sys.argv) != 3:
        print "Usage: {} <input> [dev]" . format(sys.argv[0])
        sys.exit(1);

    if len(sys.argv) == 3:
        DEVICE = sys.argv[2]

    fpath = sys.argv[1]

    ser = serial.Serial(DEVICE, 115201,
            stopbits = 2, parity = serial.PARITY_NONE, timeout = 1)

    ser = WriteChecksumSerial(ser)

    fsize = os.stat(fpath).st_size
    speed = SpeedCalc(fsize)

    def int2data(int32):
        return chr(int32 & 0xFF) + chr((int32 >> 8) & 0xFF) + \
                chr((int32 >> 16) & 0xFF) + chr((int32 >> 24) & 0xFF)

    def data2int(data):
        assert len(data) == 4
        return ord(data[0]) + (ord(data[1]) << 8) \
                + (ord(data[2]) << 16) + (ord(data[3]) << 24)

    cnt = 0

    # protocol
    # reset_checksum
    # s -> c: size
    # c -> s: checksum
    # reset_checksum
    # s -> c: data
    # c -> s: checksum
    # c -> s: file_write retval

    print "writing size: {} ..." . format(fsize)
    ser.reset_checksum()
    ser.write(int2data(fsize))
    checksum = ord(ser.read()) & 0xFF
    assert ser.checksum == checksum, \
            "local checksum {} != {} received checksum" . format(
                    ser.checksum, checksum)
    ser.reset_checksum()
    with open(fpath) as fin:
        print "writing data ..."
        size = 0
        while True:
            data = fin.read(CHUNKSIZE)
            size += len(data)
            if not data:
                break
            cnt += len(data)
            ser.write(data)
            speed.trigger(len(data))
        checksum = ord(ser.read()) & 0xFF
        file_write_retval = data2int(ser.read(4))
        assert ser.checksum == checksum
        print "{}/{} bytes written." . format(size, fsize)
        if file_write_retval == 0:
            print "file write succeed"
        else:
            print "file write failed: {}" . format(file_write_retval)

if __name__ == '__main__':
    main()

# vim: foldmethod=marker

