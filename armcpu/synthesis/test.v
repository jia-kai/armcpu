/*
 * $File: test.v
 * $Date: Sun Nov 17 10:18:14 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

module test(
	input clk50M,
	input rst,
	output [0:6] segdisp0,
	output [0:6] segdisp1,

	output reg [15:0] led,
	input [31:0] cpu_nr_cycle,

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
	reg [31:0] cpu_cycle_cnt;
	always @(posedge clk50M) begin
		if (cpu_cycle_cnt < cpu_nr_cycle) begin
			clk_cpu <= ~clk_cpu;
			if (~clk_cpu)
				cpu_cycle_cnt <= cpu_cycle_cnt + 1'b1;
		end
		if (!rst)
			cpu_cycle_cnt <= 0;
	end

	wire [31:0] monitor_data;

	system usys(.clk_cpu(clk_cpu), .clk_mem(clk50M), .rst(~rst), .debug_out(monitor_data),
		.baseram_addr(baseram_addr), .baseram_data(baseram_data),
		.baseram_ce(baseram_ce), .baseram_oe(baseram_oe), .baseram_we(baseram_we),
		.extram_addr(extram_addr), .extram_data(extram_data),
		.extram_ce(extram_ce), .extram_oe(extram_oe), .extram_we(extram_we));

	always @(posedge clk_cpu)
		led <= {led[14:0], !led[14:0]};

	digseg_driver useg0(.data(monitor_data[21:18]), .seg(segdisp0));
	digseg_driver useg1(.data(monitor_data[25:22]), .seg(segdisp1));

endmodule

