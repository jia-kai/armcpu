/*
 * $File: alu.v
 * $Date: Fri Nov 15 18:11:24 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`include "alu_opt.vh"

module alu(
	input [31:0] opr1,
	input [31:0] opr2,
	input [`ALU_OPT_WIDTH-1:0] opt,
	output reg [31:0] result,
	output reg illegal_opt);

	always @(*) begin
		illegal_opt = 0;
		result = 0;
		case (opt)
			`ALU_OPT_DISABLE:
				result = 0;
			`ALU_OPT_ADDU:
				result = opr1 + opr2;
			`ALU_OPT_SUBU:
				result = opr1 - opr2;
			`ALU_OPT_OR:
				result = opr1 | opr2;
			default:
				illegal_opt = 1;
		endcase
	end
endmodule

