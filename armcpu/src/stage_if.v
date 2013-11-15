/*
 * $File: stage_if.v
 * $Date: Fri Nov 15 10:33:35 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`include "gencode/if2id_param.v"

// instruction fetch
module stage_if(
	input clk,
	input rst,
	input branch,
	input [31:0] branch_dest,

	output [`IF2ID_WIRE_WIDTH-1:0] interstage_if2id,
	
	// mem_data must be ready before posedge for the mem_addr
	output [31:0] mem_addr,
	input [31:0] mem_data);

	`include "gencode/if2id_extract_store.v"

	reg [31:0] pc;

	assign next_pc = pc + 4;
	assign mem_addr = branch ? branch_dest : pc;

	always @(posedge clk) begin
		if (rst)
			pc <= 0;
		else if (branch)
			pc <= branch_dest;
		else
			pc <= next_pc;
		instr <= mem_data;
		$display("fetch instruction: pc=%h instr=%b",
			next_pc, mem_data);
	end

endmodule

