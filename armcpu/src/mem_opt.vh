/*
 * $File: mem_opt.vh
 * $Date: Wed Nov 20 10:59:50 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`define MEM_OPT_WIDTH	3
`define MEM_OPT_NONE	3'b000
`define MEM_OPT_LW		3'b001
`define MEM_OPT_LBS		3'b010
`define MEM_OPT_LBU		3'b011
`define MEM_OPT_SW		3'b100
`define MEM_OPT_SB		3'b101

// operation on special registers
`define MEM_OPT_WRITE_SPECIAL	3'b110
`define MEM_OPT_READ_SPECIAL	3'b111


// check whether operation is read/write mem, not special reg or none
`define MEM_OPT_IS_READ(opt)	\
	((opt) == `MEM_OPT_LW || (opt) == `MEM_OPT_LBS || (opt) == `MEM_OPT_LBU)

`define MEM_OPT_IS_WRITE(opt)	((opt) == `MEM_OPT_SW || (opt) == `MEM_OPT_SB)

// vim: ft=verilog

