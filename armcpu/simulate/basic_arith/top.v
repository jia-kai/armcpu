/*
 * $File: top.v
 * $Date: Fri Nov 15 18:02:33 2013 +0800
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
		instrmem_data = 32'h24210001; // ADDIU $1, $1, 1
		// ADDIU $1, $1, 1

	always #1 clk <= ~clk;

	initial begin
		$dumpfile("dump.vcd");
		$dumpvars(0, ucpu);

		#3 rst = 0;
		$monitor("time=%g reg1=%h", $time,
			ucpu.uid.uregfile.mem[1]);
	end

endmodule

