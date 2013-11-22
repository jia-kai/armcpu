/*
 * $File: alu_opt.vh
 * $Date: Wed Nov 20 00:32:27 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */


// source of second ALU operand
`define ALU_SRC_WIDTH 1
`define ALU_SRC_IMM	1'b0
`define ALU_SRC_REG	1'b1

// ALU opt is same as R-type instructions
`define ALU_OPT_WIDTH	7
`define ALU_OPT_DISABLE	7'h00

`define ALU_OPT_SLL_IMM	7'h00 // shift opr2 left using imm value
`define ALU_OPT_ADDU	7'h21
`define ALU_OPT_SUBU	7'h23
`define ALU_OPT_AND		7'h24
`define ALU_OPT_OR		7'h25
`define ALU_OPT_XOR		7'h26
`define ALU_OPT_NOR		7'h27
`define ALU_OPT_LT		7'h2A // signed less than
`define ALU_OPT_SETU	7'h40 // extended opt, set upper half of opr1
`define ALU_OPT_PASS_OPR1	7'h41 // extended opt, result <= first operand

// vim: ft=verilog
