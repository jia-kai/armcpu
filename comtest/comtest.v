/*
 * $File: comtest.v
 * $Date: Sat Oct 26 00:39:37 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */


module comtest(
	input clk, input rst,
	output [31:0] baseram_data,
	output [0:6] segdisp0,
	output [0:6] segdisp1,
	output baseram_oe,
	output baseram_ce,
	output baseram_we,
	output reg uart_wrn,
	input uart_tbre,
	input uart_tsre,
	output uart_rdn);

	assign baseram_oe = 1;
	assign baseram_ce = 1;
	assign baseram_we = 1;
	assign baseram_data = 32'h42424242;

	reg [2:0] state;

	reg [10:0] debug_cnt;

	assign uart_rdn = 1;	// disable com writer

	digseg_driver debug_disp_cnt(
		.data(debug_cnt[10:7]),
		.seg(segdisp0));

	digseg_driver debug_disp_state(
		.data({1'b0, state}),
		.seg(segdisp1));

	always @(posedge clk) begin
		if (!rst) begin
			state <= 0;
			debug_cnt <= 0;
		end else begin
			if (state == 0) begin
				debug_cnt <= debug_cnt + 1'b1;
				state <= 1;
				uart_wrn <= 1;
			end else if (state == 1) begin
				uart_wrn <= 0;
				state <= 2;
			end else if (state == 2) begin
				uart_wrn <= 1;
				state <= 3;
			end else if (state == 3) begin
				if (uart_tbre)
					state <= 4;
			end else if (state == 4) begin
				if (uart_tsre)
					state <= 0;
			end else
				state <= 0;
		end
	end
	
endmodule


