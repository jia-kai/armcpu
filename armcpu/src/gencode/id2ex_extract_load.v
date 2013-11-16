wire [`BRANCH_OPT_WIDTH-1:0] branch_opt_id2ex;
wire [31:0] branch_dest_id2ex;
wire [31:0] alu_sa_imm;
wire [`ALU_SRC_WIDTH-1:0] alu_src;
wire [`ALU_OPT_WIDTH-1:0] alu_opt;
wire [`MEM_OPT_WIDTH-1:0] mem_opt_id2ex;
wire [`REGADDR_WIDTH-1:0] wb_reg_addr_id2ex;
assign { branch_opt_id2ex,branch_dest_id2ex,alu_sa_imm,alu_src,alu_opt,mem_opt_id2ex,wb_reg_addr_id2ex } = interstage_id2ex;
