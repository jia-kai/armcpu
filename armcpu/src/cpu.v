/*
 * $File: cpu.v
 * $Date: Sat Nov 16 09:49:07 2013 +0800
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

	output [31:0] instrmem_addr,
	input [31:0] instrmem_data,

	output [31:0] debug_out);

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

	stage_mem umem(.clk(clk), .rst(rst), .stall(stall),
		.interstage_ex2mem(interstage_ex2mem),
		.wb_reg_addr(wb_addr), .wb_reg_data(wb_data),
		.set_stall(stall),
		.memdev_addr(),
		.memdev_data_in(32'b0),
		.memdev_data_out(),
		.memdev_opt(),
		.memdev_busy(1'b0));

endmodule

