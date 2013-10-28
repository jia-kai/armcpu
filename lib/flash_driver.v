/*
 * $File: flash_driver.v
 * $Date: Mon Oct 28 09:15:12 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`timescale 1ns/1ps

module flash_driver
	#(parameter FLASH_ADDR_SIZE = 22)
	(
	input clk,
	input [FLASH_ADDR_SIZE - 1:0] addr,
	input [15:0] data_in,
	output [15:0] data_out,
	input enable_read,
	/*
	* when asserted, data could be continousely read from flash
	* busy would be de-asserted for one cycle after finishing each read
	* addr must be valid during the whole reading process
	*/
	input enable_erase,
	// assert for one cycle to erase; addr woule be latched
	input enable_write,
	// assert for one cycle to write; addr and data woule be latched
	output reg busy,
	output [FLASH_ADDR_SIZE:0] flash_addr,
	inout [15:0] flash_data,
	output [7:0] flash_ctl);

	reg flash_oe, flash_we;

	wire flash_byte = 1, flash_vpen = 1, flash_ce = 0, flash_rp = 1;

	reg [FLASH_ADDR_SIZE - 1:0] flash_addr_sig;	// significant flash addr
	assign flash_addr = {flash_addr_sig, 1'b0};
	reg [15:0] data_to_write,
		data_cache;	/* for both caching output data when reading, and latching
						input data when writing */
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
		WRITE1 = 3'b010, WRITE2 = 4'b1110, WRITE3 = 4'b1111,
		ERASE1 = 3'b100, ERASE2 = 4'b1100, ERASE3 = 4'b1101,
		SR1 = 3'b101, SR2 = 3'b111, SR3 = 3'b110, SR4 = 4'b1000;

	assign data_out = state == READ3 ? flash_data : data_cache;

	always @(posedge clk) begin
		case (state)
			IDLE: begin
				flash_addr_sig <= addr;
				if (enable_write) begin
					data_cache <= data_in;
					data_to_write <= 16'h0040;
					flash_we <= 0;
					state <= WRITE1;
					busy <= 1;
				end else if (enable_erase) begin
					data_to_write <= 16'h0020;
					flash_we <= 0;
					state <= ERASE1;
					busy <= 1;
				end else if (enable_read) begin
					data_to_write <= 16'h00FF;
					flash_we <= 0;
					state <= READ1;
					busy <= 1;
				end else begin
					flash_oe <= 1;
					flash_we <= 1;
					busy <= 0;
				end
			end

			WRITE1: begin
				flash_we <= 1;
				state <= WRITE2;
			end
			WRITE2: begin
				flash_we <= 0;
				data_to_write <= data_cache;
				state <= WRITE3;
			end
			WRITE3: begin
				flash_we <= 1;
				state <= SR1;
			end

			ERASE1: begin
				flash_we <= 1;
				state <= ERASE2;
			end
			ERASE2: begin
				flash_we <= 0;
				data_to_write <= 16'h00d0;
				state <= ERASE3;
			end
			ERASE3: begin
				flash_we <= 1;
				state <= SR1;
			end

			READ1: begin
				flash_we <= 1;
				state <= READ2;
			end
			READ2: begin
				flash_oe <= 0;
				flash_addr_sig <= addr;
				state <= READ3;
				busy <= 0;
			end
			READ3: begin
				data_cache <= flash_data;
				if (enable_read) begin
					state <= READ2;
					busy <= 1;
				end
				else begin
					state <= IDLE;
					flash_oe <= 1;
				end
			end

			// wait for SR[7] to become 1
			SR1: begin
				data_to_write <= 16'h0070;
				flash_we <= 0;
				state <= SR2;
			end
			SR2: begin
				flash_we <= 1;
				state <= SR3;
			end
			SR3: begin
				flash_oe <= 0;
				state <= SR4;
			end
			SR4: begin
				flash_oe <= 1;
				if (flash_data[7]) begin
					state <= IDLE;
					busy <= 0;
				end
				else
					state <= SR1;
			end

			default:
				state <= IDLE;
		endcase
	end


endmodule

module flash_driver_testbench();
	reg clk = 0;
	wire [15:0] data_out;
	wire busy;
	wire [22:0] flash_addr;
	wire [7:0] flash_ctl;
	reg enable_write = 0;
	reg enable_erase = 0;
	wire [15:0] flash_data = {16{1'bz}};

	flash_driver flash_driver_test (.clk(clk),
	.addr(23'b0),
	.data_in(16'b0),
	.data_out(data_out),
	.enable_read(1'b0),
	.enable_write(enable_write),
	.enable_erase(enable_erase),
	.busy(busy),
	.flash_addr(flash_addr),
	.flash_data(flash_data),
	.flash_ctl(flash_ctl));

	always #10 clk <= ~clk;
	always #50 enable_erase <= 1;
endmodule

