/*
 * $File: flashtest.v
 * $Date: Sun Oct 27 17:50:21 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

module flashtest(
	input clk, 
	input do_read,
	input do_erase,
	input do_write,
	input [22:0] user_addr,
	input [7:0] user_data,
	output [22:0] flash_addr,
	inout [15:0] flash_data,
	output [7:0] flash_ctl,
	output [15:0] led,
	output [0:6] segdisp0,
	output [0:6] segdisp1);

	wire flash_busy;

	wire [15:0] data_to_disp;
	assign led = {
		data_to_disp[15:8],
		2'b0,
		enable_write, enable_erase, enable_read, flash_busy};

	reg enable_write, enable_erase, enable_read;

	digseg_driver disp_data_high(.data(data_to_disp[7:4]), .seg(segdisp1));
	digseg_driver disp_data_low(.data(data_to_disp[3:0]), .seg(segdisp0));

	flash_driver u0 (.clk(clk), .addr(user_addr), .data_in({8'b0, user_data}),
	.data_out(data_to_disp),
	.enable_read(enable_read), .enable_write(enable_write),
	.enable_erase(enable_erase),
	.busy(flash_busy),
	.flash_addr(flash_addr), .flash_data(flash_data),
	.flash_ctl(flash_ctl));


	always @(posedge clk) begin
		enable_erase <= ~do_erase;
		enable_read <= ~do_read;
		enable_write <= ~do_write;
	end

endmodule


