/*
 * $File: ramtest.v
 * $Date: Fri Oct 25 17:39:20 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

module ramtest(
	input clk,
	input mode_is_write,
	input [3:0] user_data,
	input [7:0] user_addr,
	output [0:6] segdisp0,
	output [19:0] baseram_addr,
	inout [31:0] baseram_data,
	output baseram_ce,
	output baseram_oe,
	output baseram_we);

	wire [31:0] data_from_ram;

	digseg_driver digseg_show_data(data_from_ram[3:0], segdisp0);

	ram_driver ram_driver_test(
		{12'b0, user_addr}, {28'b0, user_data},
		data_from_ram, mode_is_write,
		baseram_addr, baseram_data, baseram_ce, baseram_oe, baseram_we,
		clk);

endmodule


