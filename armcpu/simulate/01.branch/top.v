/*
 * $File: top.v
 * $Date: Fri Nov 15 18:30:45 2013 +0800
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
		if (instrmem_addr < 4)
			instrmem_data = 0;
		else if (instrmem_addr == 4)
			instrmem_data = 32'h10210001;	// beq $1, $1, 1
		else if (instrmem_addr == 8)
			instrmem_data = 32'h24210001;	// addiu $1, $1, 1
		else if (instrmem_addr == 12)
			instrmem_data = 32'h24220002;	// addiu $2, $1, 2
		else
			instrmem_data = 0;

	always #1 clk <= ~clk;

	initial begin
		$dumpfile("dump.vcd");
		$dumpvars(0, ucpu);

		#3 rst = 0;
		$monitor("time=%g reg1=%h reg2=%h", $time,
			ucpu.uid.uregfile.mem[1],
			ucpu.uid.uregfile.mem[2]);
	end

endmodule

