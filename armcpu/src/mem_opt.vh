/*
 * $File: mem_opt.vh
 * $Date: Sat Nov 16 11:51:11 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`define MEM_OPT_WIDTH	3
`define MEM_OPT_NONE	3'b000
`define MEM_OPT_LW		3'b001
`define MEM_OPT_LBS		3'b010
`define MEM_OPT_LBU		3'b011
`define MEM_OPT_SW		3'b100
`define MEM_OPT_SB		3'b101

`define MEM_OPT_IS_READ(opt)	\
	((opt) == `MEM_OPT_LW || (opt) == `MEM_OPT_LBS || (opt) == `MEM_OPT_LBU)

`define MEM_OPT_IS_WRITE(opt)	((opt) == `MEM_OPT_SW || (opt) == `MEM_OPT_SB)

// vim: ft=verilog

