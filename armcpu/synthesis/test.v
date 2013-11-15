/*
 * $File: test.v
 * $Date: Fri Nov 15 20:42:28 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

module test(
	input clk50M,
	input rst,
	output [0:6] segdisp0,
	output [0:6] segdisp1);

	reg [23:0] clk_cnt;

	always @(posedge clk50M)
		clk_cnt <= clk_cnt + 1'b1;

	wire [31:0] monitor_data, instrmem_addr;
	reg [31:0] instrmem_data;
	cpu ucpu(.clk(clk_cnt[23]), .rst(~rst),
		.instrmem_addr(instrmem_addr),
		.instrmem_data(instrmem_data),
		.debug_out(monitor_data));

	always @(instrmem_addr)
		`include "mem.vh"

	digseg_driver useg0(.data(monitor_data[3:0]), .seg(segdisp0));
	digseg_driver useg1(.data(monitor_data[7:4]), .seg(segdisp1));

endmodule

