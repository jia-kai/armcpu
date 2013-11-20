/*
 * $File: timer.v
 * $Date: Wed Nov 20 19:05:26 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */


// generate timer interrupt
module timer(
	input clk,
	input rst,
	input [31:0] cp0_count,
	input [31:0] cp0_compare,
	output reg int_req,
	input int_ack);

	always @(posedge clk)
		if (rst || int_ack)
			int_req <= 0;
		else if (cp0_count == cp0_compare)
			int_req <= 1;

endmodule

