/*
 * $File: alu_opt.vh
 * $Date: Fri Nov 15 14:29:56 2013 +0800
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
`define ALU_OPT_SUBU	6'h23

// vim: ft=verilog
