/*
 * $File: mem_opt.vh
 * $Date: Thu Nov 14 22:27:55 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */


`define MEM_OPT_WIDTH	3
`define MEM_OPT_NONE	3'b000
`define MEM_OPT_LW		3'b001
`define MEM_OPT_LBS		3'b010
`define MEM_OPT_LBU		3'b011
`define MEM_OPT_SW		3'b100
`define MEM_OPT_SB		3'b101

`define MEMWRITE_OPT_WIDTH	2
`define MEMWRITE_OPT_NONE	2'b00
`define MEMWRITE_OPT_BYTE	2'b01
`define MEMWRITE_OPT_WORD	2'b10

// vim: ft=verilog

