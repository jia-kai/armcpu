/*
 * $File: stage_if.v
 * $Date: Sat Nov 16 20:25:11 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`include "gencode/if2id_param.v"

// instruction fetch
module stage_if(
	input clk,
	input rst,
	input stall,
	input branch,
	input [31:0] branch_dest,

	output [`IF2ID_WIRE_WIDTH-1:0] interstage_if2id,
	
	// mem_data must be asynchronously updated for mem_addr
	output [31:0] mem_addr,
	input [31:0] mem_data);

	`include "gencode/if2id_extract_store.v"

	reg [31:0] pc;

	assign mem_addr = branch ? branch_dest : pc;
    wire [31:0] mem_addr_plus_4 = mem_addr + 4;

	always @(posedge clk) begin
		if (rst) begin
			instr <= 0;
			pc <= 0;
		end else if (!stall) begin
            pc <= mem_addr_plus_4;
			next_pc <= mem_addr_plus_4;
			instr <= mem_data;
		end
	end

endmodule

