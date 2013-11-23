/*
 * $File: multiplier_wrapper.v
 * $Date: Sat Nov 23 16:45:52 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

// wrap around xilinx multiplier core, and provide hi/lo register
module multiplier_wrapper(
	input clk,
	input [31:0] opr1,
	input [31:0] opr2,
	output [31:0] hi,
	output [31:0] lo);

endmodule


