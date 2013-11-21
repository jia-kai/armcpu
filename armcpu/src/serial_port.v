/*
 * $File: serial_port.v
 * $Date: Thu Nov 21 16:47:55 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */


// interrupt for serial port
module serial_port(
	input clk,
	input rst,
	output reg int_req,
	input int_ack,
	output reg [7:0] data_out,
	input [7:0] data_in,

	// when write_busy == 0, assert for one cycle to enable write, 
	input write_enable,
	output write_busy,


	// physical interface
	output com_TxD,
	input com_RxD);

	// ------------------------------------------------------------------

	localparam CLK_FREQ = 50000000,	// 50 MB
			BAUD = 115200;
	
	uart_async_transmitter #(.ClkFrequency(CLK_FREQ), .Baud(BAUD)) utrans
		(.clk(clk), .TxD_start(write_enable && !write_busy), .TxD_data(data_in),
		.TxD(com_TxD), .TxD_busy(write_busy));


	wire RxD_data_ready;
	wire [7:0] RxD_data;
	uart_async_receiver #(.ClkFrequency(CLK_FREQ), .Baud(BAUD)) urecv
		(.clk(clk), .rst(rst), .RxD(com_RxD),
		.RxD_data_ready(RxD_data_ready), .RxD_waiting_data(),
		.RxD_data(RxD_data));

	always @(posedge clk)
		if (rst || int_ack)
			int_req <= 0;
		else if (RxD_data_ready && !int_req) begin
			int_req <= 1;
			data_out <= RxD_data;
		end

endmodule

