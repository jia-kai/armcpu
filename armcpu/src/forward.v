/*
 * $File: forward.v
 * $Date: Fri Nov 15 19:57:00 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`include "common.vh"
`include "wb_src.vh"

// handle data harzard by forwarding
module forward(
	input [`REGADDR_WIDTH-1:0] alu_opr_reg_addr,
	input [31:0] ex2mem_alu_result,
	input [`REGADDR_WIDTH-1:0] ex2mem_wb_reg_addr,
	input [`WB_SRC_WIDTH-1:0] ex2mem_wb_src,
	input [`REGADDR_WIDTH-1:0] regfile_write_addr,
	input [31:0] regfile_write_data,
	output reg forward_enable,
	output reg [31:0] forward_data);

	assign fw_from_mem = 
		(ex2mem_wb_reg_addr == alu_opr_reg_addr &&
		ex2mem_wb_src == `WB_SRC_ALU);
	assign fw_from_regfile = (regfile_write_addr == alu_opr_reg_addr);

	always @(*) begin
		forward_enable = 0;
		forward_data = 0;
		if (alu_opr_reg_addr != 0) begin
			if (fw_from_mem) begin
				forward_enable = 1;
				forward_data = ex2mem_alu_result;
			end else if (fw_from_regfile) begin
				forward_enable = 1;
				forward_data = regfile_write_data;
			end
		end
	end

endmodule

