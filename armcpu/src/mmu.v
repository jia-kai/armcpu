/*
 * $File: mmu.v
 * $Date: Sat Nov 16 17:23:43 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`include "mem_opt.vh"

// memory management unit
module mmu(
	input clk,
	input rst,
	input [31:0] instr_addr,
	output [31:0] instr_out,

	// data_in would be latched on posedge on data_opt is write,
	// but data_addr would not
	// data_opt should only be set for one cycle
	input [`MEM_OPT_WIDTH-1:0] data_opt,
	input [31:0] data_addr,
	input [31:0] data_in,
	// data_out is valid for one cycle after busy is deasserted
	output reg [31:0] data_out,

	// busy would be asserted immediately after data_opt != NONE,
	// before next clock edge
	output busy,
	
	// interface to physical memory controller
	// it is required to response before next posedge
	// and also latch both data and addr, if multiple-cycle for one operation
	// needed
	output [31:0] dev_mem_addr,
	input [31:0] dev_mem_data_in,
	output reg [31:0] dev_mem_data_out,
	output dev_mem_is_write,
	input dev_mem_busy);

	assign instr_out = dev_mem_data_in;

	always @(*)
		if (data_opt == `MEM_OPT_LW)
			data_out = dev_mem_data_in;
		else if (data_opt == `MEM_OPT_LBS)
			data_out = {{24{dev_mem_data_in[7]}}, dev_mem_data_in[7:0]};
		else if (data_opt == `MEM_OPT_LBU)
			data_out = {{24'b0}, dev_mem_data_in[7:0]};
		else
			data_out = 0;


	localparam READ = 2'b00, WRITE_SB = 2'b01, WRITE_DO_WRITE = 2'b10;
	reg [1:0] state;

	// if multiple-cycle read is needed, dev_mem_busy should be set before
	// next posedge, so busy is also set
	assign busy =
		(state != READ || dev_mem_busy || `MEM_OPT_IS_WRITE(data_opt));

	assign dev_mem_addr =
		(state == READ && data_opt == `MEM_OPT_NONE ? instr_addr : data_addr);

	assign dev_mem_is_write = state == WRITE_DO_WRITE;

	always @(posedge clk)
		if (rst)
			state <= READ;
		else case (state)
			READ: if (!dev_mem_busy && data_opt != `MEM_OPT_NONE) begin
				dev_mem_data_out <= data_in;
				if (data_opt == `MEM_OPT_SB)
					state <= WRITE_SB;
				else if (data_opt == `MEM_OPT_SW)
					state <= WRITE_DO_WRITE;
			end
			WRITE_SB: begin
				dev_mem_data_out[31:8] <= dev_mem_data_in[31:8];
				state <= WRITE_DO_WRITE;
			end
			WRITE_DO_WRITE:
				state <= READ;
			default:
				state <= READ;
		endcase

endmodule

