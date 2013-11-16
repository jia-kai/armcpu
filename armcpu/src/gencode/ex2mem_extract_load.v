wire [31:0] mem_addr_ex2mem;
wire [31:0] mem_data_ex2mem;
wire [`MEM_OPT_WIDTH-1:0] mem_opt_ex2mem;
wire [`REGADDR_WIDTH-1:0] wb_reg_addr_ex2mem;
wire [31:0] alu_result;
assign { mem_addr_ex2mem,mem_data_ex2mem,mem_opt_ex2mem,wb_reg_addr_ex2mem,alu_result } = interstage_ex2mem;
