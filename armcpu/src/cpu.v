/*
 * $File: cpu.v
 * $Date: Fri Nov 15 10:43:26 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

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
	input [31:0] instrmem_data);

	wire [`IF2ID_WIRE_WIDTH-1:0] interstage_if2id;
	wire [`ID2EX_WIRE_WIDTH-1:0] interstage_id2ex;
	wire [`EX2MEM_WIRE_WIDTH-1:0] interstage_ex2mem;

	wire [`REGADDR_WIDTH-1:0] wb_addr;
	wire [31:0] wb_data;

	stage_if uif(.clk(clk), .rst(rst), .branch(1'b0), .branch_dest(32'b0),
		.interstage_if2id(interstage_if2id), 
		.mem_addr(instrmem_addr), .mem_data(instrmem_data));

	stage_id uid(.clk(clk), .rst(rst), .interstage_if2id(interstage_if2id),
		.reg_write_addr(wb_addr), .reg_write_data(wb_data),
		.reg1_addr(), .reg2_addr(), .interstage_id2ex(interstage_id2ex));

	stage_ex uex(.clk(clk), .rst(rst), .interstage_id2ex(interstage_id2ex),
		.reg1_forward(1'b0), .reg1_forward_data(32'b0),
		.reg2_forward(1'b0), .reg2_forward_data(32'b0),
		.interstage_ex2mem(interstage_ex2mem));

	stage_mem umem(.clk(clk), .rst(rst), .interstage_ex2mem(interstage_ex2mem),
		.wb_reg_addr(wb_addr), .wb_reg_data(wb_data));

endmodule

