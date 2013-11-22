/*
 * $File: check_instr.v
 * $Date: Fri Nov 22 23:16:32 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`timescale 1ns/1ps
`include "src/cp0_def.vh"

module check_instr #(parameter IMAGE_FILE = "prog.bin");

	wire [`IF2ID_WIRE_WIDTH-1:0] interstage_if2id;
	`include "gencode/if2id_extract_store.v"

	reg [31:0] storage [0:(1 << 22)-1];
	reg [31:0] nr_read;
	reg [31:0] cur_ptr = 0;

	reg clk = 0, rst = 1;
	
	stage_id uid(.clk(clk), .rst(rst), .stall(1'b0), .clear(1'b0),
		.interstage_if2id(interstage_if2id),
		.cur_if_branch(1'b0),
		.reg_write_addr(5'b0), .reg_write_data(0));

	always @(posedge clk) begin
		exc_code_if2id <= `EC_NONE;
		if (rst)
			cur_ptr <= 0;
		else begin
			instr <= storage[cur_ptr];
			if (cur_ptr == nr_read)
				$stop();
			cur_ptr <= cur_ptr + 1;
			next_pc <= (cur_ptr + 1) * 4;
		end
	end

	always #1 clk <= ~clk;

	initial begin: INITIAL
		integer fin, i;
		reg [31:0] tmp;
		fin = $fopen(IMAGE_FILE, "rb");
		nr_read = $fread(storage, fin) / 4;
		$fclose(fin);
		if (nr_read <= 0) 
			$fatal("failed to load ram image from `%s'", IMAGE_FILE);
		$display("load program: %d instr", nr_read);
		for (i = 0; i < nr_read; i = i + 1) begin
			tmp = storage[i];
			storage[i] = {tmp[7:0], tmp[15:8], tmp[23:16], tmp[31:24]};
		end

		for (i = nr_read; i < nr_read + 4; i = i + 1)
			storage[i] = 0;

		nr_read = nr_read + 4;

		#6 rst = 0;
	end

endmodule

