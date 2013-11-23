/*
 * $File: multiplier.v
 * $Date: Sat Nov 23 19:39:32 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */
`timescale 1ns/1ps

// simulate multiplier
module multiplier(
	input clk,
	input [31:0] a,
	input [31:0] b,
	output reg [63:0] p);

	always @(a, b) begin

		repeat (7) begin
			@(posedge clk);
		end

		p = a * b;
	end

endmodule
