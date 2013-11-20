/*
 * $File: mem_opt.vh
 * $Date: Wed Nov 20 21:42:38 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`define MEM_OPT_WIDTH	4

// used for both stage_mem and mmu
`define MEM_OPT_NONE	4'b0000
`define MEM_OPT_LW		4'b0001
`define MEM_OPT_LBS		4'b0010
`define MEM_OPT_LBU		4'b0011
`define MEM_OPT_SW		4'b0100
`define MEM_OPT_SB		4'b0101


// used for stage_mem only

// operation on CP0 registers
`define MEM_OPT_WRITE_CP0	4'b0110
`define MEM_OPT_READ_CP0	4'b0111

`define MEM_OPT_WRITE_TLB_IDX	4'b1000



// check whether operation is read/write mem, not special reg or none
`define MEM_OPT_IS_READ(opt)	\
	((opt) == `MEM_OPT_LW || (opt) == `MEM_OPT_LBS || (opt) == `MEM_OPT_LBU)

`define MEM_OPT_IS_WRITE(opt)	((opt) == `MEM_OPT_SW || (opt) == `MEM_OPT_SB)

// vim: ft=verilog

