/*
 * $File: top.v
 * $Date: Fri Nov 15 19:23:20 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`timescale 1ns/1ps

module top;
	reg clk = 0;
	reg rst = 1;

	reg [31:0] instrmem_data;
	wire [31:0] instrmem_addr;

	cpu ucpu(.clk(clk), .rst(rst),
		.instrmem_addr(instrmem_addr),
		.instrmem_data(instrmem_data),
		.debug_out());

	always @(instrmem_addr)
		`include "mem.vh"

	always #1 clk <= ~clk;

	initial begin
		$dumpfile("dump.vcd");
		$dumpvars(0, ucpu);

		#3 rst = 0;
		$monitor("time=%g reg4=%h reg5=%h reg6=%h", $time,
			ucpu.uid.uregfile.mem[4],
			ucpu.uid.uregfile.mem[5],
			ucpu.uid.uregfile.mem[6]);
	end

endmodule

