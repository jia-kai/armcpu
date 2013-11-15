/*
 * $File: branch_opt.vh
 * $Date: Thu Nov 14 19:24:18 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`define BRANCH_OPT_WIDTH	2
`define BRANCH_NONE		2'b00
`define BRANCH_ON_ALU_EQZ	2'b01	// branch on alu result = 0
`define BRANCH_ON_ALU_NEZ	2'b10	// branch on alu result != 0
`define BRANCH_UNCOND		2'b11	// unconditional jump

// vim: ft=verilog

