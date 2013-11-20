reg [`EXC_CODE_WIDTH-1:0] exc_code_ex2mem;
reg [31:0] exc_epc_ex2mem;
reg [31:0] exc_badvaddr_ex2mem;
reg [31:0] mem_addr_ex2mem;
reg [31:0] mem_data_ex2mem;
reg [`MEM_OPT_WIDTH-1:0] mem_opt_ex2mem;
reg [`REGADDR_WIDTH-1:0] wb_reg_addr_ex2mem;
reg [31:0] alu_result;
assign interstage_ex2mem = { exc_code_ex2mem,exc_epc_ex2mem,exc_badvaddr_ex2mem,mem_addr_ex2mem,mem_data_ex2mem,mem_opt_ex2mem,wb_reg_addr_ex2mem,alu_result };
