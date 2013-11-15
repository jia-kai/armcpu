#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# $File: bin2rawmem.py
# $Date: Fri Nov 15 19:27:33 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

import sys

def tohex(s):
    s = hex(s)[2:]
    return "32'h" + '0' * (8 - len(s)) + s

def convert(data, offset):
    assert len(data) % 4 == 0
    items = ['case (instrmem_addr)']
    for i in range(0, len(data), 4):
        a, b, c, d = map(ord, data[i:i+4])
        items.append("{}: instrmem_data = {};".format(
            tohex(i + offset), tohex(a | (b << 8) | (c << 16) | (d << 24))))

    items.append('default: instrmem_data = 0;')

    items.append('endcase')

    return '\n'.join(items)



if __name__ == '__main__':
    if len(sys.argv) < 2:
        sys.exit('usage: {} <raw binary file> [offset]'.format(sys.argv[0]))

    sys.argv.append("0")
    offset = int(sys.argv[2])

    with open(sys.argv[1], 'rb') as fin:
        print convert(fin.read(), offset)

