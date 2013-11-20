wire [`EXC_CODE_WIDTH-1:0] exc_code_if2id;
wire [31:0] exc_addr_if2id;
wire [31:0] next_pc;
wire [31:0] instr;
assign { exc_code_if2id,exc_addr_if2id,next_pc,instr } = interstage_if2id;
