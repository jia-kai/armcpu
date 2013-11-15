reg [`MEMWRITE_OPT_WIDTH-1:0] memwrite_opt;
reg [31:0] mem_addr;
reg [31:0] mem_data;
reg [`WB_SRC_WIDTH-1:0] wb_src_ex2mem;
reg [`REGADDR_WIDTH-1:0] wb_reg_addr_ex2mem;
reg [31:0] alu_result;
assign interstage_ex2mem = { memwrite_opt,mem_addr,mem_data,wb_src_ex2mem,wb_reg_addr_ex2mem,alu_result };
