/*
 * $File: top.v
 * $Date: Sat Nov 16 17:17:19 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`timescale 1ns/1ps

module top;
	reg clk = 0;
	reg rst = 1;

	wire [31:0] baseram_data, extram_data;
	wire [19:0] baseram_addr, extram_addr;
	wire baseram_ce, baseram_oe, baseram_we,
		extram_ce, extram_oe, extram_we;

	ram_sim #(.IMAGE_FILE("prog.bin"))
		ubaseram(
		.addr(baseram_addr), .data(baseram_data),
		.ce(baseram_ce), .oe(baseram_oe), .we(baseram_we));
	ram_sim #(.IMAGE_FILE("prog.bin"))
		uextram(
		.addr(extram_addr), .data(extram_data),
		.ce(extram_ce), .oe(extram_oe), .we(extram_we));

	system usystem(.clk(clk), .rst(rst),
		.baseram_addr(baseram_addr), .baseram_data(baseram_data),
		.baseram_ce(baseram_ce), .baseram_oe(baseram_oe), .baseram_we(baseram_we),
		.extram_addr(extram_addr), .extram_data(extram_data),
		.extram_ce(extram_ce), .extram_oe(extram_oe), .extram_we(extram_we));

	always #1 clk <= ~clk;

	initial begin
		$dumpfile("dump.vcd");
		$dumpvars(0, ubaseram);
		$dumpvars(0, usystem.ucpu);

		#3 rst = 0;
		$monitor("time=%g reg4=%h reg5=%h reg6=%h", $time,
			usystem.ucpu.uid.uregfile.mem[4],
			usystem.ucpu.uid.uregfile.mem[5],
			usystem.ucpu.uid.uregfile.mem[6]);
	end

endmodule

