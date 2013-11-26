/*
 * $File: cp0.v
 * $Date: Tue Nov 26 19:42:05 2013 +0800
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
// 3. select field is ignored (e.g. mfc0 $t0, $15, 0 and mfc0 $t0, $15, 1 both
// setup EBase)
module cp0(
	input clk,
	input rst,
	output [`CP0_REG_TOT_WIDTH-1:0] cp0_reg,

	// set to other than CP0_REG_NONE before posedge to write into cp0
	// reg; should not read and write at the same time
	input [`CP0_REG_ADDR_WIDTH-1:0] reg_write_addr,
	input [31:0] reg_write_data,

	// set exc_code to other than EC_NONE before posedge to prepare for
	// exception; exc_jmp_flag would be set on next posedge
	input [`EXC_CODE_WIDTH-1:0] exc_code,
	input [31:0] exc_epc,
	input [31:0] exc_badvaddr,

	// ip field of Cause register
	input [`INT_MASK_WIDTH-1:0] cause_ip,

	output reg int_timer_req,

	// updated at posedge
	output reg exc_jmp_flag,
	output reg [31:0] exc_jmp_dest);

	// ------------------------------------------------------------------

	// note the dummy entry regmem[`CP0_NR_REG], so no need to check whether
	// write_addr != `CP0_REG_NONE
	reg [31:0] regmem[0:`CP0_NR_REG];

	genvar i;
	generate
		for (i = 0; i < `CP0_NR_REG; i = i + 1) begin: CP0_REG_WIND
			if (i != `CP0_CAUSE)
				assign `CP0_VISIT_REG(cp0_reg, i) = regmem[i];
			else
				assign `CP0_VISIT_REG(cp0_reg, i) = {16'b0, cause_ip, regmem[i][7:0]};
		end
	endgenerate

	assign exc_is_tlb_refill = (exc_code == `EC_TLBL || exc_code == `EC_TLBS),
			exc_is_tlb = (exc_is_tlb_refill || exc_code == `EC_TLB_MOD);

	task set_vector_offset(input [29:0] offset);
		exc_jmp_dest <= {2'b10, offset + {regmem[`CP0_EBASE][29:12], 12'b0}};
	endtask


	task setup_exc; begin
		$display("time=%g impending exception: ip=%b code=%h epc=%h",
			$time, cause_ip, exc_code, exc_epc);

		// no other modification when EXL = 1,
		// see MIPS32 Architecture For Programmers, ch5
		if (regmem[`CP0_STATUS][1])
			set_vector_offset(30'h180);
		else begin
			regmem[`CP0_EPC] <= exc_epc;
			regmem[`CP0_BADVADDR] <= exc_badvaddr;
			regmem[`CP0_CAUSE][6:2] <= exc_code;
			regmem[`CP0_STATUS][1] <= 1;	// EXL

			if (exc_is_tlb_refill)
				set_vector_offset(30'h0);
			else 
				set_vector_offset(30'h180);

			if (exc_is_tlb)
				regmem[`CP0_ENTRY_HI][31:13] <= exc_badvaddr[31:13];
		end

		exc_jmp_flag <= 1;

	end endtask

	task perform_eret; begin
		regmem[`CP0_STATUS][1] <= 0;	// EXL
		exc_jmp_flag <= 1;
		exc_jmp_dest <= regmem[`CP0_EPC];
		$display("time=%g eret: %h", $time, regmem[`CP0_EPC]);
	end endtask

	always @(posedge clk) begin
		// only assert exc_jmp_flag and int_timer_ack for 1 cycle
		exc_jmp_flag <= 0;

		if (rst) begin: RESET_CP0
			integer i;
			int_timer_req <= 0;
			for (i = 0; i < `CP0_NR_REG; i = i + 1)
				regmem[i] <= 0;
		end else begin
			regmem[`CP0_COUNT] <= regmem[`CP0_COUNT] + 1'b1;
			if (regmem[`CP0_COUNT] == regmem[`CP0_COMPARE])
				int_timer_req <= 1;

			case (exc_code)
				`EC_NONE: begin
					// clear timer interrupt when writing to compare
					if (reg_write_addr == `CP0_COMPARE)
						int_timer_req <= 0;
					regmem[reg_write_addr] <= reg_write_data;
				end
				`EC_ERET:
					perform_eret();
				default:
					setup_exc();
			endcase
		end
	end

endmodule

