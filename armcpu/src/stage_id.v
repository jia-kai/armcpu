/*
 * $File: stage_id.v
 * $Date: Sun Nov 17 15:50:38 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`timescale 1ns/1ps

`include "alu_opt.vh"
`include "branch_opt.vh"
`include "mem_opt.vh"
`include "common.vh"

`include "gencode/if2id_param.v"
`include "gencode/id2ex_param.v"

// instruction decode
module stage_id(
	input clk,
	input rst,
	input stall,

	input [`IF2ID_WIRE_WIDTH-1:0] interstage_if2id,

	// since reg[0] is always 0, no need for write enable signal;
	input [`REGADDR_WIDTH-1:0] reg_write_addr,
	input [31:0] reg_write_data,

	output reg [`REGADDR_WIDTH-1:0] reg1_addr,
	output reg [31:0] reg1_data,
	output reg [`REGADDR_WIDTH-1:0] reg2_addr,
	output reg [31:0] reg2_data,

	output [`ID2EX_WIRE_WIDTH-1:0] interstage_id2ex,
	output [31:0] debug_out);

	`include "gencode/if2id_extract_load.v"
	`include "gencode/id2ex_extract_store.v"

	wire [31:0] rf_data1, rf_data2;

	wire [5:0] instr_opcode = instr[31:26];
	wire [5:0] instr_func = instr[5:0];
	wire [4:0] instr_rs = instr[25:21], instr_rt = instr[20:16],
				instr_rd = instr[15:11], instr_sa = instr[10:6];
	wire [15:0] instr_imm = instr[15:0];
	wire [31:0] instr_imm_signext = {{16{instr_imm[15]}}, instr_imm},
				instr_imm_unsignext = {16'b0, instr_imm};

	wire [31:0] branch_absolute_addr =
		next_pc + {instr_imm_signext[29:0], 2'b00};

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
		wb_reg_addr_id2ex <= instr_rd;
		assign_reg1();
		assign_reg2();
		alu_sa_imm <= instr_sa;
		alu_src <= `ALU_SRC_REG;
		alu_opt <= instr_func;
	end endtask

	task alu_from_reg(input [`ALU_OPT_WIDTH-1:0] opt); begin
		alu_src <= `ALU_SRC_REG;
		alu_opt <= opt;
	end endtask

	task alu_from_imm(input [`ALU_OPT_WIDTH-1:0] opt, input [31:0] imm); begin
		alu_src <= `ALU_SRC_IMM;
		alu_opt <= opt;
		alu_sa_imm <= imm;
	end endtask


	task mem_opt(input [`MEM_OPT_WIDTH-1:0] opt); begin
		assign_reg1();
		assign_reg2();
		alu_from_imm(`ALU_OPT_ADDU, instr_imm_signext);
		if (`MEM_OPT_IS_READ(opt))
			wb_reg_addr_id2ex <= instr_rt;
		mem_opt_id2ex <= opt;
	end endtask

	task wb_with_alu_imm(input [`ALU_OPT_WIDTH-1:0] alu_opt, input [31:0] imm); begin
		wb_reg_addr_id2ex <= instr_rt;
		assign_reg1();
		alu_from_imm(alu_opt, imm);
	end endtask

	// process itype instructions
	task proc_itype; begin
		case (instr_opcode)
			6'h04: begin // BEQ
				assign_reg1();
				assign_reg2();
				alu_from_reg(`ALU_OPT_SUBU);
				branch_opt_id2ex <= `BRANCH_ON_ALU_EQZ;
				branch_dest_id2ex <= branch_absolute_addr;
			end
			6'h09:	// ADDIU
				wb_with_alu_imm(`ALU_OPT_ADDU, instr_imm_signext);
			6'h0d:	// ORI
				wb_with_alu_imm(`ALU_OPT_OR, instr_imm_unsignext);
			6'h0f:	// LUI
				wb_with_alu_imm(`ALU_OPT_SETU, {instr_imm, 16'b0});
			6'h23:	// LW
				mem_opt(`MEM_OPT_LW);
			6'h2b:	// SW
				mem_opt(`MEM_OPT_SW);
			default:
				$warning("invalid instruction: %h", instr); // TODO: exception
		endcase
	end endtask

	task proc_instr_j; begin
		branch_opt_id2ex <= `BRANCH_UNCOND;
		branch_dest_id2ex <= {next_pc[31:28], instr[25:0], 2'b00};
	end endtask

    task proc_instr_jr; begin
        branch_opt_id2ex <= `BRANCH_UNCOND;
        branch_dest_id2ex <= 32'b1; // set to reg2_data
		reg2_addr <= instr_rs;
		reg2_data <= rf_data1;
    end endtask

	task reset; begin
		branch_opt_id2ex <= `BRANCH_NONE;
		wb_reg_addr_id2ex <= 0;
		alu_opt <= `ALU_OPT_DISABLE;
		reg1_addr <= 0;
		reg2_addr <= 0;
		mem_opt_id2ex <= `MEM_OPT_NONE;
	end endtask

	always @(posedge clk) begin
		if (rst)
			reset();
		else if (!stall) begin
			reset();
			case (instr_opcode)
				6'b000000:
                    if (instr_func == 6'h08) 
                        proc_instr_jr();
                    else
                        proc_rtype();
				6'b000010:
					proc_instr_j();
				default:
					proc_itype();
			endcase
			$display("\033[32m < -- id -- > time=%g got instruction: pc=%h instr=%h \033[0m",
				$time, next_pc - 4, instr);
		end
	end

endmodule

