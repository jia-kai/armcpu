/*
 * $File: top.v
 * $Date: Fri Nov 15 11:08:35 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`timescale 1ns/1ps

module top;
	reg clk = 0;
	reg rst = 0;

	reg [31:0] instrmem_data;
	wire [31:0] instrmem_addr;

	cpu ucpu(.clk(clk), .rst(rst),
		.instrmem_addr(instrmem_addr),
		.instrmem_data(instrmem_data));

	always @(instrmem_addr)
		instrmem_data = 32'b00100100001000010000000000000001;
		// ADDIU $1, $1, 1

	always #1 clk <= ~clk;

	initial begin
		$dumpfile("dump.vcd");
		$dumpvars(0, ucpu);

		#1 rst = 1;
		#2 rst = 0;
		$monitor("time=%d reg1=%h", $time,
			ucpu.uid.uregfile.mem[1]);
	end

endmodule

