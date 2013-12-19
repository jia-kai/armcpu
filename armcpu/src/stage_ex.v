/*
 * $File: stage_ex.v
 * $Date: Thu Dec 19 20:31:06 2013 +0800
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

	output branch_flag,
	output [31:0] branch_dest,

	// whether write-back passed to mem is from alu result
	// used for forwarding
	output reg wb_from_alu,

	output reg mult_start,
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


	assign branch_flag = (
		(branch_opt_id2ex == `BRANCH_ON_ALU_EQZ && !result_from_alu) ||
		(branch_opt_id2ex == `BRANCH_ON_ALU_NEZ && result_from_alu) ||
		(branch_opt_id2ex == `BRANCH_UNCOND));
	assign branch_dest =
		branch_dest_id2ex[32] ? reg2_data : branch_dest_id2ex[31:0];


	always @(posedge clk) begin
		mult_start <= 1'b0;	// assert for one cycle
		if (rst || !stall || clear) begin
			mem_opt_ex2mem <= `MEM_OPT_NONE;
			wb_reg_addr_ex2mem <= 0;
			exc_code_ex2mem <= `EC_NONE;
			wb_from_alu <= 0;
		end
		if (!stall && !clear) begin
			wb_from_alu <= 0;
			exc_epc_ex2mem <= exc_epc_id2ex;
			exc_badvaddr_ex2mem <= exc_badvaddr_id2ex;
			if (exc_code_id2ex != `EC_NONE)
				exc_code_ex2mem <= exc_code_id2ex;
			else if (alu_illegal_opt) begin
				exc_code_ex2mem <= `EC_RI;
				exc_badvaddr_ex2mem <= {4'hf,
					{28-`ALU_OPT_WIDTH{1'b0}}, alu_opt};
			end
			else begin
				if (alu_opt == `ALU_OPT_MULT) begin
					mult_start <= 1'b1;
					mult_opr1 <= reg1_data;
					mult_opr2 <= reg2_data;
				end
				alu_result <= result_from_alu;
				wb_reg_addr_ex2mem <= wb_reg_addr_id2ex;
				mem_opt_ex2mem <= mem_opt_id2ex;
				mem_addr_ex2mem <= result_from_alu;
				mem_data_ex2mem <= reg2_data;
				wb_from_alu <= mem_opt_id2ex == `MEM_OPT_NONE;
			end
		end
	end

endmodule

