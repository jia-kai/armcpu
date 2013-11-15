/*
 * $File: stage_id.v
 * $Date: Fri Nov 15 18:28:51 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`timescale 1ns/1ps

`include "alu_opt.vh"
`include "branch_opt.vh"
`include "wb_src.vh"
`include "mem_opt.vh"
`include "common.vh"

`include "gencode/if2id_param.v"
`include "gencode/id2ex_param.v"

// instruction decode
module stage_id(
	input clk,
	input rst,

	input [`IF2ID_WIRE_WIDTH-1:0] interstage_if2id,

	// since reg[0] is always 0, no need for write enable signal;
	// just set reg_write_addr = 0 to disable write
	input [`REGADDR_WIDTH-1:0] reg_write_addr,
	input [31:0] reg_write_data,

	output reg [`REGADDR_WIDTH-1:0] reg1_addr,
	output reg [`REGADDR_WIDTH-1:0] reg2_addr,

	output [`ID2EX_WIRE_WIDTH-1:0] interstage_id2ex,
	output [31:0] debug_out);

	`include "gencode/if2id_extract_load.v"
	`include "gencode/id2ex_extract_store.v"

	wire [31:0] rf_data1, rf_data2;

	wire [5:0] instr_opcode = instr[31:26];
	wire [4:0] instr_rs = instr[25:21], instr_rt = instr[20:16],
				instr_rd = instr[15:11],
				instr_sa = instr[10:6],
				instr_func = instr[5:0];
	wire [15:0] instr_imm = instr[15:0];

	wire [31:0] branch_absolute_addr =
		next_pc + {{14{instr_imm[15]}}, instr_imm, 2'b00};

	register_file uregfile(.clk(clk), .rst(rst),
		.read1_addr(instr_rs), .read2_addr(instr_rt),
		.write_addr(reg_write_addr), 
		.data_in(reg_write_data),
		.data_out1(rf_data1), .data_out2(rf_data2),
		.debug_out(debug_out));

	task assign_reg1; begin
		reg1_addr <= instr_rs;
		reg1_data <= rf_data1;
	end endtask

	task assign_reg2; begin
		reg2_addr <= instr_rt;
		reg2_data <= rf_data2;
	end endtask

	// process rtype instructions
	task proc_rtype; begin
		wb_src_id2ex <= `WB_SRC_ALU;
		wb_reg_addr_id2ex <= instr_rd;
		assign_reg1();
		assign_reg2();
		alu_sa_imm <= instr_sa;
		alu_src <= `ALU_SRC_REG;
		alu_opt <= instr_func;
	end endtask

	// process itype instructions
	task proc_itype; begin
		alu_src <= `ALU_SRC_IMM;
		alu_sa_imm <= instr_imm;
		case (instr_opcode)
			6'h04: begin // BEQ
				assign_reg1();
				assign_reg2();
				alu_src <= `ALU_SRC_REG;
				alu_opt <= `ALU_OPT_SUBU;
				branch_opt_id2ex <= `BRANCH_ON_ALU_EQZ;
				branch_dest_id2ex <= branch_absolute_addr;
			end
			6'h09: begin // ADDIU
				assign_reg1();
				wb_src_id2ex <= `WB_SRC_ALU;
				wb_reg_addr_id2ex <= instr_rt;
				alu_opt <= `ALU_OPT_ADDU;
			end
			default:
				; // TODO: exception
		endcase
	end endtask

	always @(posedge clk) begin
		branch_opt_id2ex <= `BRANCH_NONE;
		wb_reg_addr_id2ex <= 0;
		alu_opt <= `ALU_OPT_DISABLE;
		reg1_addr <= 0;
		reg2_addr <= 0;
		mem_opt <= `MEM_OPT_NONE;
		case (instr_opcode)
			6'b000000:
				proc_rtype();
			// TODO: coprocessor
			default:
				proc_itype();
		endcase
		$display("  < -- id -- > time=%g got instruction: next_pc=%h instr=%b",
			$time, next_pc, instr);
	end

endmodule

