/*
 * $File: main.v
 * $Date: Fri Oct 25 15:05:51 2013 +0800
 */
module main(
    input clk11M,
	input clk50M,
    output [15:0] led);

	wire [15:0] led0, led1;
	assign led[15:1] = led0[15:1] | led1[15:1];
	assign led[0] = 1'b1;

	led_looper looper_lclk(clk11M, led0);
	led_looper looper_hclk(clk50M, led1);

endmodule


module led_looper(
	input clk,
	output reg [15:0] led);

	reg [23:0] cnt;
	reg cnt_high_prev;
	wire cnt_changed = cnt[23] & ~cnt_high_prev;

	always @(posedge clk) begin
		cnt <= cnt + 1'b1;
		cnt_high_prev <= cnt[23];
		if (cnt_changed)
			led <= {led[14:0], ~ (|led[14:0])};
	end
endmodule


