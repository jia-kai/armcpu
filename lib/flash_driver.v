/*
 * $File: flash_driver.v
 * $Date: Sun Oct 27 20:38:29 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`timescale 1ns/1ps

module flash_driver(
	input clk,
	input [22:0] addr,
	input [15:0] data_in,
	output [15:0] data_out,
	input enable_read,
	/*
	* when asserted, data could be continousely read from flash
	* busy would be de-asserted for one cycle after finishing each read
	*/
	input enable_erase,
	// assert for one cycle to erase; addr woule be latched
	input enable_write,
	// assert for one cycle to write; addr woule be latched, and data should
	// still be available after two cycles
	output busy,
	output reg [22:0] flash_addr,
	inout [15:0] flash_data,
	output [7:0] flash_ctl);

	assign data_out = flash_data;

	reg enable_we, enable_we_delay, flash_oe, we_read;

	wire flash_byte = 1, flash_vpen = 1, flash_ce = 0, flash_rp = 1,
		do_enable_we = enable_we | enable_we_delay,
		we_write = (do_enable_we & ~clk) | ~do_enable_we,
		// we_write is for write and erase
		flash_we = we_write & we_read;

	reg [15:0] data_to_write;
	assign flash_data = flash_oe ? data_to_write : {16{1'bz}};

	assign flash_ctl = {
		flash_byte,
		flash_ce,
		2'b0,	// ce1 ce2
		flash_oe,
		flash_rp,
		flash_vpen,
		flash_we};

	reg [3:0] state;
	localparam
		IDLE = 3'b000,
		READ1 = 3'b001, READ2 = 3'b011, READ3 = 4'b1011,
		WRITE1 = 3'b010,
		ERASE1 = 3'b100,
		SR1 = 3'b101, SR2 = 3'b111, SR3 = 3'b110, SR4 = 4'b1000;

	assign busy = (state != IDLE) & (state != READ3);
	
	always @(posedge clk) begin
		case (state)
			IDLE: begin
				flash_addr <= addr;
				if (enable_write) begin
					data_to_write <= 16'h0040;
					enable_we <= 1;
					state <= WRITE1;
				end else if (enable_erase) begin
					data_to_write <= 16'h0020;
					enable_we <= 1;
					state <= ERASE1;
				end else if (enable_read) begin
					data_to_write <= 16'h00FF;
					we_read <= 0;
					state <= READ1;
				end else begin
					enable_we <= 0;
					flash_oe <= 1;
					we_read <= 1;
				end
			end

			WRITE1: begin
				data_to_write <= data_in;
				enable_we <= 0;
				state <= SR1;
			end

			ERASE1: begin
				data_to_write <= 16'h00d0;
				enable_we <= 0;
				state <= SR1;
			end

			READ1: begin
				we_read <= 1;
				state <= READ2;
			end

			READ2: begin
				flash_oe <= 0;
				flash_addr <= addr;
				state <= READ3;
			end

			READ3: begin
				if (enable_read)
					state <= READ2;
				else begin
					state <= IDLE;
					flash_oe <= 1;
				end
			end

			// wait for SR[7] to become 1
			SR1: begin
				data_to_write <= 16'h0070;
				we_read <= 0;
				state <= SR2;
			end
			SR2: begin
				we_read <= 1;
				state <= SR3;
			end
			SR3: begin
				flash_oe <= 0;
				state <= SR4;
			end
			SR4: begin
				flash_oe <= 1;
				if (flash_data[7])
					state <= IDLE;
				else
					state <= SR1;
			end

			default:
				state <= IDLE;
		endcase
	end

	always @(negedge clk)
		enable_we_delay <= enable_we;


endmodule

module flash_driver_testbench();
	reg clk = 0;
	wire [15:0] data_out;
	wire busy;
	wire [22:0] flash_addr;
	wire [7:0] flash_ctl;
	reg enable_write = 0;
	wire [15:0] flash_data = {16{1'bz}};

	flash_driver flash_driver_test (.clk(clk),
	.addr(23'b0),
	.data_in(16'b0),
	.data_out(data_out),
	.enable_read(1'b0),
	.enable_write(enable_write),
	.enable_erase(1'b0),
	.busy(busy),
	.flash_addr(flash_addr),
	.flash_data(flash_data),
	.flash_ctl(flash_ctl));

	always #10 clk <= ~clk;
	always #50 enable_write <= 1;
endmodule

