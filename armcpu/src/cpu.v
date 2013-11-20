/*
 * $File: cpu.v
 * $Date: Wed Nov 20 14:23:45 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`timescale 1ns/1ps

`include "common.vh"
`include "branch_opt.vh"
`include "alu_opt.vh"
`include "mem_opt.vh"

`include "gencode/if2id_param.v"
`include "gencode/id2ex_param.v"
`include "gencode/ex2mem_param.v"

module cpu(
	input clk,
	input rst,

	// connected to physical memory controller
	output [31:0] dev_mem_addr,
	input [31:0] dev_mem_data_in,
	output [31:0] dev_mem_data_out,
	output dev_mem_is_write,
	input dev_mem_busy,

	output [31:0] debug_out);

	// -------------------------------------------------------------------

	wire [31:0] mmu_instr_addr, mmu_instr_data,
		mmu_data_addr, mmu_data_to_mmu, mmu_data_from_mmu;
	wire mmu_busy;
	wire [`EXC_CODE_WIDTH-1:0] mmu_exc_code;
	wire [`MEM_OPT_WIDTH-1:0] mmu_data_opt;

	wire [`IF2ID_WIRE_WIDTH-1:0] interstage_if2id;
	wire [`ID2EX_WIRE_WIDTH-1:0] interstage_id2ex;
	wire [`EX2MEM_WIRE_WIDTH-1:0] interstage_ex2mem;

	wire [`REGADDR_WIDTH-1:0] wb_addr;
	wire [31:0] wb_data;

	wire [`REGADDR_WIDTH-1:0] id2ex_reg1_addr, id2ex_reg2_addr, ex2mem_wb_reg_addr;
	wire [`MEM_OPT_WIDTH-1:0] ex2mem_mem_opt;
	assign ex2mem_wb_from_alu = ex2mem_mem_opt == `MEM_OPT_NONE;
	wire [31:0] id2ex_reg1_data, id2ex_reg1_forward_data,
		id2ex_reg2_data, id2ex_reg2_forward_data;
	wire [31:0] ex2mem_alu_result = interstage_ex2mem[31:0];

	wire branch_flag, exc_jmp_flag;
	reg jmp_flag;
	wire [31:0] branch_dest, exc_jmp_dest;
	reg [31:0] jmp_dest;

	wire [`CP0_REG_TOT_WIDTH-1:0] cp0_reg;

	wire stall, clear;

	assign {ex2mem_mem_opt, ex2mem_wb_reg_addr} = 
		interstage_ex2mem[`MEM_OPT_WIDTH+`REGADDR_WIDTH+31:32];

	always @(*) begin
		jmp_flag = 0;
		jmp_dest = 0;
		if (exc_jmp_flag) begin
			jmp_flag = 1;
			jmp_dest = exc_jmp_dest;
		end else if (branch_flag) begin
			jmp_flag = 1;
			jmp_dest = branch_dest;
		end
	end

	forward ufwd1(
		.opr_reg_addr(id2ex_reg1_addr),
		.opr_reg_data(id2ex_reg1_data),
		.ex2mem_alu_result(ex2mem_alu_result),
		.ex2mem_wb_reg_addr(ex2mem_wb_reg_addr),
		.ex2mem_wb_from_alu(ex2mem_wb_from_alu),
		.regfile_write_addr(wb_addr),
		.regfile_write_data(wb_data),
		.forward_data(id2ex_reg1_forward_data));
	forward ufwd2(
		.opr_reg_addr(id2ex_reg2_addr),
		.opr_reg_data(id2ex_reg2_data),
		.ex2mem_alu_result(ex2mem_alu_result),
		.ex2mem_wb_reg_addr(ex2mem_wb_reg_addr),
		.ex2mem_wb_from_alu(ex2mem_wb_from_alu),
		.regfile_write_addr(wb_addr),
		.regfile_write_data(wb_data),
		.forward_data(id2ex_reg2_forward_data));

	stage_if uif(.clk(clk), .rst(rst), .stall(stall), .clear(clear),
		.jmp_flag(jmp_flag), .jmp_dest(jmp_dest),
		.interstage_if2id(interstage_if2id), 
		.mem_addr(mmu_instr_addr), .mem_data(mmu_instr_data),
		.mem_exc_code(mmu_exc_code));

	stage_id uid(.clk(clk), .rst(rst), .stall(stall), .clear(clear),
		.interstage_if2id(interstage_if2id),
		.cur_if_branch(branch_flag),
		.reg_write_addr(wb_addr), .reg_write_data(wb_data),
		.reg1_addr(id2ex_reg1_addr), .reg1_data(id2ex_reg1_data),
		.reg2_addr(id2ex_reg2_addr), .reg2_data(id2ex_reg2_data),
		.interstage_id2ex(interstage_id2ex),
		.debug_out(debug_out));

	stage_ex uex(.clk(clk), .rst(rst), .stall(stall), .clear(clear),
		.interstage_id2ex(interstage_id2ex),
		.reg1_data(id2ex_reg1_forward_data),
		.reg2_data(id2ex_reg2_forward_data),
		.branch_flag(branch_flag), .branch_dest(branch_dest),
		.interstage_ex2mem(interstage_ex2mem));

	stage_mem umem(.clk(clk), .rst(rst),
		.interstage_ex2mem(interstage_ex2mem),
		.wb_reg_addr(wb_addr), .wb_reg_data(wb_data),
		.set_stall(stall), .set_clear(clear),
		.exc_jmp_flag(exc_jmp_flag), .exc_jmp_dest(exc_jmp_dest),
		.cp0_reg(cp0_reg),
		.int_req(8'b0), .int_ack(),
		.mmu_addr(mmu_data_addr),
		.mmu_data_in(mmu_data_from_mmu),
		.mmu_data_out(mmu_data_to_mmu),
		.mmu_opt(mmu_data_opt),
		.mmu_exc_code(mmu_exc_code),
		.mmu_busy(mmu_busy));

	mmu ummu(.clk(clk), .rst(rst),
		.instr_addr(mmu_instr_addr), .instr_out(mmu_instr_data),
		.data_opt(mmu_data_opt), .data_addr(mmu_data_addr),
		.data_in(mmu_data_to_mmu), .data_out(mmu_data_from_mmu),
		.busy(mmu_busy),
		.exc_code(mmu_exc_code),
		.dev_mem_addr(dev_mem_addr),
		.dev_mem_data_in(dev_mem_data_in),
		.dev_mem_data_out(dev_mem_data_out),
		.dev_mem_is_write(dev_mem_is_write),
		.dev_mem_busy(dev_mem_busy));
endmodule

