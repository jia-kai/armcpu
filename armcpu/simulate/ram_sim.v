/*
 * $File: ram_sim.v
 * $Date: Thu Dec 19 19:52:21 2013 +0800
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

	function is_valid_data(input [31:0] data); begin
		// $display("time=%g is_valid_data: data=%h", $time, data);
		is_valid_data = (|data) === 1'b1 || data === 32'b0;
	end endfunction

	always @(posedge we)
		if (!ce && $time > 0) begin
			storage[addr] <= data;
			if (!is_valid_data(data) || !oe) begin
				$warning("time=%g mem %s: write bad data: addr=%h(%h) data=%h oe=%b",
					$time, NAME, addr * 4, addr, data, oe);
				#1 $fatal("exit due to previous error");
			end else
				$display("\033[31m <-- mem %s --> time=%g write: addr=%h(%h) data=%h\033[0m",
					NAME, $time, addr * 4, addr, data);
		end

	wire [31:0] data_from_mem;
	ram_output_delay uoutdelay(.in(storage[addr]), .out(data_from_mem));
	assign data = (!ce && !oe ? data_from_mem : {32{1'bz}});

	specify
		$setup(data, posedge we, 0.5);
		$setup(oe, posedge we, 0.5);
	endspecify

	/*
	always @(*)
		if (CHECK_BAD_READ && !oe && !ce && !is_valid_data(data_from_mem)) begin
			storage[addr] = $random;
			$warning("time=%g mem %s: read uninitialized memory: addr=%h, return rand: %h",
				$time, NAME, addr, storage[addr]);
		end
	*/

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

module ram_output_delay(
	input [31:0] in,
	output [31:0] out);

	specify
		(in => out) = 0.9;
	endspecify
	assign out = in;
endmodule

