/*
 * $File: phy_mem_ctrl.v
 * $Date: Mon Nov 25 15:07:37 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`timescale 1ns/1ps

`define COM_DATA_ADDR	32'h1FD003F8	// only lowest byte contributes
`define COM_STAT_ADDR	32'h1FD003FC	// {30'b0, read_ready, write_ready}

`define SEGDISP_ADDR	32'h1FD00400	// 7-segment display monitor

`define ADDR_IS_RAM(addr) ((addr & 32'h007FFFFF) == addr)
`define ADDR_IS_FLASH(addr) (addr[31:24] == 8'h1E)
`define ADDR_IS_ROM(addr) (addr[31:12] == 20'h10000)

`define ROM_ADDR_WIDTH	12

`define RAM_WRITE_WIDTH	1	// width of write signal
`define RAM_WRITE_READ_RECOVERY 1	// recovery time before next read after write

`define FLASH_WRITE_WIDTH 4
`define FLASH_WRITE_READ_RECOVERY 2

// physical memory controller
module phy_mem_ctrl(
	input clk50M,
	input rst,

	input is_write,
	input [31:0] addr,
	input [31:0] data_in,
	output reg [31:0] data_out,
	output busy,

	output reg int_com_ack,

	output reg [31:0] segdisp,

	// control interface
	input rom_selector,

	// ram interface
	output [19:0] baseram_addr,
	inout [31:0] baseram_data,
	output baseram_ce,
	output baseram_oe,
	output baseram_we,
	output [19:0] extram_addr,
	inout [31:0] extram_data,
	output extram_ce,
	output extram_oe,
	output extram_we,

	// serial port interface
	input [7:0]com_data_in,
	output [7:0] com_data_out,
	output reg enable_com_write,
	input com_read_ready,
	input com_write_ready,

	// flash interface
	output [22:0] flash_addr,
	inout [15:0] flash_data,
	output [7:0] flash_ctl);


	// ------------------------------------------------------------------

	always @(*)
        if (addr[1:0]) begin
			$warning("time=%g access unaligned addr: %h", $time, addr);
            $fatal("exit due to previous error");
        end

	reg [31:0] write_addr_latch, write_data_latch;
	reg [1:0] state;
	reg [3:0] write_cnt;
	wire [3:0] write_cnt_next = write_cnt + 1'b1;
	localparam READ = 2'b00,
		WRITE_RAM = 2'b01, WRITE_FLASH = 2'b10, RECOVERY_READ = 2'b11;

	assign busy = (state != READ || is_write);

	assign addr_is_ram = `ADDR_IS_RAM(addr),
			addr_is_com_data = (addr == `COM_DATA_ADDR),
			addr_is_com_stat = (addr == `COM_STAT_ADDR),
			addr_is_flash = `ADDR_IS_FLASH(addr),
			addr_is_segdisp = (addr == `SEGDISP_ADDR),
			addr_is_rom = `ADDR_IS_ROM(addr);

	assign flash_byte = 1, flash_vpen = 1, flash_ce = 0, flash_rp = 1,
		flash_oe = (state == WRITE_FLASH),
		flash_we = ~(state == WRITE_FLASH && write_cnt < `FLASH_WRITE_WIDTH);
	assign flash_addr = flash_oe ? write_addr_latch[23:1] : addr[23:1];
	assign flash_data = flash_oe ? write_data_latch[15:0] : {16{1'bz}};
	assign flash_ctl = {
		flash_byte,
		flash_ce,
		2'b0,	// ce1 ce2
		flash_oe,
		flash_rp,
		flash_vpen,
		flash_we};

	
	wire [`ROM_ADDR_WIDTH-1:0] rom_addr = addr[`ROM_ADDR_WIDTH-1:0];
	reg [31:0] rom_data;

	task rom_bootloader;
		`include "rom/bootloader.v"
	endtask

	task rom_memtrans;
		`include "rom/memtrans.v"
	endtask

	always @(rom_addr, rom_selector)
		case (rom_selector)
			1'b0: rom_memtrans();
			1'b1: rom_bootloader();
		endcase

	assign com_data_out = write_data_latch[7:0];

	assign ram_oe = (state == WRITE_RAM),
		ram_we = ~(state == WRITE_RAM && write_cnt < `RAM_WRITE_WIDTH);


	wire [20:0]
		ram_addr = (ram_oe ? write_addr_latch[22:2] : addr[22:2]);

	assign ram_selector = ram_addr[20],
		baseram_ce = ram_selector,
		extram_ce = ~ram_selector,
		baseram_oe = ~(~ram_selector & ~ram_oe),
		extram_oe = ~(ram_selector & ~ram_oe),
		baseram_we = ~(~ram_selector & ~ram_we),
		extram_we = ~(ram_selector & ~ram_we);

	// set data after oe changes, so before we data is ready
	assign baseram_data = baseram_oe ? write_data_latch : {32{1'bz}},
		extram_data = extram_oe ? write_data_latch : {32{1'bz}},
		baseram_addr = ram_addr[19:0],
		extram_addr = ram_addr[19:0];

	always @(*) begin
		data_out = 0;
		case ({addr_is_ram, addr_is_com_data, addr_is_com_stat,
				addr_is_flash, addr_is_rom})
			5'b10000: data_out = ram_selector ? extram_data : baseram_data;
			5'b01000: data_out = {25'b0, com_data_in};
			5'b00100: data_out = {30'b0, com_read_ready, com_write_ready};
			5'b00010: data_out = {16'b0, flash_data};
			5'b00001: data_out = rom_data;
		endcase
	end

	always @(negedge clk50M)
		int_com_ack <= addr_is_com_data && !is_write;
	
	reg is_write_prev;
	assign is_write_posedge = !is_write_prev && is_write;
	always @(negedge clk50M) begin
		enable_com_write <= 0;
		is_write_prev <= is_write;
		if (rst)
			state <= READ;
		else case (state)
			READ: if (is_write_posedge) begin
				write_addr_latch <= addr;
				write_data_latch <= data_in;
				write_cnt <= 0;
				case ({addr_is_ram, addr_is_com_data, addr_is_flash, addr_is_segdisp})
					4'b1000: state <= WRITE_RAM;
					4'b0100: enable_com_write <= 1;
					4'b0010: state <= WRITE_FLASH;
					4'b0001: segdisp <= data_in;
				endcase
			end
			WRITE_RAM: begin
				write_cnt <= write_cnt_next;
				if (write_cnt_next == `RAM_WRITE_READ_RECOVERY + `RAM_WRITE_WIDTH)
					state <= RECOVERY_READ;
			end
			WRITE_FLASH: begin
				write_cnt <= write_cnt_next;
				if (write_cnt_next == `FLASH_WRITE_READ_RECOVERY + `FLASH_WRITE_WIDTH)
					state <= RECOVERY_READ;
			end
			RECOVERY_READ:
				state <= READ;
			default:
				state <= READ;
		endcase
	end

endmodule

