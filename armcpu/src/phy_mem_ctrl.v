/*
 * $File: phy_mem_ctrl.v
 * $Date: Thu Nov 21 19:48:23 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`timescale 1ns/1ps

`define COM_DATA_ADDR	32'h1FD003F8	// only lowest byte contributes
`define COM_STAT_ADDR	32'h1FD003FC	// {30'b0, read_ready, write_ready}

`define RAM_ADDR_MASK	32'h007FFFFF	// 8MiB

`define ADDR_IS_RAM(addr) ((addr & `RAM_ADDR_MASK) == addr)


// physical memory controller
module phy_mem_ctrl(
	input clk,
	input rst,

	input is_write,
	input [31:0] addr,
	input [31:0] data_in,
	output reg [31:0] data_out,
	output busy,

	output reg int_com_ack,

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
	input com_write_ready);


	// ------------------------------------------------------------------

	assign addr_is_ram = `ADDR_IS_RAM(addr),
			addr_is_com_data = (addr == `COM_DATA_ADDR),
			addr_is_com_stat = (addr == `COM_STAT_ADDR);

	reg [31:0] write_addr_latch, write_data_latch;

	assign com_data_out = write_data_latch[7:0];

	reg [1:0] state;
	localparam READ_RAM = 2'b00,
		WRITE_RAM0 = 2'b01, WRITE_RAM1 = 2'b11, WRITE_RAM2 = 2'b10;

	assign ram_we = (state != WRITE_RAM1);
	assign ram_oe = ~(state == READ_RAM || state == WRITE_RAM2);
	assign busy = (state != READ_RAM || is_write);

	always @(*)
        if (addr[1:0]) begin
			$warning("time=%g access unaligned addr: %h", $time, addr);
            $fatal("exit due to previous error");
        end

	wire [20:0]
		addr_to_ram = (ram_oe ? write_addr_latch[22:2] : addr[22:2]);

	assign ram_selector = addr_to_ram[20],
		baseram_ce = ram_selector,
		extram_ce = ~ram_selector,
		baseram_oe = ~(~ram_selector & ~ram_oe),
		extram_oe = ~(ram_selector & ~ram_oe),
		baseram_we = ~(~ram_selector & ~ram_we),
		extram_we = ~(ram_selector & ~ram_we);

	// set data after oe changes, so before we data is ready
	assign baseram_data = baseram_oe ? write_data_latch : {32{1'bz}},
		extram_data = extram_oe ? write_data_latch : {32{1'bz}},
		baseram_addr = addr_to_ram[19:0],
		extram_addr = addr_to_ram[19:0];

	always @(*) begin
		data_out = 0;
		// TODO: flash
		case ({addr_is_ram, addr_is_com_data, addr_is_com_stat})
			3'b100: data_out = ram_selector ? extram_data : baseram_data;
			3'b010: data_out = {24'b0, com_data_in};
			3'b001: data_out = {30'b0, com_read_ready, com_write_ready};
		endcase
	end

	always @(negedge clk)
		int_com_ack <= addr_is_com_data && !is_write;
	
	always @(negedge clk) begin
		enable_com_write <= 0;
		if (rst)
			state <= READ_RAM;
		else case (state)
			READ_RAM: if (is_write) begin
				write_addr_latch <= addr;
				write_data_latch <= data_in;
				case ({addr_is_ram, addr_is_com_data})
					2'b10: state <= WRITE_RAM0;
					2'b01: enable_com_write <= 1;
				endcase
			end
			WRITE_RAM0:
				state <= WRITE_RAM1;
			WRITE_RAM1:
				state <= WRITE_RAM2;
			WRITE_RAM2:
				state <= READ_RAM;
			default:
				state <= READ_RAM;
		endcase
	end

endmodule

