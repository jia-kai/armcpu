/*
 * $File: test.v
 * $Date: Sun Nov 17 12:32:10 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

module test(
	input clk50M,
	input rst,
	output [0:6] segdisp0,
	output [0:6] segdisp1,

	output reg [15:0] led,
	input [31:0] params,

	// ram interface
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


	reg clk_cpu;
	wire [23:0] cpu_speed = params[23:0];
	wire [7:0] ram_read_wait = params[31:24];
	reg [23:0] clk50M_cnt;
	always @(posedge clk50M) begin
		if (clk50M_cnt >= cpu_speed) begin
			clk50M_cnt <= 0;
			clk_cpu <= ~clk_cpu;
		end else
			clk50M_cnt <= clk50M_cnt + 1'b1;
	end

	wire [31:0] monitor_data;

	system usys(.clk_cpu(clk_cpu), .clk_mem(clk50M), .rst(~rst),
		.ram_read_wait(ram_read_wait),
		.debug_out(monitor_data),
		.baseram_addr(baseram_addr), .baseram_data(baseram_data),
		.baseram_ce(baseram_ce), .baseram_oe(baseram_oe), .baseram_we(baseram_we),
		.extram_addr(extram_addr), .extram_data(extram_data),
		.extram_ce(extram_ce), .extram_oe(extram_oe), .extram_we(extram_we));

	always @(posedge clk_cpu)
		led[7:0] <= {led[6:0], !led[6:0]};

	always @(posedge clk50M)
		led[15:8] <= monitor_data[7:0];

	digseg_driver useg0(.data(monitor_data[21:18]), .seg(segdisp0));
	digseg_driver useg1(.data(monitor_data[25:22]), .seg(segdisp1));

endmodule

