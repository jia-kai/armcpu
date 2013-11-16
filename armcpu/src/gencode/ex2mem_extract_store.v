reg [`MEM_OPT_WIDTH-1:0] mem_opt_ex2mem;
reg [31:0] mem_addr_ex2mem;
reg [31:0] mem_data_ex2mem;
reg [`WB_SRC_WIDTH-1:0] wb_src_ex2mem;
reg [`REGADDR_WIDTH-1:0] wb_reg_addr_ex2mem;
reg [31:0] alu_result;
assign interstage_ex2mem = { mem_opt_ex2mem,mem_addr_ex2mem,mem_data_ex2mem,wb_src_ex2mem,wb_reg_addr_ex2mem,alu_result };
