/*
 * $File: stage_if.v
 * $Date: Fri Dec 20 15:17:31 2013 +0800
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

	input has_int_pending,

	input jmp_flag,
	input [31:0] jmp_dest,

	output [`IF2ID_WIRE_WIDTH-1:0] interstage_if2id,
	
	// mem_data must be asynchronously updated for mem_addr
	output reg [31:0] mem_addr,
	input [31:0] mem_data,
	input [`EXC_CODE_WIDTH-1:0] mem_exc_code);

	`include "gencode/if2id_extract_store.v"

	wire [31:0] mem_addr_plus_4 = mem_addr + 4;

	// this latch is used to improve timing, otherwise xilinx may fail to meet
	// constraints
	always @(negedge clk)
		mem_addr <= jmp_flag ? jmp_dest : next_pc;

	always @(posedge clk) begin
		if (rst) begin
			instr <= 0;
			next_pc <= `SYSTEM_STARTUP_ADDR;
			exc_code_if2id <= `EC_NONE;
		end else if (!stall) begin
			exc_code_if2id <= `EC_NONE;
			exc_addr_if2id <= mem_addr;
			instr <= 0;
			if (!clear) begin
				next_pc <= mem_addr_plus_4;
				if (mem_exc_code != `EC_NONE)
					exc_code_if2id <= mem_exc_code;
				else if (has_int_pending)
					exc_code_if2id <= `EC_INT;
				else
					instr <= mem_data;
			end
		end
	end

endmodule

