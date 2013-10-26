/*
 * $File: comtest.v
 * $Date: Sat Oct 26 20:45:53 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */


module comtest(
	input clk, input rst,
	inout [7:0] baseram_data,
	output [0:6] segdisp0,
	output [0:6] segdisp1,
	output [15:0] led,
	output baseram_oe,
	output baseram_ce,
	output baseram_we,
	output reg uart_enable_recv,
	output reg uart_TxD_start,
	input uart_TxD_busy,
	input uart_RxD_data_ready,
	input uart_RxD_waiting_data,
	output uart_rst);

	assign baseram_oe = 1;
	assign baseram_ce = 1;
	assign baseram_we = 1;
	assign uart_rst = ~rst;

	/*
	* receive NULL terminated string, calc xor of chars
	*/

	reg is_write;
	reg [7:0] data_to_write;
	assign baseram_data = is_write ? data_to_write : {8{1'bz}};

	reg [7:0] frame_num_shift;
	assign led = {frame_num_shift,
		4'b0, is_write, uart_TxD_busy, uart_RxD_data_ready, uart_RxD_waiting_data};

	digseg_driver disp_data_high(.data(data_to_write[7:4]), .seg(segdisp1));
	digseg_driver disp_data_low(.data(data_to_write[3:0]), .seg(segdisp0));

	reg state;
	always @(posedge clk) begin
		if (uart_rst) begin
			data_to_write <= 0;
			is_write <= 0;
		end else if (is_write) begin
			uart_enable_recv <= 0;
			if (state == 0) begin
				state <= 1;
				uart_TxD_start <= 1;
			end else if (state == 1) begin
				uart_TxD_start <= 0;
				if (~uart_TxD_busy) begin
					state <= 0;
					data_to_write <= 0;
					is_write <= 0;
				end
			end else
				state <= 0;
		end else begin
			uart_enable_recv <= 1;
			if (uart_RxD_data_ready) begin
				data_to_write <= data_to_write ^ baseram_data;
				frame_num_shift <= {frame_num_shift[6:0], !frame_num_shift[6:0]};
				if (!baseram_data) begin
					state <= 0;
					is_write <= 1;
				end
			end
		end
	end


endmodule


