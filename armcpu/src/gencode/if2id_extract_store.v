reg [`EXC_CODE_WIDTH-1:0] exc_code_if2id;
reg [31:0] exc_addr_if2id;
reg [31:0] next_pc;
reg [31:0] instr;
assign interstage_if2id = { exc_code_if2id,exc_addr_if2id,next_pc,instr };
