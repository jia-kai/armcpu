#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# $File: gencode.py
# $Date: Sat Nov 16 23:33:01 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

import os
import os.path
from collections import namedtuple

trans_if2id = [
    ('next_pc', 32),
    ('instr', 32)
]

trans_id2ex = [
    ('branch_opt_id2ex', 'BRANCH_OPT_WIDTH'),
    ('branch_dest_id2ex', 32),

    ('alu_sa_imm', 32), # shift amout, or immediate opr
    ('alu_src', 'ALU_SRC_WIDTH'),
    ('alu_opt', 'ALU_OPT_WIDTH'),

    ('mem_opt_id2ex', 'MEM_OPT_WIDTH'),

    ('wb_reg_addr_id2ex', 'REGADDR_WIDTH')
]

trans_ex2mem = [
    ('mem_addr_ex2mem', 32),
    ('mem_data_ex2mem', 32),

    ('mem_opt_ex2mem', 'MEM_OPT_WIDTH'),
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

    def gen_var_def(t, fout):
        for i in desc:
            var, width = i
            if isinstance(width, int):
                width -= 1
            else:
                width = '`{}-1'.format(width)
            print >>fout, '{} [{}:0] {};'.format(t, width, var)

    with open('{}_extract_store.v'.format(name), 'w') as fout:
        gen_var_def('reg', fout)
        print >>fout, 'assign interstage_{} = {};'.format(
                name, var_group_list)

    with open('{}_extract_load.v'.format(name), 'w') as fout:
        gen_var_def('wire', fout)
        print >>fout, 'assign {} = interstage_{};'.format(
                var_group_list, name)

if __name__ == '__main__':
    os.chdir(os.path.dirname(__file__))
    for i, j in trans:
        gen_code(i, j)

