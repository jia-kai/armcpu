/*
 * $File: system.v
 * $Date: Sat Nov 16 16:41:01 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */


// top-level system
module system(
	input clk,
	input rst,

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
	output extram_we);

	wire mem_is_write, mem_busy;
	wire [31:0] mem_addr, data_to_mem, data_from_mem;


	cpu ucpu(.clk(clk), .rst(rst),
		.dev_mem_addr(mem_addr),
		.dev_mem_data_in(data_from_mem),
		.dev_mem_data_out(data_to_mem),
		.dev_mem_is_write(mem_is_write),
		.dev_mem_busy(mem_busy),
		.debug_out());

	phy_mem_ctrl umem(.clk(clk), .rst(rst),
		.is_write(mem_is_write), .addr(mem_addr),
		.data_in(data_to_mem), .data_out(data_from_mem),
		.busy(mem_busy),

		.baseram_addr(baseram_addr), .baseram_data(baseram_data),
		.baseram_ce(baseram_ce), .baseram_oe(baseram_oe), .baseram_we(baseram_we),
		.extram_addr(extram_addr), .extram_data(extram_data),
		.extram_ce(extram_ce), .extram_oe(extram_oe), .extram_we(extram_we));

endmodule


