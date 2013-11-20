/*
 * $File: alu.v
 * $Date: Wed Nov 20 08:47:45 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`include "alu_opt.vh"

module alu(
	input [31:0] opr1,
	input [31:0] opr2,
    input [31:0] sa_imm,
	input [`ALU_OPT_WIDTH-1:0] opt,
	output reg [31:0] result,
	output reg illegal_opt);

	always @(*) begin
		illegal_opt = 0;
		result = 0;
		case (opt)
            `ALU_OPT_SLL_IMM:
                result = opr2 << sa_imm;
			`ALU_OPT_ADDU:
				result = opr1 + opr2;
			`ALU_OPT_SUBU:
				result = opr1 - opr2;
			`ALU_OPT_OR:
				result = opr1 | opr2;
			`ALU_OPT_XOR:
				result = opr1 ^ opr2;
            `ALU_OPT_LT:
                result = $signed(opr1) < $signed(opr2) ? 32'b1 : 0;
            `ALU_OPT_SETU:
                result = {opr2[31:16], opr1[15:0]};
            `ALU_OPT_PASS_OPR1:
                result = opr1;
            default: begin
                $warning("illegal alu opt: %h", opt);
				illegal_opt = 1;
            end
		endcase
	end
endmodule

