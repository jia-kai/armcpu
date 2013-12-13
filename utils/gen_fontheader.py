#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# $File: gen_fontheader.py
# $Date: Fri Dec 13 22:42:02 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

from PIL import Image, ImageFont, ImageDraw
FONT_FILE = "/usr/share/fonts/TTF/DejaVuSansMono.ttf"
FONT_SIZE = 14

CHAR_WIDTH = 10
CHAR_HEIGHT = 15

ROW_NR_CHAR = 16
NR_ROW = 10

START_ASCII = ord(' ')
END_ASCII = 127

def render_image():
    image = Image.new("L", (ROW_NR_CHAR * CHAR_WIDTH, NR_ROW * CHAR_HEIGHT))
    font = ImageFont.truetype(FONT_FILE, FONT_SIZE)
    draw = ImageDraw.Draw(image)
    x = 0
    y = 0
    max_width = 0
    max_height = 0
    for i in map(chr, range(START_ASCII, END_ASCII)):
        size = draw.textsize(i, font=font)
        max_width = max(max_width, size[0])
        max_height = max(max_height, size[1])
        draw.text((x, y), i, 255, font=font)
        x += CHAR_WIDTH
        if x == ROW_NR_CHAR * CHAR_WIDTH:
            x = 0
            y += CHAR_HEIGHT

    assert max_width <= CHAR_WIDTH and max_height <= CHAR_HEIGHT,\
        (max_width, max_height)
    return image

def get_char_bitmap(image, char):
    num = ord(char) - START_ASCII
    r = num / ROW_NR_CHAR * CHAR_HEIGHT + 1
    c = num % ROW_NR_CHAR * CHAR_WIDTH
    pos = []
    for i in range(r, r + CHAR_HEIGHT):
        for j in range(c, c + CHAR_WIDTH):
            val = image.getpixel((j, i))
            if val > 127:
                val = 1
            else:
                val = 0
            pos.append(val)

    rst = []
    for i in range(0, len(pos), 32):
        sub = map(str, pos[i:i+32][::-1])
        rst.append(hex(int(''.join(sub), 2)) + 'u')
    return rst

if __name__ == '__main__':
    img = render_image()
    img.save("/tmp/font.png")
    array = []
    for ch in range(START_ASCII, END_ASCII):
        array.append(get_char_bitmap(img, chr(ch)))
    print '#ifndef __HEADER_FONT__'
    print '#define __HEADER_FONT__'
    print '#define CHAR_WIDTH {}'.format(CHAR_WIDTH)
    print '#define CHAR_HEIGHT {}'.format(CHAR_HEIGHT)
    array = ['{' + ','.join(i) + '}' for i in array]
    print 'static const unsigned CHAR_FONT_BITMAP[{}][{}] = '.\
        format(END_ASCII -START_ASCII,
               (CHAR_WIDTH * CHAR_HEIGHT - 1) / 32 + 1), \
        '{', ','.join(array), '};'
    print '#endif'


