/*
 * $File: ram_sim.v
 * $Date: Sat Nov 16 20:18:36 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`timescale 1ns/1ps

// simulate ram device
module ram_sim
	#(parameter IMAGE_FILE = "", parameter ADDR_WIDTH = 20)

	(input [ADDR_WIDTH-1:0] addr,
	inout [31:0] data,
	input ce, input oe, input we);

	reg [31:0] storage [0:(1 << ADDR_WIDTH)-1];

	always @(negedge we)
		if (!ce) begin
			storage[addr] <= data;
			$display("\033[31m <-- mem --> time=%g write: addr=%h data=%h\033[0m",
				$time, addr, data);
		end

	wire [31:0] data_from_mem = storage[addr];
	assign data = (!ce && !oe ? data_from_mem : {32{1'bz}});

	always @(*)
		if (!ce && !oe && !we)
			$error("both oe and we is deasserted");

	initial if (IMAGE_FILE != "") begin: INITIAL
		integer fin, nr_read, i;
		reg [31:0] tmp;
		fin = $fopen(IMAGE_FILE, "rb");
		nr_read = $fread(storage, fin) / 4;
		$fclose(fin);
		if (nr_read <= 0) 
			$fatal("failed to load ram image from `%s'", IMAGE_FILE);
		for (i = 0; i < nr_read; i = i + 1) begin
			tmp = storage[i];
			storage[i] = {tmp[7:0], tmp[15:8], tmp[23:16], tmp[31:24]};
		end
		for (i = 0; i < nr_read; i = i + 1)
			$display("initial mem dump: %h: %h", i, storage[i]);
	end

endmodule

