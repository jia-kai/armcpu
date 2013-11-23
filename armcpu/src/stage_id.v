/*
 * $File: stage_id.v
 * $Date: Sat Nov 23 16:46:31 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`timescale 1ns/1ps

`include "alu_opt.vh"
`include "branch_opt.vh"
`include "mem_opt.vh"
`include "common.vh"

`include "gencode/if2id_param.v"
`include "gencode/id2ex_param.v"

// instruction decode
module stage_id(
	input clk,
	input rst,
	input stall,
    input clear,

	input [`IF2ID_WIRE_WIDTH-1:0] interstage_if2id,

    input in_delay_slot,

	// since reg[0] is always 0, no need for write enable signal;
	input [`REGADDR_WIDTH-1:0] reg_write_addr,
	input [31:0] reg_write_data,

	output reg [`REGADDR_WIDTH-1:0] reg1_addr,
	output reg [31:0] reg1_data,
	output reg [`REGADDR_WIDTH-1:0] reg2_addr,
	output reg [31:0] reg2_data,

	output [`ID2EX_WIRE_WIDTH-1:0] interstage_id2ex);

	// ------------------------------------------------------------------

	`include "gencode/if2id_extract_load.v"
	`include "gencode/id2ex_extract_store.v"

	wire [31:0] rf_data1, rf_data2;

	wire [5:0] instr_opcode = instr[31:26];
	wire [5:0] instr_func = instr[5:0];
	wire [4:0] instr_rs = instr[25:21], instr_rt = instr[20:16],
				instr_rd = instr[15:11], instr_sa = instr[10:6];
	wire [15:0] instr_imm = instr[15:0];
	wire [31:0] instr_imm_signext = {{16{instr_imm[15]}}, instr_imm},
				instr_imm_unsignext = {16'b0, instr_imm};

	
	wire [32:0]
        // pc-relative offset address
        branch_dest_pc_relative = {1'b0, next_pc + {instr_imm_signext[29:0], 2'b00}},
        // absolute jump in 256MB area
        branch_dest_pc_region = {1'b0, next_pc[31:28], instr[25:0], 2'b00};

	register_file uregfile(.clk(clk), .rst(rst),
		.read1_addr(instr_rs), .read2_addr(instr_rt),
		.write_addr(reg_write_addr), 
		.data_in(reg_write_data),
		.data_out1(rf_data1), .data_out2(rf_data2));

	reg [`CP0_REG_ADDR_WIDTH-1:0] instr_rd_cp0_regnum;
	always @(*)
		case (instr_rd)
			0: instr_rd_cp0_regnum = `CP0_INDEX;
			2: instr_rd_cp0_regnum = `CP0_ENTRY_LO0;
			3: instr_rd_cp0_regnum = `CP0_ENTRY_LO1;
			8: instr_rd_cp0_regnum = `CP0_BADVADDR;
			9: instr_rd_cp0_regnum = `CP0_COUNT;
			10: instr_rd_cp0_regnum = `CP0_ENTRY_HI;
			11: instr_rd_cp0_regnum = `CP0_COMPARE;
			12: instr_rd_cp0_regnum = `CP0_STATUS;
			13: instr_rd_cp0_regnum = `CP0_CAUSE;
			14: instr_rd_cp0_regnum = `CP0_EPC;
			15: instr_rd_cp0_regnum = `CP0_EBASE;
			default:
				instr_rd_cp0_regnum = `CP0_UNIMPLEMENTED;
		endcase

	task assign_reg1; begin
		reg1_addr <= instr_rs;
		reg1_data <= rf_data1;
	end endtask

	task assign_reg2; begin
		reg2_addr <= instr_rt;
		reg2_data <= rf_data2;
	end endtask

	// process rtype instructions
	task proc_rtype; begin
		wb_reg_addr_id2ex <= instr_rd;
		assign_reg1();
		assign_reg2();
		alu_sa_imm <= instr_sa;
		alu_src <= `ALU_SRC_REG;
		alu_opt <= instr_func;
	end endtask

    // set alu_opr2 from reg data
	task alu_from_reg(input [`ALU_OPT_WIDTH-1:0] opt); begin
		alu_src <= `ALU_SRC_REG;
		alu_opt <= opt;
	end endtask

    // set alu_opr2 from imm
	task alu_from_imm(input [`ALU_OPT_WIDTH-1:0] opt, input [31:0] imm); begin
		alu_src <= `ALU_SRC_IMM;
		alu_opt <= opt;
		alu_sa_imm <= imm;
	end endtask

    // setup for memory operations
	task mem_opt(input [`MEM_OPT_WIDTH-1:0] opt); begin
		assign_reg1();
		assign_reg2();
		alu_from_imm(`ALU_OPT_ADDU, instr_imm_signext);
		if (`MEM_OPT_IS_READ(opt))
			wb_reg_addr_id2ex <= instr_rt;
		mem_opt_id2ex <= opt;
	end endtask

    // write back, data from alu with imm opr
	task wb_with_alu_imm(input [`ALU_OPT_WIDTH-1:0] alu_opt, input [31:0] imm); begin
		wb_reg_addr_id2ex <= instr_rt;
		assign_reg1();
		alu_from_imm(alu_opt, imm);
	end endtask

    // helper for implementing conditional branch
    task proc_cond_branch(
            input set_reg,
            input [`ALU_OPT_WIDTH-1:0] alu_opt,
            input [`BRANCH_OPT_WIDTH-1:0] cond); begin
        if (set_reg) begin
            assign_reg1();
            assign_reg2();
        end
        alu_from_reg(alu_opt);
        branch_opt_id2ex <= cond;
        branch_dest_id2ex <= branch_dest_pc_relative;
    end endtask

    // set exception for invalid instruction
    task invalid_instruction; begin
        $warning("invalid instruction: %h", instr);
        exc_code_id2ex <= `EC_RI;
    end endtask

	// process itype instructions
	task proc_itype; begin
		case (instr_opcode)
            6'h01:
                case (instr_rt)
                    5'b00001: begin  // BGEZ
                        assign_reg1();
                        proc_cond_branch(1'b0, `ALU_OPT_LT, `BRANCH_ON_ALU_EQZ);
                    end
                    5'b00000: begin  // BLTZ 
                        assign_reg1();
                        proc_cond_branch(1'b0, `ALU_OPT_LT, `BRANCH_ON_ALU_NEZ);
                    end
                    default:
                        invalid_instruction();
                endcase
			6'h04:  // BEQ
                proc_cond_branch(1'b1, `ALU_OPT_XOR, `BRANCH_ON_ALU_EQZ);
			6'h05:  // BNE
                proc_cond_branch(1'b1, `ALU_OPT_XOR, `BRANCH_ON_ALU_NEZ);
			6'h06:  
				if (instr_rt == 5'b00000) begin  // BLEZ
					reg2_addr <= instr_rs;
					reg2_data <= rf_data1;
					proc_cond_branch(1'b0, `ALU_OPT_LT, `BRANCH_ON_ALU_EQZ);
				end else
					invalid_instruction();
			6'h07:
				if (instr_rt == 5'b00000) begin  // BGTZ
					reg2_addr <= instr_rs;
					reg2_data <= rf_data1;
					proc_cond_branch(1'b0, `ALU_OPT_LT, `BRANCH_ON_ALU_NEZ);
				end else
					invalid_instruction();
			6'h09:	// ADDIU
				wb_with_alu_imm(`ALU_OPT_ADDU, instr_imm_signext);
			6'h0a:	// SLTI
				wb_with_alu_imm(`ALU_OPT_LT, instr_imm_signext);
			6'h0b:	// SLTIU
				wb_with_alu_imm(`ALU_OPT_LTU, instr_imm_unsignext);
			6'h0c:	// ANDI
				wb_with_alu_imm(`ALU_OPT_AND, instr_imm_unsignext);
			6'h0d:	// ORI
				wb_with_alu_imm(`ALU_OPT_OR, instr_imm_unsignext);
			6'h0e:	// XORI
				wb_with_alu_imm(`ALU_OPT_XOR, instr_imm_unsignext);
			6'h0f:	// LUI
				wb_with_alu_imm(`ALU_OPT_SETU, {instr_imm, 16'b0});
			6'h20:	// LB
				mem_opt(`MEM_OPT_LBS);
			6'h23:	// LW
				mem_opt(`MEM_OPT_LW);
			6'h24:	// LBU
				mem_opt(`MEM_OPT_LBU);
			6'h28:	// SB
				mem_opt(`MEM_OPT_SB);
			6'h2b:	// SW
				mem_opt(`MEM_OPT_SW);
			default:
                invalid_instruction();
		endcase
	end endtask

	task proc_instr_j; begin
		branch_opt_id2ex <= `BRANCH_UNCOND;
		branch_dest_id2ex <= branch_dest_pc_region;
	end endtask

    task proc_instr_jr; begin
        branch_opt_id2ex <= `BRANCH_UNCOND;
        branch_dest_id2ex[32] <= 1; // set to reg2_data
		reg2_addr <= instr_rs;
		reg2_data <= rf_data1;
    end endtask

    task proc_instr_jal; begin
        proc_instr_j();
        reg1_data <= next_pc + 32'h4; 
        alu_opt <= `ALU_OPT_PASS_OPR1;
        wb_reg_addr_id2ex <= 31;
    end endtask

    task proc_instr_jalr; begin
        proc_instr_jal();
        proc_instr_jr();
        wb_reg_addr_id2ex <= instr_rd;
    end endtask

	task proc_instr_syscall; begin
		exc_code_id2ex <= `EC_SYS;
	end endtask

	task reset; begin
		branch_opt_id2ex <= `BRANCH_NONE;
		wb_reg_addr_id2ex <= 0;
		alu_opt <= `ALU_OPT_DISABLE;
        alu_sa_imm <= 0;
		reg1_addr <= 0;
		reg2_addr <= 0;
		mem_opt_id2ex <= `MEM_OPT_NONE;
        exc_code_id2ex <= `EC_NONE;
	end endtask

	task proc_cp0;
		if (instr_func == 6'h18)	// ERET
			exc_code_id2ex <= `EC_ERET;
		else if (instr_func == 6'h02)	// TLBWI
			mem_opt_id2ex <= `MEM_OPT_WRITE_TLB_IDX;
		else if (instr_rs == 0) begin	// MFC0
			mem_opt_id2ex <= `MEM_OPT_READ_CP0;
			reg1_data <= instr_rd_cp0_regnum;
			alu_opt <= `ALU_OPT_PASS_OPR1;
			wb_reg_addr_id2ex <= instr_rt;
		end else if (instr_rs == 5'b00100)	begin // MTC0
			mem_opt_id2ex <= `MEM_OPT_WRITE_CP0;
			reg1_data <= instr_rd_cp0_regnum;
			assign_reg2();
			alu_opt <= `ALU_OPT_PASS_OPR1;
		end else
			invalid_instruction();
	endtask

    task do_decode; begin
        case (instr_opcode)
            6'b000000: case(instr_func)
                6'h08: proc_instr_jr();
                6'h09: proc_instr_jalr();
				6'h0c: proc_instr_syscall();
                default: proc_rtype();
            endcase
            6'b000010:
                proc_instr_j();
            6'b000011:
                proc_instr_jal();
			6'b010000:
				proc_cp0();
			6'b101111: ;	// CACHE ignored
            default:
                proc_itype();
        endcase
        $display("\033[32m < -- id -- > time=%g got instruction: pc=%h instr=%h \033[0m",
            $time, next_pc - 4, instr);
    end endtask

	always @(posedge clk) begin
		if (rst)
			reset();
		else if (!stall) begin
			reset();
            if (!clear) begin
                if (exc_code_if2id != `EC_NONE) begin
                    exc_code_id2ex <= exc_code_if2id;
                    exc_epc_id2ex <= exc_addr_if2id;
                    exc_badvaddr_id2ex <= exc_addr_if2id;
                end else begin
                    exc_epc_id2ex <= in_delay_slot ? next_pc - 8 : next_pc - 4;
                    do_decode();
                end
            end
		end
	end

endmodule

