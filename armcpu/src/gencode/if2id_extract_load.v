wire [31:0] next_pc;
wire [31:0] instr;
assign { next_pc,instr } = interstage_if2id;
