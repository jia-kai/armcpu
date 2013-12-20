/*
 * $File: ps2_drv.v
 * $Date: Fri Dec 20 11:19:35 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */


module ps2_drv(
	input clk,
	input rst,

	input int_ack,
	output reg int_req,
	output reg [7:0] kbd_ascii,

	input kbd_enb_hi,
	input kbd_enb_lo,
	input [3:0] kbd_data);



	reg [3:0] recv_data_lo;
	wire [7:0] recv_data = {kbd_data, recv_data_lo};
	reg [7:0] cur_pressed, cur_pressed_ascii, recv_data_prev;
	reg shift_pressed;

	assign is_shift = (recv_data == 8'h12 || recv_data == 8'h59),
		is_break = (recv_data_prev == 8'hF0);

	`include "ps2_code.vh"

	// maintain int
	always @(posedge clk) begin
		if (rst || (int_req && int_ack)) begin
			kbd_ascii <= 0;
			int_req <= 0;
		end else if (!int_req && cur_pressed_ascii) begin
			int_req <= 1'b1;
			kbd_ascii <= cur_pressed_ascii;
		end
	end


	// maintain cur_pressed
	always @(posedge clk) begin
		if (rst)
			shift_pressed <= 0;
		else begin
			if (kbd_enb_lo)
				recv_data_lo <= kbd_data;
			else if (kbd_enb_hi) begin
				recv_data_prev <= recv_data;
				if (is_shift)
					shift_pressed <= !is_break;
				else if (is_break) begin
					if (recv_data == cur_pressed)
						cur_pressed <= 0;
				end else
					cur_pressed <= recv_data;
			end
		end
	end

endmodule

