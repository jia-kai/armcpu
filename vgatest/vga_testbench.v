/*
 * $File: vga_testbench.v
 * $Date: Sat Nov 02 19:37:52 2013 +0800
 * $Author: Xinyu Zhou <zxytim@gmail.com>
 */

`timescale 1ns/1ps

// specification reference:
// http://tinyvga.com/vga-timing/640x480@60Hz
module vga_driver_test;
	reg clk50M = 0;

	wire [8:0]color_out;
	wire hsync, vsync;
	vga_driver u0(clk50M, color_out, hsync, vsync);

	always #10 clk50M = !clk50M;

	initial begin
//        $dumpfile("test.vcd");
//        $dumpvars(2, vga_driver_test);
//        #20000000 $finish;
	end

endmodule
