/*
 * $File: stage_mem.v
 * $Date: Thu Nov 21 17:19:38 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`include "common.vh"
`include "mem_opt.vh"
`include "gencode/ex2mem_param.v"
`include "int_def.vh"

// memory read/write
module stage_mem(
	input clk,
	input rst,

	input [`EX2MEM_WIRE_WIDTH-1:0] interstage_ex2mem,

	output reg [`REGADDR_WIDTH-1:0] wb_reg_addr,
	output reg [31:0] wb_reg_data,

	output set_stall,
	output set_clear,

	output exc_jmp_flag,
	output [31:0] exc_jmp_dest,

	output [`CP0_REG_TOT_WIDTH-1:0] cp0_reg,

	// handle interrupt; interface to misc divices
	input [`INT_MASK_WIDTH-1:0] int_req,
	output int_timer_ack,

	// interface to MMU
	output [`TLB_WRITE_STRUCT_WIDTH-1:0] mmu_tlb_write_struct,
	output reg [31:0] mmu_addr,
	input [31:0] mmu_data_in,
	output reg [31:0] mmu_data_out,
	output reg [`MEM_OPT_WIDTH-1:0] mmu_opt,
	input [`EXC_CODE_WIDTH-1:0] mmu_exc_code,
	input mmu_busy);

	// ------------------------------------------------------------------

	`include "gencode/ex2mem_extract_load.v"

	reg state;
	localparam READY = 1'b0, WAIT = 1'b1;

	reg [`REGADDR_WIDTH-1:0] wb_reg_addr_latch;

	reg [`EXC_CODE_WIDTH-1:0] cp0_exc_code;
	reg [`CP0_REG_ADDR_WIDTH-1:0] cp0_write_addr;
	reg [31:0] cp0_exc_epc, cp0_exc_badvaddr, cp0_write_data;

	assign set_stall = (state != READY);
	assign set_clear = (cp0_exc_code != `EC_NONE);

	wire [31:0] cp0_reg_unwind [0:`CP0_NR_REG-1];
	wire [31:0] cp0_status = cp0_reg_unwind[`CP0_STATUS];

	genvar i;
	generate
		for (i = 0; i < `CP0_NR_REG; i = i + 1) begin: CP0_REG_UNWIND
			assign cp0_reg_unwind[i] = `CP0_VISIT_REG(cp0_reg, i);
		end
	endgenerate


	assign has_int_pending = (int_req & cp0_status[15:8]) != 0 &&
		cp0_status[0] /* IE */ && !cp0_status[1] /* EXL */;

	cp0 ucp0(.clk(clk), .rst(rst),
		.cp0_reg(cp0_reg),
		.reg_write_addr(cp0_write_addr), .reg_write_data(cp0_write_data),
		.exc_code(cp0_exc_code),
		.exc_epc(cp0_exc_epc), .exc_badvaddr(cp0_exc_badvaddr),
		.cause_ip(int_req),
		.int_timer_ack(int_timer_ack),
		.exc_jmp_flag(exc_jmp_flag), .exc_jmp_dest(exc_jmp_dest));

	
	reg tlb_write_enable;
	reg [`TLB_ENTRY_WIDTH-1:0] tlb_entry;
	reg [`TLB_INDEX_WIDTH-1:0] tlb_index;
	assign mmu_tlb_write_struct = {tlb_write_enable, tlb_index, tlb_entry};
	
	task proc_mem_opt; 
		case (mem_opt_ex2mem) 
			`MEM_OPT_WRITE_CP0: begin
				state <= WAIT;
				cp0_write_addr <= mem_addr_ex2mem[`CP0_REG_ADDR_WIDTH-1:0];
				cp0_write_data <= mem_data_ex2mem;
			end
			`MEM_OPT_READ_CP0:
				wb_reg_data <= cp0_reg_unwind[mem_addr_ex2mem];
			`MEM_OPT_WRITE_TLB_IDX: begin
				state <= WAIT;
				tlb_write_enable <= 1;
				tlb_index <= cp0_reg_unwind[`CP0_INDEX][`TLB_INDEX_WIDTH-1:0];
				tlb_entry <= {cp0_reg_unwind[`CP0_ENTRY_HI][31:13],
					cp0_reg_unwind[`CP0_ENTRY_LO1][25:6],
					cp0_reg_unwind[`CP0_ENTRY_LO1][2:1],
					cp0_reg_unwind[`CP0_ENTRY_LO0][25:6],
					cp0_reg_unwind[`CP0_ENTRY_LO0][2:1]};
			end
			default: if (mem_opt_ex2mem != `MEM_OPT_NONE) begin
				state <= WAIT;
				mmu_opt <= mem_opt_ex2mem;
				mmu_addr <= mem_addr_ex2mem;
				mmu_data_out <= mem_data_ex2mem;
				wb_reg_addr <= 0;
			end
		endcase
	endtask

	always @(negedge clk) begin
		// thoses signals should be asserted for at most 1 cycle
		mmu_opt <= `MEM_OPT_NONE;
		cp0_write_addr <= `CP0_REG_NONE;
		tlb_write_enable <= 0;

		if (rst) begin
			state <= READY;
			cp0_exc_code <= `EC_NONE;
		end else case (state)
			READY: begin
				cp0_exc_epc <= exc_epc_ex2mem;
				cp0_exc_badvaddr <= 0;
				wb_reg_addr_latch <= wb_reg_addr_ex2mem;
				if (exc_code_ex2mem != `EC_NONE) begin
					cp0_exc_code <= exc_code_ex2mem;
					cp0_exc_badvaddr <= exc_badvaddr_ex2mem;
				end else if (has_int_pending)
					cp0_exc_code <= `EC_INT;
				else begin
					cp0_exc_code <= `EC_NONE;
					wb_reg_addr <= wb_reg_addr_ex2mem;
					wb_reg_data <= alu_result;
					proc_mem_opt();
				end
			end
			WAIT:
				if (mmu_exc_code != `EC_NONE) begin
					state <= READY;
					cp0_exc_code <= mmu_exc_code;
					cp0_exc_badvaddr <= mmu_addr;
				end else if (!mmu_busy) begin
					state <= READY;
					wb_reg_data <= mmu_data_in;
					wb_reg_addr <= wb_reg_addr_latch;
				end
		endcase
	end

endmodule

