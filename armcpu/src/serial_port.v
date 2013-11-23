/*
 * $File: serial_port.v
 * $Date: Sat Nov 23 22:45:23 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */


// interrupt for serial port
module serial_port
	#(parameter CLK_FREQ = 0)
	(input clk,
	input rst,
	output reg int_req,
	input int_ack,
	output reg [7:0] data_out,
	input [7:0] data_in,

	// when write_busy == 0, assert for one cycle to enable write, 
	input write_enable,
	output write_busy,


	// physical interface
	output TxD,
	input RxD);

	// ------------------------------------------------------------------

	localparam BAUD = 115200;
	
	uart_async_transmitter #(.ClkFrequency(CLK_FREQ), .Baud(BAUD)) utrans
		(.clk(clk), .TxD_start(write_enable && !write_busy), .TxD_data(data_in),
		.TxD(TxD), .TxD_busy(write_busy));


	wire RxD_data_ready;
	wire [7:0] RxD_data;
	uart_async_receiver #(.ClkFrequency(CLK_FREQ), .Baud(BAUD)) urecv
		(.clk(clk), .rst(rst), .RxD(RxD),
		.RxD_data_ready(RxD_data_ready), .RxD_waiting_data(),
		.RxD_data(RxD_data));

	always @(posedge clk)
		if (rst || int_ack)
			int_req <= 0;
		else if (RxD_data_ready && !int_req) begin
			int_req <= 1;
			data_out <= RxD_data;
		end

	always @(posedge write_enable)
		if (write_busy)
			$warning("time=%g write to com while it is busy", $time);
		else
			$warning("time=%g write to com: %h", $time, data_in);

endmodule

