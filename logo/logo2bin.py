#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# $File: logo2bin.py
# $Date: Fri Nov 29 01:21:27 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

import cv2
import struct

img = cv2.imread('logo-400x300.png', cv2.CV_LOAD_IMAGE_COLOR)

with open('logo.bin', 'wb') as fout:
    for row in img:
        for pxl in row:
            r, g, b = pxl
            r = r * 8 / 256
            g = g * 8 / 256
            b = b * 4 / 256
            fout.write(struct.pack('B', (r << 5) | (g << 2) | b))

