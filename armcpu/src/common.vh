/*
 * $File: common.vh
 * $Date: Thu Nov 21 17:53:24 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`define REGADDR_WIDTH	5
`define TLB_ENTRY_WIDTH	63
`define TLB_INDEX_WIDTH	4	// total 16 entries

`define TLB_NR_ENTRY	(1 << `TLB_INDEX_WIDTH)

// {enable, index, entry}
`define TLB_WRITE_STRUCT_WIDTH	(`TLB_ENTRY_WIDTH + `TLB_INDEX_WIDTH + 1)

`include "cp0_def.vh"

`define SYSTEM_STARTUP_ADDR	32'h80000000

// vim: ft=verilog


