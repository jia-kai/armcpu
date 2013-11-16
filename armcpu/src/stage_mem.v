/*
 * $File: stage_mem.v
 * $Date: Sat Nov 16 22:23:12 2013 +0800
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
	output reg [31:0] wb_reg_data,

	output set_stall,

	// interface to MMU
	output reg [31:0] mmu_addr,
	input [31:0] mmu_data_in,
	output reg [31:0] mmu_data_out,
	output reg [`MEM_OPT_WIDTH-1:0] mmu_opt,
	input mmu_busy);

	`include "gencode/ex2mem_extract_load.v"

	reg state;
	localparam READY = 1'b0, WAIT_UNBUSY = 1'b1;

	reg [`REGADDR_WIDTH-1:0] wb_reg_addr_latch;

	assign set_stall = (state == WAIT_UNBUSY);

	always @(negedge clk) begin
		if (rst) begin
			state <= READY;
			mmu_opt <= `MEM_OPT_NONE;
		end
		else case (state)
			READY: begin
				wb_reg_addr <= wb_reg_addr_ex2mem;
				wb_reg_data <= alu_result;
				mmu_opt <= mem_opt_ex2mem;
				mmu_addr <= mem_addr_ex2mem;
				mmu_data_out <= mem_data_ex2mem;
				if (mem_opt_ex2mem != `MEM_OPT_NONE) begin
					state <= WAIT_UNBUSY;
					wb_reg_addr_latch <= wb_reg_addr_ex2mem;
					wb_reg_addr <= 0;
				end
			end
			WAIT_UNBUSY: begin
				mmu_opt <= `MEM_OPT_NONE;
				if (!mmu_busy) begin
					wb_reg_data <= mmu_data_in;
					wb_reg_addr <= wb_reg_addr_latch;
					state <= READY;
				end
			end
		endcase
	end

endmodule

