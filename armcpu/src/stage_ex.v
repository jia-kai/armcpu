/*
 * $File: stage_ex.v
 * $Date: Sun Nov 17 15:51:20 2013 +0800
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

	input [`ID2EX_WIRE_WIDTH-1:0] interstage_id2ex,

	input [31:0] reg1_data,
	input [31:0] reg2_data,

	output do_branch,
	output [31:0] branch_dest,
	
	output [`EX2MEM_WIRE_WIDTH-1:0] interstage_ex2mem);

	`include "gencode/id2ex_extract_load.v"
	`include "gencode/ex2mem_extract_store.v"

	wire [31:0] result_from_alu;

	alu ualu(
		.opr1(reg1_data),
		.opr2(alu_src == `ALU_SRC_IMM ? alu_sa_imm : reg2_data),
		.sa_imm(alu_sa_imm),
		.opt(alu_opt), .result(result_from_alu), .illegal_opt());


	assign do_branch = (
		(branch_opt_id2ex == `BRANCH_ON_ALU_EQZ && !result_from_alu) ||
		(branch_opt_id2ex == `BRANCH_ON_ALU_NEZ && result_from_alu) ||
		(branch_opt_id2ex == `BRANCH_UNCOND));
	assign branch_dest = branch_dest_id2ex[0] ? reg2_data : branch_dest_id2ex;

	always @(posedge clk) begin
		if (rst) begin
			mem_opt_ex2mem <= `MEM_OPT_NONE;
			wb_reg_addr_ex2mem <= 0;
		end
		if (!stall) begin
			alu_result <= result_from_alu;
			wb_reg_addr_ex2mem <= wb_reg_addr_id2ex;
			mem_opt_ex2mem <= mem_opt_id2ex;
			mem_addr_ex2mem <= result_from_alu;
			mem_data_ex2mem <= reg2_data;
		end
	end

endmodule

