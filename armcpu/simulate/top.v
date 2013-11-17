/*
 * $File: top.v
 * $Date: Sun Nov 17 16:12:14 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`timescale 1ns/1ps

module top;
	reg clk = 0, clk_half = 0;
	reg rst = 1;

	wire [31:0] baseram_data, extram_data;
	wire [19:0] baseram_addr, extram_addr;
	wire baseram_ce, baseram_oe, baseram_we,
		extram_ce, extram_oe, extram_we;

	wire [31:0] debug_out;

	ram_sim #(.IMAGE_FILE("prog.bin"))
		ubaseram(
		.addr(baseram_addr), .data(baseram_data),
		.ce(baseram_ce), .oe(baseram_oe), .we(baseram_we));
	ram_sim 
		uextram(
		.addr(extram_addr), .data(extram_data),
		.ce(extram_ce), .oe(extram_oe), .we(extram_we));

	system usystem(.clk_cpu(clk_half), .clk_mem(clk), .rst(rst),
		.ram_read_wait(8'b0),
		.debug_out(debug_out),
		.baseram_addr(baseram_addr), .baseram_data(baseram_data),
		.baseram_ce(baseram_ce), .baseram_oe(baseram_oe), .baseram_we(baseram_we),
		.extram_addr(extram_addr), .extram_data(extram_data),
		.extram_ce(extram_ce), .extram_oe(extram_oe), .extram_we(extram_we));

	always #1 clk <= ~clk;

	always @(posedge clk)
		clk_half <= ~clk_half;

	initial begin
		$dumpfile("dump.vcd");
		$dumpvars(0, ubaseram);
		$dumpvars(0, usystem);

		$monitor("time=%g debug_out=%h", $time, debug_out);

		#6 rst = 0;
	end

	// $monitor seems to override privious ones

	always @(usystem.ucpu.uid.uregfile.mem[1])
		$display("time=%g reg1($at)=%h", $time,
			usystem.ucpu.uid.uregfile.mem[1]);
	always @(usystem.ucpu.uid.uregfile.mem[2])
		$display("time=%g reg2($v0)=%h", $time,
			usystem.ucpu.uid.uregfile.mem[2]);
	always @(usystem.ucpu.uid.uregfile.mem[3])
		$display("time=%g reg3($v1)=%h", $time,
			usystem.ucpu.uid.uregfile.mem[3]);
	always @(usystem.ucpu.uid.uregfile.mem[4])
		$display("time=%g reg4($a0)=%h", $time,
			usystem.ucpu.uid.uregfile.mem[4]);
	always @(usystem.ucpu.uid.uregfile.mem[5])
		$display("time=%g reg5($a1)=%h", $time,
			usystem.ucpu.uid.uregfile.mem[5]);
	always @(usystem.ucpu.uid.uregfile.mem[6])
		$display("time=%g reg6($a2)=%h", $time,
			usystem.ucpu.uid.uregfile.mem[6]);
	always @(usystem.ucpu.uid.uregfile.mem[7])
		$display("time=%g reg7($a3)=%h", $time,
			usystem.ucpu.uid.uregfile.mem[7]);
	always @(usystem.ucpu.uid.uregfile.mem[31])
		$display("time=%g reg31($ra)=%h", $time,
			usystem.ucpu.uid.uregfile.mem[31]);


endmodule

