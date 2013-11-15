/*
 * $File: accum_adder.v
 * $Date: Fri Nov 15 16:01:21 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

module accum_adder(
	input clk50M,
	input rst,
	output [0:6] segdisp0,
	output [0:6] segdisp1);

	wire [31:0] monitor_data;
	cpu ucpu(.clk(clk50M), .rst(~rst),
		.instrmem_addr(),
		.instrmem_data(32'h24210001), // ADDIU $1, $1, 1
		.debug_out(monitor_data));


	digseg_driver useg0(.data(monitor_data[21:18]), .seg(segdisp0));
	digseg_driver useg1(.data(monitor_data[25:22]), .seg(segdisp1));

endmodule

