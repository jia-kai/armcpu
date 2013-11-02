/*
 * $File: vga_test.v
 * $Date: Sat Nov 02 19:38:36 2013 +0800
 * $Author: Xinyu Zhou <zxytim@gmail.com>
 */

`timescale 1ns/1ns

module vga_test(
	input clk50M,
	output [8:0] color_out,
	output hsync,
	output vsync,

	// debug
	output [0:6] segdisp0,
	output [0:6] segdisp1,
	output [15:0] led
	);
//    reg clk50M = 0;

	reg [9:0] vsync_cnt = {10{1'b0}};
	reg [9:0] hsync_cnt = {10{1'b0}};

	reg [3:0] sec = {4{1'b0}};

	reg clk_ind = 0;
	reg [25:0] clk_cnt = {25{1'b0}};
	always @(negedge clk50M) begin
		if (clk_cnt == 50000000 - 1) begin
			clk_cnt <= 0;
			clk_ind <= clk_ind + 1'b1;
		end else begin
			clk_cnt <= clk_cnt + 1'b1;
		end
	end

	assign led = {clk_ind, color_out, sec};

	vga_driver vga(clk50M, color_out, hsync, vsync);

	digseg_driver digsegv(sec, segdisp0);
	digseg_driver digsegh(sec, segdisp1);

	reg vsync_prev;
	always @(posedge clk50M)
		vsync_prev <= vsync;

	always @(posedge clk50M) begin
		if (vsync_prev & ~vsync) begin
			if (vsync_cnt == 59) begin
				vsync_cnt <= {10{1'b0}};
				sec <= sec + 1'b1;
			end else begin
				vsync_cnt <= vsync_cnt + 1'b1;
			end
		end
	end

	always @(negedge hsync) begin hsync_cnt <= hsync_cnt + 1'b1; end

//    always #10 clk50M = !clk50M;
//    initial begin
//        $dumpfile("test.vcd");
//        $dumpvars(0, clk50M);
//        $dumpvars(0, vsync_cnt);
//        $dumpvars(0, hsync_cnt);
//        $dumpvars(0, vsync);
//        $dumpvars(0, hsync);
//        $dumpvars(0, sec);
//        $dumpvars(0, led);
//        #50000000 $finish;
//    end

endmodule
