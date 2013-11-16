/*
 * $File: stage_mem.v
 * $Date: Sat Nov 16 09:52:48 2013 +0800
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
	input stall,

	input [`EX2MEM_WIRE_WIDTH-1:0] interstage_ex2mem,

	output reg [`REGADDR_WIDTH-1:0] wb_reg_addr,
	output reg [31:0] wb_reg_data,

	output set_stall,	// must be updated before negedge

	// connected to memory device
	output reg [31:0] memdev_addr,
	input [31:0] memdev_data_in,
	output reg [31:0] memdev_data_out,
	output reg [`MEM_OPT_WIDTH-1:0] memdev_opt,
	input memdev_busy);

	`include "gencode/ex2mem_extract_load.v"

	reg [1:0] state;
	localparam READY = 2'b00, WAIT_BUSY = 2'b01, WAIT_UNBUSY = 2'b10;

	assign set_stall = (state != READY);

	always @(posedge clk) begin
		wb_reg_addr <= 0;
		if (rst)
			state <= READY;
		else case (state)
			READY: begin
				if (!stall) begin
					wb_reg_addr <= wb_reg_addr_ex2mem;
					wb_reg_data <= alu_result;
					memdev_opt <= mem_opt_ex2mem;
					memdev_addr <= mem_addr;
					memdev_data_out <= alu_result;
					if (mem_opt_ex2mem != `MEM_OPT_NONE)
						state <= WAIT_BUSY;
				end
			end
			WAIT_BUSY:
				if (memdev_busy)
					state <= WAIT_UNBUSY;
			WAIT_UNBUSY:
				if (!memdev_busy) begin
					state <= READY;
					wb_reg_data <= memdev_data_in;
				end
		endcase
	end

endmodule

