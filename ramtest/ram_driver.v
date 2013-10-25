/*
 * $File: ram_driver.v
 * $Date: Fri Oct 25 17:57:35 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

/*
 * I/O from external ram
 */
module ram_driver
	#(parameter ADDR_WIDTH = 20, DATA_WIDTH = 32)
	(input [ADDR_WIDTH-1:0] addr,
	 input [DATA_WIDTH-1:0] data_to_write,		// data to be written
	 output reg [DATA_WIDTH-1:0] data_read,	// data read from ram
	 input write_mode,
	 output [ADDR_WIDTH-1:0] dev_addr,	// address line to device
	 inout [DATA_WIDTH-1:0] dev_data,
	 output dev_ce,	// enable
	 output reg dev_oe,	// output enable
	 output reg dev_we,	// write enable
	 input clk);

	 assign dev_addr = addr;

	 reg write_enable;
	 reg [DATA_WIDTH-1:0] data_write_cache;
	 assign dev_data = write_enable ? data_write_cache : {DATA_WIDTH{1'bz}};
	 assign dev_ce = 0;

	 always @(posedge clk) begin
		 if (write_mode) begin
			 dev_oe <= 1;
			 dev_we <= 0;
			 data_write_cache <= data_to_write;
			 write_enable <= 1;
		 end else begin
			 dev_oe <= 0;
			 dev_we <= 1;
			 data_read <= dev_data;
			 write_enable <= 0;
			 data_write_cache <= 0;
		 end
	 end

endmodule


