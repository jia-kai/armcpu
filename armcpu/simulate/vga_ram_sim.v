/*
 * $File: vga_ram_sim.v
 * $Date: Fri Nov 29 03:20:39 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */


module vga_ram(input clka, input wea,
	input [17:0] addra,
	input [7:0] dina,
	input clkb,
	input [17:0] addrb,
	output [7:0] doutb);

	reg [7:0] mem [0:1<<18];

	initial begin: INIT_MEM
		integer i;
		for (i = 0; i < (1 << 18); i = i + 1)
			mem[i] = 0;
	end

	always @(posedge clka)
		if (wea)
			mem[addra] <= dina;

	assign doutb = mem[addrb];

endmodule

