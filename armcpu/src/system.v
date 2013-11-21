/*
 * $File: system.v
 * $Date: Thu Nov 21 18:40:25 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */


// top-level system
module system
	#(parameter CLK_MEM_FREQ = 50000000)
	(input clk_cpu,
	input clk_mem,
	input rst,

	output [31:0] debug_out,

	// ram interface
	output [19:0] baseram_addr,
	inout [31:0] baseram_data,
	output baseram_ce,
	output baseram_oe,
	output baseram_we,
	output [19:0] extram_addr,
	inout [31:0] extram_data,
	output extram_ce,
	output extram_oe,
	output extram_we,

	// serial port interface
	output com_TxD,
	input com_RxD);

	// ------------------------------------------------------------------

	wire mem_is_write, mem_busy;
	wire [31:0] mem_addr, data_to_mem, data_from_mem;

	wire int_com_req, int_com_ack, com_write_enable, com_write_busy;
	wire [7:0] data_to_com, data_from_com;

	cpu ucpu(.clk(clk_cpu), .rst(rst),
		.int_com_req(int_com_req),
		.dev_mem_addr(mem_addr),
		.dev_mem_data_in(data_from_mem),
		.dev_mem_data_out(data_to_mem),
		.dev_mem_is_write(mem_is_write),
		.dev_mem_busy(mem_busy),
		.debug_out(debug_out));

	phy_mem_ctrl umem(.clk(clk_mem), .rst(rst),
		.is_write(mem_is_write), .addr(mem_addr),
		.data_in(data_to_mem), .data_out(data_from_mem),
		.busy(mem_busy),

		.int_com_ack(int_com_ack),

		.baseram_addr(baseram_addr), .baseram_data(baseram_data),
		.baseram_ce(baseram_ce), .baseram_oe(baseram_oe), .baseram_we(baseram_we),
		.extram_addr(extram_addr), .extram_data(extram_data),
		.extram_ce(extram_ce), .extram_oe(extram_oe), .extram_we(extram_we),
	
		.com_data_in(data_from_com), .com_data_out(data_to_com),
		.enable_com_write(com_write_enable),
		.com_read_ready(int_com_req),
		.com_write_ready(!com_write_busy));

	serial_port #(.CLK_FREQ(CLK_MEM_FREQ)) ucom(
		.clk(clk_mem), .rst(rst),
		.int_req(int_com_req), .int_ack(int_com_ack),
		.data_out(data_from_com), .data_in(data_to_com),
		.write_enable(com_write_enable),
		.write_busy(com_write_busy),
		.TxD(com_TxD), .RxD(com_RxD));

endmodule


