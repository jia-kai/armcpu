/*
 * $File: cp0.v
 * $Date: Wed Nov 20 16:47:17 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`timescale 1ns/1ps
`include "cp0_def.vh"

// coprocessor 0
// this implementation differs from MIPS standard in following ways:
// 1. some registers are not implemented
// 2. if write to predifined fieds (e.g. EBase[31:30]), the standard requires
//	original valus is returned on next read; but the value newly written would
//	be returned in this simplified cp0 design
module cp0(
	input clk,
	input rst,
	input add_counter,	// whether to add counter reg in this cycle
	output [`CP0_REG_TOT_WIDTH-1:0] cp0_reg,

	// set to other than CP0_REG_NONE before posedge to write into cp0
	// reg; should not read and write at the same time
	input [`CP0_REG_ADDR_WIDTH-1:0] reg_write_addr,
	input [31:0] reg_write_data,

	// set exc_code to other than EC_NONE before posedge to prepare for
	// exception; exc_jmp_flag would be set on next posedge
	input [`INT_MASK_WIDTH-1:0] exc_ip,
	input [`EXC_CODE_WIDTH-1:0] exc_code,
	input [31:0] exc_epc,
	input [31:0] exc_badvaddr,

	// updated at posedge
	output reg exc_jmp_flag,
	output reg [31:0] exc_jmp_dest);

	// ------------------------------------------------------------------

	reg [31:0] regmem[0:`CP0_NR_REG-1];

	genvar i;
	generate
		for (i = 0; i < `CP0_NR_REG; i = i + 1) begin: CP0_REG_WIND
			assign `CP0_VISIT_REG(cp0_reg, i) = regmem[i];
		end
	endgenerate

	task set_vector_offset(input [29:0] offset);
		exc_jmp_dest <= {2'b10, offset + {regmem[`CP0_EBASE][29:12], 12'b0}};
	endtask


	task setup_exc; begin
		$display("time=%g: impending exception: ip=%b code=%h epc=%h",
			$time, exc_ip, exc_code, exc_epc);

		// no other modification when EXL = 1,
		// see MIPS32 Architecture For Programmers, ch5
		if (regmem[`CP0_STATUS][1])
			set_vector_offset(30'h180);
		else begin
			regmem[`CP0_EPC] <= exc_epc;
			regmem[`CP0_BADVADDR] <= exc_badvaddr;
			regmem[`CP0_CAUSE][15:8] <= exc_ip;
			regmem[`CP0_CAUSE][6:2] <= exc_code;
			regmem[`CP0_STATUS][1] <= 1;	// EXL

			/*
			if (`EC_IS_TLB_REFILL(exc_code))
				set_vector_offset(30'h0);
			else 
				set_vector_offset(30'h180);
			*/
			set_vector_offset(30'h180);	// required by ucore ?
		end

		exc_jmp_flag <= 1;

	end endtask

	task perform_eret; begin
		regmem[`CP0_STATUS][1] <= 0;	// EXL
		exc_jmp_flag <= 1;
		exc_jmp_dest <= regmem[`CP0_EPC];
	end endtask

	always @(posedge clk) begin
		exc_jmp_flag <= 0; // only assert exc_jmp_flag for 1 cycle
		if (rst) begin: RESET_CP0
			integer i;
			for (i = 0; i < `CP0_NR_REG; i = i + 1)
				regmem[i] <= 0;
		end begin
			if (add_counter)
				regmem[`CP0_COUNT] <= regmem[`CP0_COUNT] + 1'b1;

			case (exc_code)
				`EC_NONE:
					if (reg_write_addr != `CP0_REG_NONE) begin
						regmem[reg_write_addr] <= reg_write_data;

						// clear timer interrupt when writing to compare
						if (reg_write_addr == `CP0_COMPARE)
							regmem[`CP0_CAUSE][15] <= 0;
					end
				`EC_ERET:
					perform_eret();
				default:
					setup_exc();
			endcase
		end
	end

endmodule

