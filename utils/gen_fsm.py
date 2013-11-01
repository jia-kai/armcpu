#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# $File: gen_fsm.py
# $Date: Fri Nov 01 17:12:33 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

def gen_gray(tgt_len):
    return [i ^  (i >> 1) for i in range(tgt_len)]

if __name__ == '__main__':
    states = []
    try:
        while True:
            states.append(raw_input())
    except EOFError:
        pass

    nr_state = len(states)
    code =  gen_gray(nr_state)

    nr_bit = 1
    while (1 << nr_bit) < nr_state:
        nr_bit += 1

    code_fmt = "{}'b{{:0>{}}}".format(nr_bit, nr_bit).format

    print 'localparam STATE_WIDTH = {};'.format(nr_bit)
    print 'localparam\n\t\t' + ',\n\t\t'.join([
        states[i] + ' = ' +code_fmt(bin(code[i])[2:])
        for i in range(len(states))]) + ';'


