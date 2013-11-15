reg [31:0] next_pc;
reg [31:0] instr;
assign interstage_if2id = { next_pc,instr };
