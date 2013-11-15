/*
 * $File: alu_opt.vh
 * $Date: Thu Nov 14 19:52:06 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */


// srouce of second ALU operand
`define ALU_SRC_WIDTH 1
`define ALU_SRC_IMM	1'b0
`define ALU_SRC_REG	1'b1

// ALU opt is same as R-type instructions
`define ALU_OPT_WIDTH	6
`define ALU_OPT_DISABLE	6'h00
`define ALU_OPT_ADDU	6'h21

// vim: ft=verilog
