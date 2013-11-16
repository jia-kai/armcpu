/*
 * $File: forward.v
 * $Date: Sat Nov 16 09:53:09 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`include "common.vh"
`include "wb_src.vh"

// handle data harzard by forwarding
module forward(
	input [`REGADDR_WIDTH-1:0] opr_reg_addr,
	input [31:0] opr_reg_data,
	input [31:0] ex2mem_alu_result,
	input [`REGADDR_WIDTH-1:0] ex2mem_wb_reg_addr,
	input [`WB_SRC_WIDTH-1:0] ex2mem_wb_src,
	input [`REGADDR_WIDTH-1:0] regfile_write_addr,
	input [31:0] regfile_write_data,
	output reg [31:0] forward_data);

	assign fw_from_alu_rst = 
		(ex2mem_wb_reg_addr == opr_reg_addr && ex2mem_wb_src == `WB_SRC_ALU);
	assign fw_from_regfile = (regfile_write_addr == opr_reg_addr);

	always @(*) begin
		forward_data = opr_reg_data;
		if (opr_reg_addr) begin
			if (fw_from_alu_rst)
				forward_data = ex2mem_alu_result;
			else if (fw_from_regfile) 
				forward_data = regfile_write_data;
		end
	end
endmodule

