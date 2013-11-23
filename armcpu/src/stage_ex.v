/*
 * $File: stage_ex.v
 * $Date: Sat Nov 23 19:32:56 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`timescale 1ns/1ps

`include "common.vh"
`include "alu_opt.vh"
`include "branch_opt.vh"
`include "mem_opt.vh"

`include "gencode/id2ex_param.v"
`include "gencode/ex2mem_param.v"

// instruction execution stage
module stage_ex(
	input clk,
	input rst,
	input stall,
	input clear,

	input [`ID2EX_WIRE_WIDTH-1:0] interstage_id2ex,

	input [31:0] reg1_data,
	input [31:0] reg2_data,

	// updated on negedge, regardness of stall
	output reg branch_flag,
	output reg [31:0] branch_dest,

	output reg [31:0] mult_opr1,
	output reg [31:0] mult_opr2,
	
	output [`EX2MEM_WIRE_WIDTH-1:0] interstage_ex2mem);

	// ------------------------------------------------------------------

	`include "gencode/id2ex_extract_load.v"
	`include "gencode/ex2mem_extract_store.v"

	wire [31:0] result_from_alu;
	wire alu_illegal_opt;

	alu ualu(
		.opr1(reg1_data),
		.opr2(alu_src == `ALU_SRC_IMM ? alu_sa_imm : reg2_data),
		.sa_imm(alu_sa_imm),
		.opt(alu_opt), .result(result_from_alu),
		.illegal_opt(alu_illegal_opt));


	assign branch_flag_comb = (
		(branch_opt_id2ex == `BRANCH_ON_ALU_EQZ && !result_from_alu) ||
		(branch_opt_id2ex == `BRANCH_ON_ALU_NEZ && result_from_alu) ||
		(branch_opt_id2ex == `BRANCH_UNCOND));
	wire [31:0] branch_dest_comb =
		branch_dest_id2ex[32] ? reg2_data : branch_dest_id2ex;

	always @(negedge clk) begin
		branch_flag <= branch_flag_comb;
		branch_dest <= branch_dest_comb;
	end

	always @(posedge clk) begin
		if (rst || !stall || clear) begin
			mem_opt_ex2mem <= `MEM_OPT_NONE;
			wb_reg_addr_ex2mem <= 0;
			exc_code_ex2mem <= `EC_NONE;
		end
		if (!stall && !clear) begin
			exc_epc_ex2mem <= exc_epc_id2ex;
			exc_badvaddr_ex2mem <= exc_badvaddr_id2ex;
			if (exc_code_id2ex != `EC_NONE)
				exc_code_ex2mem <= exc_code_id2ex;
			else if (alu_illegal_opt)
				exc_code_ex2mem <= `EC_RI;
			else begin
				if (alu_opt == `ALU_OPT_MULT) begin
					mult_opr1 <= reg1_data;
					mult_opr2 <= reg2_data;
				end
				alu_result <= result_from_alu;
				wb_reg_addr_ex2mem <= wb_reg_addr_id2ex;
				mem_opt_ex2mem <= mem_opt_id2ex;
				mem_addr_ex2mem <= result_from_alu;
				mem_data_ex2mem <= reg2_data;
			end
		end
	end

endmodule

