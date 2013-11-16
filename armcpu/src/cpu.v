/*
 * $File: cpu.v
 * $Date: Sat Nov 16 20:30:34 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`timescale 1ns/1ps

`include "common.vh"
`include "wb_src.vh"
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

	wire [31:0] instrmem_addr, instrmem_data,
		datamem_addr,
		datamem_data_to_mem, datamem_data_from_mem;
	wire mmu_busy;
	wire [`MEM_OPT_WIDTH-1:0] datamem_opt;

	wire [`IF2ID_WIRE_WIDTH-1:0] interstage_if2id;
	wire [`ID2EX_WIRE_WIDTH-1:0] interstage_id2ex;
	wire [`EX2MEM_WIRE_WIDTH-1:0] interstage_ex2mem;

	wire [`REGADDR_WIDTH-1:0] wb_addr;
	wire [31:0] wb_data;

	wire [`REGADDR_WIDTH-1:0] id2ex_reg1_addr, id2ex_reg2_addr, ex2mem_wb_reg_addr;
	wire [`WB_SRC_WIDTH-1:0] ex2mem_wb_src;
	wire [31:0] id2ex_reg1_data, id2ex_reg1_forward_data,
		id2ex_reg2_data, id2ex_reg2_forward_data;
	wire [31:0] ex2mem_alu_result = interstage_ex2mem[31:0];

	wire branch;
	wire [31:0] branch_dest;

	wire stall;

	assign {ex2mem_wb_src, ex2mem_wb_reg_addr} = 
		interstage_ex2mem[`WB_SRC_WIDTH+`REGADDR_WIDTH+31:32];

	forward ufwd1(
		.opr_reg_addr(id2ex_reg1_addr),
		.opr_reg_data(id2ex_reg1_data),
		.ex2mem_alu_result(ex2mem_alu_result),
		.ex2mem_wb_reg_addr(ex2mem_wb_reg_addr),
		.ex2mem_wb_src(ex2mem_wb_src),
		.regfile_write_addr(wb_addr),
		.regfile_write_data(wb_data),
		.forward_data(id2ex_reg1_forward_data));
	forward ufwd2(
		.opr_reg_addr(id2ex_reg2_addr),
		.opr_reg_data(id2ex_reg2_data),
		.ex2mem_alu_result(ex2mem_alu_result),
		.ex2mem_wb_reg_addr(ex2mem_wb_reg_addr),
		.ex2mem_wb_src(ex2mem_wb_src),
		.regfile_write_addr(wb_addr),
		.regfile_write_data(wb_data),
		.forward_data(id2ex_reg2_forward_data));

	stage_if uif(.clk(clk), .rst(rst), .stall(stall),
		.branch(branch), .branch_dest(branch_dest),
		.interstage_if2id(interstage_if2id), 
		.mem_addr(instrmem_addr), .mem_data(instrmem_data));

	stage_id uid(.clk(clk), .rst(rst), .stall(stall),
		.interstage_if2id(interstage_if2id),
		.reg_write_addr(wb_addr), .reg_write_data(wb_data),
		.reg1_addr(id2ex_reg1_addr), .reg1_data(id2ex_reg1_data),
		.reg2_addr(id2ex_reg2_addr), .reg2_data(id2ex_reg2_data),
		.interstage_id2ex(interstage_id2ex),
		.debug_out(debug_out));

	stage_ex uex(.clk(clk), .rst(rst), .stall(stall),
		.interstage_id2ex(interstage_id2ex),
		.reg1_data(id2ex_reg1_forward_data),
		.reg2_data(id2ex_reg2_forward_data),
		.do_branch(branch), .branch_dest(branch_dest),
		.interstage_ex2mem(interstage_ex2mem));

	stage_mem umem(.clk(clk), .rst(rst),
		.interstage_ex2mem(interstage_ex2mem),
		.wb_reg_addr(wb_addr), .wb_reg_data(wb_data),
		.set_stall(stall),
		.mmu_addr(datamem_addr),
		.mmu_data_in(datamem_data_from_mem),
		.mmu_data_out(datamem_data_to_mem),
		.mmu_opt(datamem_opt),
		.mmu_busy(mmu_busy));

	mmu ummu(.clk(clk), .rst(rst),
		.instr_addr(instrmem_addr), .instr_out(instrmem_data),
		.data_opt(datamem_opt), .data_addr(datamem_addr),
		.data_in(datamem_data_to_mem), .data_out(datamem_data_from_mem),
		.busy(mmu_busy),
		.dev_mem_addr(dev_mem_addr),
		.dev_mem_data_in(dev_mem_data_in),
		.dev_mem_data_out(dev_mem_data_out),
		.dev_mem_is_write(dev_mem_is_write),
		.dev_mem_busy(dev_mem_busy));
endmodule

