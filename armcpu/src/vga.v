/*
 * $File: vga.v
 * $Date: Fri Nov 29 02:43:27 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`include "vga_def.vh"

// vga driver
module vga(
	input clk50M,
	input [`VGA_ADDR_WIDTH-1:0] write_addr,
	input [`VGA_DATA_WIDTH-1:0] write_data,
	input write_enable,	// data not latched; always sampled on posedge

	output reg [8:0] color_out, // 3 red, 3 green, 3 blue
	output hsync,
	output vsync);

	localparam H_VISIBLE_AREA = 800,
		H_FRONT_PORCH = 56,
		H_SYNC_PULSE = 120,
		H_BACK_PORCH = 64,
		H_WHOLE = 1040;

	localparam V_VISIBLE_AREA = 600,
		V_FRONT_PORCH = 37,
		V_SYNC_PULSE = 6,
		V_BACK_PORCH = 23,
		V_WHOLE = 666;

	localparam RAM_ADDR_BASE = 18'h8000;

	reg [10:0] hsync_cnt = 0;
	reg [10:0] vsync_cnt = 0;

	assign hsync = (hsync_cnt >= H_SYNC_PULSE);
	assign vsync = (vsync_cnt >= V_SYNC_PULSE);

	wire [10:0] pixel_x = (hsync_cnt >= H_SYNC_PULSE + H_FRONT_PORCH ?
		hsync_cnt - H_SYNC_PULSE - H_FRONT_PORCH : {11{1'b1}});
	wire [10:0] pixel_y = (vsync_cnt >= V_SYNC_PULSE + V_FRONT_PORCH ?
		vsync_cnt - V_SYNC_PULSE - V_FRONT_PORCH : {11{1'b1}});
	wire [`VGA_ADDR_WIDTH-1:0] pixel_ram_addr =
		{pixel_y[10:1], {`VGA_WIDTH_MULT_SHIFT{1'b0}}} + pixel_x[10:1];

	wire should_draw = pixel_x >= 0 && pixel_x < H_VISIBLE_AREA &&
		pixel_y >= 0 && pixel_y < V_VISIBLE_AREA;

	wire [7:0] data_from_ram;
	wire [17:0] addr_to_ram =
		write_enable ? write_addr + RAM_ADDR_BASE
			: {1'b1, {`VGA_WIDTH_MULT_SHIFT{1'b0}}};

	vga_ram uram(.clka(clk50M), .wea(1'b1),
		.addra(addr_to_ram),
		.dina(write_data),
		.clkb(clk50M),
		.addrb(pixel_ram_addr + RAM_ADDR_BASE),
		.doutb(data_from_ram));

	wire [2:0] red = data_from_ram[7:5], green = data_from_ram[4:2];
	reg [2:0] blue;
	always @(*)
		case (data_from_ram[1:0])
			0: blue <= 3'b000;
			1: blue <= 3'b010;
			2: blue <= 3'b101;
			3: blue <= 3'b111;
		endcase

	always @(posedge clk50M) begin
		if (hsync_cnt == H_WHOLE - 1) begin
			hsync_cnt <= 0;
			if (vsync_cnt == V_WHOLE - 1) begin
				vsync_cnt <= 0;
			end else begin
				vsync_cnt <= vsync_cnt + 1'b1;
			end
		end else begin
			hsync_cnt <= hsync_cnt + 1'b1;
		end
		if (should_draw) 
			color_out <= {blue, green, red};
		else
			color_out <= 0;
	end


endmodule

