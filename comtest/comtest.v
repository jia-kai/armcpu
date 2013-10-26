/*
 * $File: comtest.v
 * $Date: Sat Oct 26 20:04:47 2013 +0800
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
	output uart_enable_recv,
	output uart_TxD_start,
	input uart_TxD_busy,
	input uart_RxD_data_ready,
	input uart_RxD_waiting_data,
	output uart_rst);

	assign baseram_oe = 1;
	assign baseram_ce = 1;
	assign baseram_we = 1;
	assign uart_rst = ~rst;

	assign uart_TxD_start = 0;
	assign uart_enable_recv = 1;

	reg [7:0] frame_num;
	reg [7:0] prev_recv_data;

	assign led = {prev_recv_data,
		5'b0, uart_RxD_data_ready, uart_RxD_waiting_data};

	always @(posedge clk) begin
		if (~rst) begin
			frame_num <= 0;
			prev_recv_data <= 0;
		end else
			if (uart_RxD_data_ready) begin
				prev_recv_data <= baseram_data;
				frame_num <= frame_num + 1'b1;
			end
	end

	digseg_driver data_disp_high(
		.data(frame_num[7:4]),
		.seg(segdisp1));

	digseg_driver data_disp_low(
		.data(frame_num[3:0]),
		.seg(segdisp0));

	/*
	reg [7:0] frame_num_indicator;
	reg [7:0] data_to_write;
	reg [7:0] data_from_com_prev;
	reg is_write;
	reg [2:0] state;

	assign led = {frame_num_indicator, 
		state[1:0],
		is_write, uart_tbre, uart_tsre, uart_data_ready,
		uart_framing_error, uart_parity_error};

	digseg_driver data_disp_high(
		.data(data_from_com_prev[7:4]),
		.seg(segdisp1));

	digseg_driver data_disp_low(
		.data(data_from_com_prev[3:0]),
		.seg(segdisp0));
	


	assign baseram_data = is_write ? data_to_write : {8{1'bz}};


	always @(posedge clk) begin
		if (!rst) begin
			state <= 0;
			is_write <= 0;
			frame_num_indicator <= 0;
		end else if (is_write) begin
			// writing to com
			uart_rdn <= 1;
			if (state == 0) begin
				state <= 1;
				uart_wrn <= 1;
			end else if (state == 1) begin
				uart_wrn <= 0;
				state <= 2;
			end else if (state == 2) begin
				uart_wrn <= 1;
				state <= 3;
			end else if (state == 3) begin
				if (uart_tbre)
					state <= 4;
			end else if (state == 4) begin
				if (uart_tsre) begin
					is_write <= 0;
					state <= 0;
					data_to_write <= 0;
				end
			end else
				state <= 0;
		end else begin
			// reading from com
			uart_wrn <= 1;
			if (state == 0) begin
				state <= 1;
			end else if (state == 1) begin
				uart_rdn <= 1;
				state <= 2;
			end else if (state == 2) begin
				if (uart_data_ready) begin
					state <= 3;
					uart_rdn <= 0;
				end
			end else if (state == 3) begin
				data_to_write <= data_to_write ^ baseram_data;
				frame_num_indicator <= {frame_num_indicator[6:0],
					~(|frame_num_indicator[6:0])};

				if (|baseram_data) begin
					data_from_com_prev <= baseram_data;
					uart_rdn <= 1;
					state <= 2;
				end
				else begin
					is_write <= 1;
					state <= 0;
				end
			end else
				state <= 0;
		end

	end
	*/

endmodule


