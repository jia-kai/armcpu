/*
 * $File: register_file.v
 * $Date: Fri Nov 15 20:39:32 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

module register_file(
	input clk,
	input rst,
	input [4:0] read1_addr,
	input [4:0] read2_addr,

	// if not 0 on negedge, would write to the register
	input [4:0] write_addr,

	input [31:0] data_in,
	output [31:0] data_out1,
	output [31:0] data_out2,
	output [31:0] debug_out);

	reg [31:0] mem [0:31];

	assign data_out1 = mem[read1_addr];
	assign data_out2 = mem[read2_addr];

	assign debug_out = mem[4];

	always @(negedge clk)
		if (rst) begin: RESET_REG
			integer i;
			for (i = 0; i < 32; i = i + 1)
				mem[i] <= 0;
		end else if (write_addr != 0)
			mem[write_addr] <= data_in;

endmodule

