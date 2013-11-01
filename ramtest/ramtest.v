/*
 * $File: ramtest.v
 * $Date: Fri Nov 01 13:35:12 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

module ramtest(
	input clk,
	input enable_read_key,
	input enable_write_key,
	input [3:0] user_data,
	input [7:0] user_addr,
	output [0:6] segdisp0,
	output reg [2:0] led,

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

	wire [31:0] data_from_ram;
	reg [3:0] data_to_show;
	digseg_driver digseg_show_data(data_to_show[3:0], segdisp0);

	reg enable_write_key_prev, enable_read_key_prev;
	assign mode_changed_to_write = ~enable_write_key_prev & enable_write_key,
		mode_changed_to_read = ~enable_read_key_prev & enable_read_key;

	always @(posedge clk) begin
		enable_write_key_prev <= enable_write_key;
		enable_read_key_prev <= enable_read_key;
	end

	wire write_finished, read_ready;
	always @(posedge clk) begin
		if (mode_changed_to_write)
			led[0] <= ~led[0];
		if (write_finished)
			led[1] <= ~led[1];
		if (read_ready) begin
			led[2] <= ~led[2];
			data_to_show <= data_from_ram[3:0];
		end
	end

	ram_driver ram_driver_inst(
		clk, 1'b1,
		mode_changed_to_read, mode_changed_to_write,
		{user_addr[7], 12'b0, user_addr}, {28'b0, user_data},
		data_from_ram, write_finished, read_ready, 
		baseram_addr, baseram_data, baseram_ce, baseram_oe, baseram_we,
		extram_addr, extram_data, extram_ce, extram_oe, extram_we);

endmodule


