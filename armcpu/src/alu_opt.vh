/*
 * $File: alu_opt.vh
 * $Date: Sun Nov 17 15:37:31 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */


// srouce of second ALU operand
`define ALU_SRC_WIDTH 1
`define ALU_SRC_IMM	1'b0
`define ALU_SRC_REG	1'b1

// ALU opt is same as R-type instructions
`define ALU_OPT_WIDTH	7
`define ALU_OPT_DISABLE	7'h00 

`define ALU_OPT_SLL_IMM	7'h00 // shift opr2 left using imm value
`define ALU_OPT_ADDU	7'h21
`define ALU_OPT_SUBU	7'h23
`define ALU_OPT_OR		7'h25
`define ALU_OPT_SETU	7'h40 // extended opt, set upper half of opr1

// vim: ft=verilog
