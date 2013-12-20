/*
 * $File: cpld.v
 * $Date: Fri Dec 20 11:02:47 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */


module cpld(
	input clk50M,

	input pass_TxD,
	output pass_RxD,
	output TxD,
	input RxD,

	input ps2_clk,
	input ps2_data,
	output kbd_enb_hi,
	output kbd_enb_lo,
	output [3:0] kbd_data);

	assign TxD = pass_TxD;
	assign pass_RxD = RxD;

	ps2 usp2(.clk(clk50M),
		.ps2_clk(ps2_clk), .ps2_data(ps2_data),
		.kbd_enb_hi(kbd_enb_hi), .kbd_enb_lo(kbd_enb_lo),
		.kbd_data(kbd_data));

endmodule

