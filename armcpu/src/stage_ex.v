/*
 * $File: stage_ex.v
 * $Date: Fri Nov 15 11:13:21 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

// instruction execution stage

`include "common.vh"
`include "alu_opt.vh"
`include "branch_opt.vh"
`include "wb_src.vh"
`include "mem_opt.vh"

`include "gencode/id2ex_param.v"
`include "gencode/ex2mem_param.v"

module stage_ex(
	input clk,
	input rst,

	input [`ID2EX_WIRE_WIDTH-1:0] interstage_id2ex,

	input reg1_forward,
	input [31:0] reg1_forward_data,
	input reg2_forward,
	input [31:0] reg2_forward_data,
	
	output [`EX2MEM_WIRE_WIDTH-1:0] interstage_ex2mem);

	`include "gencode/id2ex_extract_load.v"
	`include "gencode/ex2mem_extract_store.v"

	wire [31:0] result_from_alu;

	wire [31:0]
		reg1_actual_data = reg1_forward ? reg1_forward_data : reg1_data,
		reg2_actual_data = reg2_forward ? reg2_forward_data : reg2_data;

	alu alu_unit(
		.opr1(reg1_actual_data),
		.opr2(alu_src == `ALU_SRC_IMM ? alu_sa_imm : reg2_actual_data),
		.opt(alu_opt), .result(result_from_alu), .illegal_opt());

	always @(mem_opt)
		case(mem_opt)
			`MEM_OPT_SW:
				memwrite_opt = `MEMWRITE_OPT_WORD;
			`MEM_OPT_SB:
				memwrite_opt = `MEMWRITE_OPT_BYTE;
			default:
				memwrite_opt = `MEMWRITE_OPT_NONE;
		endcase

	// TODO: branch

	always @(posedge clk) begin
		alu_result <= result_from_alu;
		wb_src_ex2mem <= wb_src_id2ex;
		wb_reg_addr_ex2mem <= wb_reg_addr_id2ex;
		mem_addr <= reg1_actual_data + {{16{alu_sa_imm[15]}}, alu_sa_imm};
		mem_data <= reg2_actual_data;
	end

endmodule

