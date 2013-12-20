/*
 * $File: ps2.v
 * $Date: Fri Dec 20 09:52:32 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

module ps2(
	input clk,
	input rst_key,
	
	output [0:6] segdisp0,
	output [0:6] segdisp1,
	output int_req,
	input int_ack_key,
	
	input kbd_enb_hi,
	input kbd_enb_lo,
	input [3:0] kbd_data);

	wire [7:0] kbd_ascii;

	ps2_drv ups2(.clk(clk), .rst(~rst_key),
		.int_ack(~int_ack_key), .int_req(int_req),
		.kbd_ascii(kbd_ascii),
		.kbd_enb_hi(kbd_enb_hi), .kbd_enb_lo(kbd_enb_lo),
		.kbd_data(kbd_data));

	digseg_driver udig0(.data(kbd_ascii[3:0]), .seg(segdisp0));
	digseg_driver udig1(.data(kbd_ascii[7:4]), .seg(segdisp1));

endmodule

