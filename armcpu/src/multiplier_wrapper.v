/*
 * $File: multiplier_wrapper.v
 * $Date: Thu Dec 19 20:45:21 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`define WAIT_CYCLE	14
`include "lohi_def.vh"

// wrap around xilinx multiplier core, and provide hi/lo register
module multiplier_wrapper(
	input clk,
	input start,	// start on posedge
	input [31:0] opr1,
	input [31:0] opr2,
	output reg [63:0] result,
	input [`LOHI_WRITE_OPT_WIDTH-1:0] write_opt,
	input [31:0] write_data,
	output ready);

	wire [63:0] cur_product;

	multiplier umult(.clk(clk), .a(opr1), .b(opr2), .p(cur_product));

	reg start_prev;
	reg [3:0] wait_cnt = 0;

	assign start_posedge = ~start_prev & start;
	assign ready = (wait_cnt == (`WAIT_CYCLE + 1) && !start_posedge);

	always @(posedge clk) begin
		start_prev <= start;
		if (start_posedge)
			wait_cnt <= 0;
		else if (wait_cnt < `WAIT_CYCLE)
			wait_cnt <= wait_cnt + 1'b1;
		else if (wait_cnt == `WAIT_CYCLE) begin
			result <= cur_product;
			wait_cnt <= wait_cnt + 1'b1;
		end
		case (write_opt)
			`LOHI_WRITE_LO:
				result[31:0] <= write_data;
			`LOHI_WRITE_HI:
				result[63:32] <= write_data;
		endcase
	end

endmodule


