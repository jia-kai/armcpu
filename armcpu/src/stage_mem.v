/*
 * $File: stage_mem.v
 * $Date: Fri Nov 15 10:12:28 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`include "common.vh"
`include "wb_src.vh"
`include "mem_opt.vh"
`include "gencode/ex2mem_param.v"

// memory read/write
module stage_mem(
	input clk,
	input rst,

	input [`EX2MEM_WIRE_WIDTH-1:0] interstage_ex2mem,

	output reg [`REGADDR_WIDTH-1:0] wb_reg_addr,
	output reg [31:0] wb_reg_data);

	`include "gencode/ex2mem_extract_load.v"

	// TODO: mem rw

	always @(posedge clk) begin
		wb_reg_addr <= wb_reg_addr_ex2mem;
		wb_reg_data <= wb_src_ex2mem == `WB_SRC_MEM ? 0 : alu_result;
	end

endmodule

