reg [`BRANCH_OPT_WIDTH-1:0] branch_opt_id2ex;
reg [31:0] branch_dest_id2ex;
reg [31:0] alu_sa_imm;
reg [`ALU_SRC_WIDTH-1:0] alu_src;
reg [`ALU_OPT_WIDTH-1:0] alu_opt;
reg [`MEM_OPT_WIDTH-1:0] mem_opt_id2ex;
reg [`WB_SRC_WIDTH-1:0] wb_src_id2ex;
reg [`REGADDR_WIDTH-1:0] wb_reg_addr_id2ex;
assign interstage_id2ex = { branch_opt_id2ex,branch_dest_id2ex,alu_sa_imm,alu_src,alu_opt,mem_opt_id2ex,wb_src_id2ex,wb_reg_addr_id2ex };
