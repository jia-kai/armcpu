/*
 * $File: phy_mem_ctrl.v
 * $Date: Sun Nov 17 12:28:39 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */


// physical memory controller
module phy_mem_ctrl(
	input clk,
	input rst,

	input is_write,
	input [31:0] addr,
	input [31:0] data_in,
	output reg [31:0] data_out,
	output busy,

	input [7:0] ram_read_wait,

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
	output extram_we);

	// ------------------------------------------------------------------

	reg [31:0] write_addr_latch, write_data_latch;

	localparam RAM_ADDR_MASK = 32'h1fffff;	// 8MiB, 2M 32-bit word

	reg [1:0] state;
	localparam READ_RAM = 2'b00,
		WRITE_RAM0 = 2'b01, WRITE_RAM1 = 2'b11, WAIT_READ_RAM_READ_RAMY = 2'b10;

	assign ram_we = (state != WRITE_RAM1);
	assign ram_oe = ~(state == READ_RAM || state == WAIT_READ_RAM_READ_RAMY);
	assign busy = (state != READ_RAM || is_write);

	always @(*)
		if (addr[1:0])
			$warning("access unaligned addr: %h", addr);

	wire [20:0]
		addr_to_ram = (ram_oe ? write_addr_latch[22:2] : addr[22:2]);
	assign ram_selector = addr_to_ram[20],
		baseram_ce = ram_selector,
		extram_ce = ~ram_selector,
		baseram_oe = ~(~ram_selector & ~ram_oe),
		extram_oe = ~(ram_selector & ~ram_oe),
		baseram_we = ~(~ram_selector & ~ram_we),
		extram_we = ~(ram_selector & ~ram_we);

	always @(*)
		if (ram_selector)
			data_out = extram_data;
		else
			data_out = baseram_data;
		// TODO: flash, com


	// set data after oe changes, so before we data is ready
	assign baseram_data = baseram_oe ? write_data_latch : {32{1'bz}},
		extram_data = extram_oe ? write_data_latch : {32{1'bz}},
		baseram_addr = addr_to_ram[19:0],
		extram_addr = addr_to_ram[19:0];

	
	reg [7:0] ram_read_wait_cnt;

	always @(negedge clk)
		if (rst)
			state <= READ_RAM;
		else case (state)
			READ_RAM: if (is_write) begin
				write_addr_latch <= addr;
				write_data_latch <= data_in;
				if ((addr & RAM_ADDR_MASK) == addr)
					state <= WRITE_RAM0;
			end
			WRITE_RAM0:
				state <= WRITE_RAM1;
			WRITE_RAM1: begin
				ram_read_wait_cnt <= 0;
				state <= WAIT_READ_RAM_READ_RAMY;
			end
			WAIT_READ_RAM_READ_RAMY: begin
				ram_read_wait_cnt <= ram_read_wait_cnt + 1'b1;
				if (ram_read_wait_cnt == ram_read_wait)
					state <= READ_RAM;
			end
			default:
				state <= READ_RAM;
		endcase

endmodule

