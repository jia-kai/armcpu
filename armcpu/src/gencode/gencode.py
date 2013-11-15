#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# $File: gencode.py
# $Date: Fri Nov 15 09:55:23 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

import os
import os.path
from collections import namedtuple

noreg = namedtuple('noreg', ['var', 'width'])

trans_if2id = [
    noreg('next_pc', 32),
    ('instr', 32)
]

trans_id2ex = [
    ('branch_opt', 'BRANCH_OPT_WIDTH'),
    ('branch_dest', 32),

    ('alu_sa_imm', 16), # shift amout, or immediate opr
    ('alu_src', 'ALU_SRC_WIDTH'),
    ('alu_opt', 'ALU_OPT_WIDTH'),

    ('mem_opt', 'MEM_OPT_WIDTH'),

    ('reg1_data', 32),
    ('reg2_data', 32),

    ('wb_src_id2ex', 'WB_SRC_WIDTH'),
    ('wb_reg_addr_id2ex', 'REGADDR_WIDTH')
]

trans_ex2mem = [
    ('memwrite_opt', 'MEMWRITE_OPT_WIDTH'),
    ('mem_addr', 32),
    ('mem_data', 32),

    ('wb_src_ex2mem', 'WB_SRC_WIDTH'),
    ('wb_reg_addr_ex2mem', 'REGADDR_WIDTH'),

    ('alu_result', 32)
]

trans = [
    ('if2id', trans_if2id),
    ('id2ex', trans_id2ex),
    ('ex2mem', trans_ex2mem)
]

def gen_code(name, desc):
    width_num = 0
    width_list = []
    for _, width in desc:
        if isinstance(width, int):
            width_num += width
        else:
            width_list.append('`' + width)
    width_list.append(str(width_num))
    with open('{}_param.v'.format(name), 'w') as fout:
        print >>fout, '`define {}_WIRE_WIDTH ({})'.format(
                name.upper(), '+'.join(width_list))

    var_group_list = '{{ {} }}'.format(','.join(var for var, _ in desc))
    with open('{}_extract_store.v'.format(name), 'w') as fout:
        for i in desc:
            var, width = i
            if isinstance(width, int):
                width -= 1
            else:
                width = '`{}-1'.format(width)
            if isinstance(i, noreg):
                print >>fout, 'wire [{}:0] {};'.format(width, var)
            else:
                print >>fout, 'reg [{}:0] {};'.format(width, var)

        print >>fout, 'assign interstage_{} = {};'.format(
                name, var_group_list)

    with open('{}_extract_load.v'.format(name), 'w') as fout:
        item = []
        for i in desc:
            var, width = i
            if isinstance(width, int):
                width -= 1
            else:
                width = '`{}-1'.format(width)
            print >>fout, 'wire [{}:0] {};'.format(width, var)

        print >>fout, 'assign {} = interstage_{};'.format(
                var_group_list, name)

if __name__ == '__main__':
    os.chdir(os.path.dirname(__file__))
    for i, j in trans:
        gen_code(i, j)

