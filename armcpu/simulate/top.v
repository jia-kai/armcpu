/*
 * $File: top.v
 * $Date: Fri Nov 29 00:15:17 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`timescale 1ns/1ps

`include "src/cp0_def.vh"

module top;
	reg clk = 0, clk_half = 0;
	reg rst = 1;

	wire [31:0] baseram_data, extram_data;
	wire [19:0] baseram_addr, extram_addr;
	wire baseram_ce, baseram_oe, baseram_we,
		extram_ce, extram_oe, extram_we;

	wire [31:0] segdisp;

	ram_sim #(.NAME("base"), .IMAGE_FILE("prog.bin"))
		ubaseram(
		.addr(baseram_addr), .data(baseram_data),
		.ce(baseram_ce), .oe(baseram_oe), .we(baseram_we));
	ram_sim #(.NAME("ext")) 
		uextram(
		.addr(extram_addr), .data(extram_data),
		.ce(extram_ce), .oe(extram_oe), .we(extram_we));

	wire [22:0] flash_addr;
	wire [31:0] flash_data_ext;
	wire [7:0] flash_ctl;
	ram_sim #(.NAME("flash"), .ADDR_WIDTH(23), .CHECK_BAD_READ(0))
		uflash(.addr(flash_addr), .data(flash_data_ext),
		.ce(flash_ctl[5]), .oe(flash_ctl[3]), .we(flash_ctl[0]));

	wire com_to_sys, com_from_sys;

	wire [8:0] vga_color_out;
	wire vga_hsync, vga_vsync;

	system usystem(.clk_cpu(clk_half), .clk50M(clk), .rst(rst),
		.segdisp(segdisp),
		.rom_selector(1'b0),
		.baseram_addr(baseram_addr),
		.baseram_data(baseram_data),
		.baseram_ce(baseram_ce),
		.baseram_oe(baseram_oe),
		.baseram_we(baseram_we),
		.extram_addr(extram_addr),
		.extram_data(extram_data),
		.extram_ce(extram_ce),
		.extram_oe(extram_oe),
		.extram_we(extram_we),

		.com_TxD(com_from_sys),
		.com_RxD(com_to_sys),
	
		.flash_addr(flash_addr), .flash_data(flash_data_ext[15:0]),
		.flash_ctl(flash_ctl),
	
		.vga_color_out(vga_color_out),
		.vga_hsync(vga_hsync),
		.vga_vsync(vga_vsync));

	always #1 clk <= ~clk;

	always @(posedge clk)
		clk_half <= ~clk_half;

	initial begin
		$dumpfile("dump.vcd");
		$dumpvars(0, top);

		$monitor("time=%g segdisp=%h", $time, segdisp);

		#6 rst = 0;
	end

	reg write_com = 0;
	reg [7:0] write_com_data = 0;
	wire com_write_busy, com_read_ready;
	wire [7:0] com_read_data;
	uart_async_transmitter ucomtrans(.clk(clk), .TxD_start(write_com),
		.TxD_data(write_com_data), .TxD(com_to_sys), .TxD_busy(com_write_busy));

	uart_async_receiver ucomrecv(
		.clk(clk), .rst(rst),
		.RxD(com_from_sys), .RxD_data_ready(com_read_ready),
		.RxD_waiting_data(), .RxD_data(com_read_data));

	always @(com_read_ready)
		$display("time=%g com_read_data=%h", $time, com_read_data);

	always @(com_write_busy)
		$display("time=%g com_write_busy=%b", $time, com_write_busy);

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
	always @(usystem.ucpu.uid.uregfile.mem[16])
		$display("time=%g reg16($s0)=%h", $time,
			usystem.ucpu.uid.uregfile.mem[16]);
	always @(usystem.ucpu.uid.uregfile.mem[26])
		$display("time=%g reg26($k0)=%h", $time,
			usystem.ucpu.uid.uregfile.mem[26]);
	always @(usystem.ucpu.uid.uregfile.mem[27])
		$display("time=%g reg26($k1)=%h", $time,
			usystem.ucpu.uid.uregfile.mem[27]);
	always @(usystem.ucpu.uid.uregfile.mem[29])
		$display("time=%g reg29($sp)=%h", $time,
			usystem.ucpu.uid.uregfile.mem[29]);
	always @(usystem.ucpu.uid.uregfile.mem[31])
		$display("time=%g reg31($ra)=%h", $time,
			usystem.ucpu.uid.uregfile.mem[31]);


	wire is_user_mode = usystem.ucpu.is_user_mode;
	always @(is_user_mode)
		if (is_user_mode)
			$display("time=%g cpu entered user mode", $time);
		else
			$display("time=%g cpu entered kernel mode", $time);

	wire [31:0]
		cp0_status = `CP0_VISIT_REG(usystem.ucpu.umem.cp0_reg, `CP0_STATUS),
		cp0_cause = `CP0_VISIT_REG(usystem.ucpu.umem.cp0_reg, `CP0_CAUSE);
	always @(cp0_status)
		$display("time=%g cp0_status: IM=%b KSU=%b EXL=%b IE=%b",
			$time, cp0_status[15:8], cp0_status[4:3], cp0_status[1], cp0_status[0]);
	always @(cp0_cause)
		$display("time=%g cp0_cause: IP=%b ExcCode=%h",
			$time, cp0_cause[15:8], cp0_cause[6:2]);

endmodule

