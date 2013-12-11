/*
 * $File: stage_if.v
 * $Date: Wed Nov 20 15:55:07 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`include "gencode/if2id_param.v"
`include "common.vh"

// instruction fetch
module stage_if(
	input clk,
	input rst,
	input stall,
	input clear,

	input jmp_flag,
	input [31:0] jmp_dest,

	output [`IF2ID_WIRE_WIDTH-1:0] interstage_if2id,
	
	// mem_data must be asynchronously updated for mem_addr
	output [31:0] mem_addr,
	input [31:0] mem_data,
	input [`EXC_CODE_WIDTH-1:0] mem_exc_code);

	`include "gencode/if2id_extract_store.v"

	reg [31:0] pc;

	assign mem_addr = jmp_flag ? jmp_dest : pc;
	wire [31:0] mem_addr_plus_4 = mem_addr + 4;

	always @(posedge clk) begin
		if (rst) begin
			instr <= 0;
			pc <= `SYSTEM_STARTUP_ADDR;
			exc_code_if2id <= `EC_NONE;
		end else if (!stall) begin
			pc <= mem_addr_plus_4;
			next_pc <= mem_addr_plus_4;
			exc_code_if2id <= `EC_NONE;
			if (clear) 
				instr <= 0;
			else if (mem_exc_code != `EC_NONE) begin
				exc_code_if2id <= mem_exc_code;
				exc_addr_if2id <= mem_addr;
				instr <= 0;
			end else
				instr <= mem_data;
		end
	end

endmodule

