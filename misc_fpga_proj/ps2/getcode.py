#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# $File: getcode.py
# $Date: Fri Dec 20 17:42:30 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>


def get_noshift_code_map():
    rst = [(0x5A, '\r'), (0x29, ' '), (0x66, '\b')]
    with open('scancodes2_subset.txt') as fin:
        data = fin.readlines()
    for i in data:
        i = [i.strip().encode('ascii')
             for i in i.decode('utf-8').strip().split(u'│') if i.strip()]
        rst.append((int(i[1], 16), i[0].lower()))
    return rst

def get_shift_charmap():
    rst = {i: i.upper() for i in map(chr, range(ord('a'), ord('z') + 1))}
    num_upper = ')!@#$%^&*('
    for i in range(10):
        rst[str(i)] = num_upper[i]
    misc_upper = r'~_+|}{:"?><'
    misc_lower = r"`-=\][;'/.,"
    assert len(misc_lower) == len(misc_upper)
    rst.update({misc_lower[i]: misc_upper[i] for i in range(len(misc_lower))})
    return rst

def gen_all(gen_state):
    noshift_code_map = get_noshift_code_map()
    shift_ch_map = get_shift_charmap()
    for code, ch in noshift_code_map:
        ch_shift = shift_ch_map.get(ch)
        if not ch_shift:
            gen_state('x', code, ch)
        else:
            gen_state(0, code, ch)
            gen_state(1, code, ch_shift)


def main_verilog(fout):
    def gen_state(shift, code, char):
        code = bin(code)[2:]
        code = '0' * (8 - len(code)) + code
        print >>fout, "9'b{}{}: cur_pressed_ascii = 8'h{};".format(
            shift, code, hex(ord(char))[2:])

    print >>fout, 'always @(*)'
    print >>fout, 'casex ({shift_pressed, cur_pressed})'
    gen_all(gen_state)
    print >>fout, "default: cur_pressed_ascii = 8'b0;"
    print >>fout, 'endcase'

def main_c(fout):
    state_map = dict()
    def gen_state(shift, code, char):
        if shift == 'x':
            gen_state(0, code, char)
            gen_state(1, code, char)
            return
        assert code > 0 and code < 127
        code = (shift << 7) | code
        state_map[code] = ord(char)

    gen_all(gen_state)
    print 'number of encodings:', len(state_map)

    state_map = [state_map.get(i, 0) for i in range(256)]
    print >>fout, 'static const char KEYCODE_MAP[256] = {', \
        ','.join(map(str, state_map)), \
        '};'


if __name__ == '__main__':
    with open('ps2_code.vh', 'w') as fout:
        main_verilog(fout)
    with open('ps2_code.h', 'w') as fout:
        main_c(fout)

