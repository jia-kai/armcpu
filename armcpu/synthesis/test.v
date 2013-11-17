/*
 * $File: test.v
 * $Date: Sun Nov 17 09:37:22 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

module test(
	input clk50M,
	input rst,
	output [0:6] segdisp0,
	output [0:6] segdisp1,

	output reg [15:0] led,

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


	reg clk25M;
	always @(posedge clk50M)
		clk25M <= ~clk25M;

	wire [31:0] monitor_data;

	system usys(.clk_cpu(clk25M), .clk_mem(clk50M), .rst(~rst), .debug_out(monitor_data),
		.baseram_addr(baseram_addr), .baseram_data(baseram_data),
		.baseram_ce(baseram_ce), .baseram_oe(baseram_oe), .baseram_we(baseram_we),
		.extram_addr(extram_addr), .extram_data(extram_data),
		.extram_ce(extram_ce), .extram_oe(extram_oe), .extram_we(extram_we));

	always @(posedge clk25M)
		led <= {led[14:0], !led[14:0]};

	digseg_driver useg0(.data(monitor_data[25:22]), .seg(segdisp0));
	digseg_driver useg1(.data(monitor_data[21:18]), .seg(segdisp1));

endmodule

