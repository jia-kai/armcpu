/*
 * $File: mmu.v
 * $Date: Tue Nov 26 20:22:03 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`include "mem_opt.vh"
`include "common.vh"

// memory management unit
module mmu(
	input clk,
	input rst,

	input [`TLB_WRITE_STRUCT_WIDTH-1:0] tlb_write_struct,

	input [31:0] instr_addr,
	output [31:0] instr_out,

	// data_in would be latched on posedge on data_opt is write,
	// but data_addr would not
	// data_opt should only be set for one cycle
	input [`MEM_OPT_WIDTH-1:0] data_opt,
	input [31:0] data_addr,
	input [31:0] data_in,
	// data_out is valid for one cycle after busy is deasserted
	output reg [31:0] data_out,

	// busy would be asserted immediately after data_opt != NONE,
	// before next clock edge
	output busy,

    // first check exception; if it happens, no actual operation would be
    // performed and busy is not set
    output reg [`EXC_CODE_WIDTH-1:0] exc_code,
	
	// interface to physical memory controller
	// it is required to response before next posedge
	// and also latch both data and addr, if multiple-cycle for one operation
	// needed
	output reg [31:0] dev_mem_addr,
	input [31:0] dev_mem_data_in,
	output reg [31:0] dev_mem_data_out,
	output dev_mem_is_write,
	input dev_mem_busy);

	// ------------------------------------------------------------------

	always @(*) begin
		if (instr_addr[1:0])
			$warning("time=%g unaligned instr_addr: %h", $time, instr_addr);
	end

	wire tlb_write_enable;
	wire [`TLB_INDEX_WIDTH-1:0] tlb_write_index;
	wire [`TLB_ENTRY_WIDTH-1:0] tlb_write_entry;
	reg tlb_missing, tlb_writable;
	reg [`TLB_ENTRY_WIDTH-1:0] tlb_mem[0:`TLB_NR_ENTRY-1];

	assign {tlb_write_enable, tlb_write_index, tlb_write_entry} = tlb_write_struct;


	assign mem_opt_is_write = `MEM_OPT_IS_WRITE(data_opt);
	assign instr_out = dev_mem_data_in;

	localparam READ = 2'b00, WRITE_SB = 2'b01, WRITE_DO_WRITE = 2'b10;
	reg [1:0] state;

	// if multiple-cycle read is needed, dev_mem_busy should be set before
	// next posedge, so busy is also set
	assign busy =
		(state != READ || dev_mem_busy || mem_opt_is_write) &&
        exc_code == `EC_NONE;


    wire [31:0]
		mem_unaligned_addr =
			state == READ && data_opt == `MEM_OPT_NONE ? instr_addr : data_addr,
		mem_vrt_addr = {mem_unaligned_addr[31:2], 2'b00};


	assign dev_mem_is_write = state == WRITE_DO_WRITE;


	// select a byte in input word according to addr
    reg [7:0] dev_mem_data_in_selected_byte;
    always @(*)
        case (mem_unaligned_addr[1:0])
            0: dev_mem_data_in_selected_byte = dev_mem_data_in[7:0];
            1: dev_mem_data_in_selected_byte = dev_mem_data_in[15:8];
            2: dev_mem_data_in_selected_byte = dev_mem_data_in[23:16];
            3: dev_mem_data_in_selected_byte = dev_mem_data_in[31:24];
        endcase


	// handle exception
    always @(*) begin
		// TODO: check user/kernel permission
        exc_code = `EC_NONE;
        if (mem_unaligned_addr[1:0]) begin
			if (state == READ && (data_opt == `MEM_OPT_LW || data_opt == `MEM_OPT_NONE)) begin
                exc_code = `EC_ADEL;
				$warning("time=%g unaligned mem_addr read, data_opt=%h: %h", $time,
					data_opt, mem_unaligned_addr);
			end
			if (data_opt == `MEM_OPT_SW) begin
                exc_code = `EC_ADES;
				$warning("time=%g unaligned mem_addr write word: %h", $time,
					mem_unaligned_addr);
			end
		end else if (tlb_missing) begin
			if (mem_opt_is_write) begin
				exc_code = `EC_TLBS;
				$warning("time=%g TLB write missing, vaddr=%h",
					$time, mem_vrt_addr);
			end else begin
				exc_code = `EC_TLBL;
				$warning("time=%g TLB read missing, vaddr=%h",
					$time, mem_vrt_addr);
			end
		end else if (!tlb_writable && mem_opt_is_write) begin
			exc_code = `EC_TLB_MOD;
			$warning("time=%g write to read-only page, vaddr=%h",
				$time, mem_vrt_addr);
		end
    end

	// virtual addr to physical addr
	always @(*) begin
		// TODO: user/kernel permission check
		dev_mem_addr = 0;
		tlb_missing = 0;
		tlb_writable = 0;
		if (mem_vrt_addr[31:28] >= 4'h8 && mem_vrt_addr[31:28] <= 4'hb) begin
			// direct mapping; cache unimplemented
			dev_mem_addr = {3'b0, mem_vrt_addr[28:0]};
			tlb_writable = 1;
		end else begin: TLB_LOOKUP
			integer i;
			tlb_missing = 1;

			// XXX: verilog has no break ...
			for (i = `TLB_NR_ENTRY - 1; i >= 0; i = i - 1) begin
				if (tlb_mem[i][62:44] == mem_vrt_addr[31:13]) begin
					if (mem_vrt_addr[12] && tlb_mem[i][22]) begin
						tlb_missing = 0;
						tlb_writable = tlb_mem[i][23];
						dev_mem_addr = {tlb_mem[i][43:24], mem_vrt_addr[11:0]};
					end else if (!mem_vrt_addr[12] && tlb_mem[i][0]) begin
						tlb_missing = 0;
						tlb_writable = tlb_mem[i][1];
						dev_mem_addr = {tlb_mem[i][21:2], mem_vrt_addr[11:0]};
					end

				end
			end
		end
	end

	// assign data output
	always @(*)
		if (data_opt == `MEM_OPT_LW)
			data_out = dev_mem_data_in;
		else if (data_opt == `MEM_OPT_LBS)
            data_out = {{24{dev_mem_data_in_selected_byte[7]}}, dev_mem_data_in_selected_byte};
		else if (data_opt == `MEM_OPT_LBU)
            data_out = {{24'b0}, dev_mem_data_in_selected_byte};
		else
			data_out = 0;


	// main fsm
	always @(posedge clk)
		if (rst)
			state <= READ;
		else case (state)
			READ: if (!dev_mem_busy &&
                    data_opt != `MEM_OPT_NONE && exc_code == `EC_NONE) begin
				dev_mem_data_out <= data_in;
				if (data_opt == `MEM_OPT_SB)
					state <= WRITE_SB;
				else if (data_opt == `MEM_OPT_SW)
					state <= WRITE_DO_WRITE;
			end
            WRITE_SB: begin: WRITE_BYTE_INIT
                integer i, j;
                for (i = 0; i < 4; i = i + 1)
                    if (mem_unaligned_addr[1:0] != i) begin
                        for (j = i * 8; j < (i + 1) * 8; j = j + 1)
                            dev_mem_data_out[j] <= dev_mem_data_in[j];
                    end else begin
                        for (j = 0; j < 8; j = j + 1)
                            dev_mem_data_out[j + i * 8] <= dev_mem_data_out[j];
                    end
				state <= WRITE_DO_WRITE;
			end
			WRITE_DO_WRITE:
				state <= READ;
			default:
				state <= READ;
		endcase


	// handl tlb write
	always @(posedge clk)
		if (rst) begin: INIT_TLB
			integer i;
			for (i = 0; i < `TLB_NR_ENTRY; i = i + 1)
				tlb_mem[i] <= 0;
		end else if (tlb_write_enable) begin
			tlb_mem[tlb_write_index] <= tlb_write_entry;
			$display("time=%g write TLB: index=%h VPN2=%h P1=(%h, %b) P0=(%h, %b)",
				$time, tlb_write_index, tlb_write_entry[62:44],
				tlb_write_entry[43:24], tlb_write_entry[23:22],
				tlb_write_entry[21:2], tlb_write_entry[1:0]);
		end

endmodule

