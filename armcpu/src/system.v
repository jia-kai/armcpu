/*
 * $File: system.v
 * $Date: Fri Nov 22 20:51:14 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */


// top-level system
module system
	(input clk_cpu,
	input clk50M,
	input rst,

	output [31:0] segdisp,

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
	input com_RxD,

	// flash interface
	output [22:0] flash_addr,
	inout [15:0] flash_data,
	output [7:0] flash_ctl);

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
		.dev_mem_busy(mem_busy));

	phy_mem_ctrl umem(.clk50M(clk50M), .rst(rst),
		.is_write(mem_is_write), .addr(mem_addr),
		.data_in(data_to_mem), .data_out(data_from_mem),
		.busy(mem_busy),

		.int_com_ack(int_com_ack),

		.segdisp(segdisp),

		.baseram_addr(baseram_addr), .baseram_data(baseram_data),
		.baseram_ce(baseram_ce), .baseram_oe(baseram_oe), .baseram_we(baseram_we),
		.extram_addr(extram_addr), .extram_data(extram_data),
		.extram_ce(extram_ce), .extram_oe(extram_oe), .extram_we(extram_we),
	
		.com_data_in(data_from_com), .com_data_out(data_to_com),
		.enable_com_write(com_write_enable),
		.com_read_ready(int_com_req),
		.com_write_ready(!com_write_busy),
	
		.flash_addr(flash_addr),
		.flash_data(flash_data),
		.flash_ctl(flash_ctl));


	serial_port #(.CLK_FREQ(50000000)) ucom(
		.clk(clk50M), .rst(rst),
		.int_req(int_com_req), .int_ack(int_com_ack),
		.data_out(data_from_com), .data_in(data_to_com),
		.write_enable(com_write_enable),
		.write_busy(com_write_busy),
		.TxD(com_TxD), .RxD(com_RxD));

endmodule

