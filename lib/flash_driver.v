/*
 * $File: flash_driver.v
 * $Date: Sun Oct 27 17:44:10 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */


module flash_driver(
	input clk,
	input [22:0] addr,
	input [15:0] data_in,
	output [15:0] data_out,
	input enable_read,
	input enable_erase,
	input enable_write,
	output busy,
	output [22:0] flash_addr,
	inout [15:0] flash_data,
	output [7:0] flash_ctl);

	wire flash_byte, flash_vpen, flash_ce, flash_oe, flash_we, flash_rp;

	assign flash_ctl = {
		flash_byte,
		flash_ce,
		2'b0,	// ce1 ce2
		flash_oe,
		flash_rp,
		flash_vpen,
		flash_we};

	flash_driver_impl impl(addr, data_in, data_out, clk,
		1'b1, flash_byte, flash_vpen, flash_ce, flash_oe, flash_we,
		flash_rp, flash_addr, flash_data,
		enable_read, enable_write, enable_erase, busy);

endmodule


