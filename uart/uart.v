/*
 * $File: uart.v
 * $Date: Sat Oct 26 19:34:59 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

module uart(
	input clk,
	input rst,	// assert to reset the status of receiver
	input enable_recv,
	inout [7:0] data,
	input TxD_start,
	output TxD_busy,
	output RxD_data_ready,
	output RxD_waiting_data,
	output TxD,
	input RxD);

	localparam CLK_FREQ = 50000000,	// 50 MB
			BAUD = 115200;

	wire [7:0] data_recv;

	assign data = enable_recv ? data_recv : {8{1'bz}};

	async_transmitter #(.ClkFrequency(CLK_FREQ), .Baud(BAUD)) u0
	(.clk(clk), .TxD_start(TxD_start), .TxD_data(data),
	.TxD(TxD), .TxD_busy(TxD_busy));

	async_receiver #(.ClkFrequency(CLK_FREQ), .Baud(BAUD)) u1
	(.clk(clk), .rst(rst), .RxD(RxD),
	.RxD_data_ready(RxD_data_ready), .RxD_waiting_data(RxD_waiting_data),
	.RxD_data(data_recv), .RxD_idle(), .RxD_endofpacket());

endmodule

