/*
 * $File: multiplier_wrapper.v
 * $Date: Sat Nov 23 20:22:18 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`define WAIT_CYCLE	8
`include "lohi_def.vh"

// wrap around xilinx multiplier core, and provide hi/lo register
module multiplier_wrapper(
	input clk,
	input [31:0] opr1,
	input [31:0] opr2,
	output reg [63:0] result,
	input [`LOHI_WRITE_OPT_WIDTH-1:0] write_opt,
	input [31:0] write_data,
	output ready);

	wire [63:0] cur_product;
	reg [31:0] prev_opr1 = 0, prev_opr2 = 0, cur_opr1 = 0, cur_opr2 = 0;

	multiplier umult(.clk(clk), .a(cur_opr1), .b(cur_opr2), .p(cur_product));

	assign ready = (opr1 == prev_opr1 && opr2 == prev_opr2);

	reg [3:0] wait_cnt;

	always @(posedge clk) begin
		if (cur_opr1 != opr1 || cur_opr2 != opr2) begin
			cur_opr1 <= opr1;
			cur_opr2 <= opr2;
			wait_cnt <= 0;
		end else begin
			wait_cnt <= wait_cnt + 1;
			if (wait_cnt == `WAIT_CYCLE) begin
				prev_opr1 <= cur_opr1;
				prev_opr2 <= cur_opr2;
				result <= cur_product;
			end
		end
		case (write_opt)
			`LOHI_WRITE_LO:
				result[31:0] <= write_data;
			`LOHI_WRITE_HI:
				result[63:32] <= write_data;
		endcase
	end

endmodule


