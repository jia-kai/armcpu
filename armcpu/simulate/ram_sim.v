/*
 * $File: ram_sim.v
 * $Date: Fri Nov 22 20:35:26 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`timescale 1ns/1ps

// simulate ram device
module ram_sim
	#(parameter NAME, IMAGE_FILE = "", ADDR_WIDTH = 20, CHECK_BAD_READ = 1)

	(input [ADDR_WIDTH-1:0] addr,
	inout [31:0] data,
	input ce, input oe, input we);

	reg [31:0] storage [0:(1 << ADDR_WIDTH)-1];

	function is_valid_data(input [31:0] data);
		is_valid_data = (|data) === 1'b1 || data === 32'b0;
	endfunction

	always @(posedge we)
		if (!ce && $time > 0) begin
			storage[addr] <= data;
			if (!is_valid_data(data)) begin
				$warning("time=%g mem %s: write bad data: addr=%h data=%h",
					$time, NAME, addr, data);
				#1 $fatal("exit due to previous error");
			end else
				$display("\033[31m <-- mem %s --> time=%g write: addr=%h data=%h\033[0m",
					NAME, $time, addr, data);
		end

	wire [31:0] data_from_mem = storage[addr];
	assign data = (!ce && !oe ? data_from_mem : {32{1'bz}});

	always @(*)
		if (CHECK_BAD_READ && !oe && !ce && !is_valid_data(data_from_mem)) begin
			$warning("time=%g mem %s: read uninitialized memory: addr=%h, return rand",
				$time, NAME, addr);
			storage[addr] = $random;
		end

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

		for (i = nr_read; i < nr_read + 4; i = i + 1)
			storage[i] = 0;

		/*
		for (i = 0; i < nr_read; i = i + 1)
			$display("initial mem %s dump: %h: %h", NAME, i, storage[i]);
		*/
	end

endmodule

