/*
 * $File: com2flash.v
 * $Date: Mon Oct 28 11:05:31 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

/*
* protocol:
* s: server (PC)
* c: client (our board)
* s -> c:
*	START_WRITE
*		s -> c:
*			3 bytes start_addr, MSB to LSB
*			3 bytes end_addr, MSB to LSB
*		c -> s:
*			1 byte, checksum
*		s -> s:
*			2 * (start_addr - end_addr) bytes, the data
*			for each word, MSB to LSB order
*		c -> s:
*			1 byte, checksum
*		goto idle state
*		
*
* output:
*	segdisp: number of 4k blocks
*/

module com2flash
	#(parameter FLASH_ADDR_SIZE = 22)
	(
	input clk,
	input rst,
	output [15:0] led,
	output [0:6] segdisp0,
	output [0:6] segdisp1,
	inout [31:0] baseram_data,
	output baseram_oe,
	output baseram_ce,
	output baseram_we,
	output reg uart_enable_recv,
	output uart_TxD_start,
	input uart_TxD_busy,
	input uart_RxD_data_ready,
	input uart_RxD_waiting_data,
	output uart_rst,
	output [FLASH_ADDR_SIZE:0] flash_addr,
	output [15:0] flash_data,
	output [7:0] flash_ctl);

	localparam CMD_WRITE = 8'hf3;

	reg [19:0] frame_cnt;

	// XXX: frame_cnt not right
	digseg_driver disp_fc_high(.data(frame_cnt[7:4]), .seg(segdisp1));
	digseg_driver disp_fc_low(.data(frame_cnt[3:0]), .seg(segdisp0));

	assign uart_rst = ~rst;
	assign baseram_oe = 1;
	assign baseram_ce = 1;
	assign baseram_we = 1;

	reg [7:0] data_to_com;
	reg [7:0] flash_write_cnt;
	wire [7:0] data_from_com = baseram_data[7:0];
	reg [15:0] prev_flash_data;	// XXX: debug only
	assign baseram_data = {
		flash_write_cnt, prev_flash_data,
		uart_enable_recv ? {8{1'bz}} : data_to_com};
	assign uart_TxD_start = ~uart_enable_recv;

	reg [7:0] checksum;
	reg [FLASH_ADDR_SIZE-1:0] start_addr, end_addr, addr_to_flash;
	wire [FLASH_ADDR_SIZE-1:0] start_addr_next = start_addr + 1'b1;

	reg [47:0] comdata_shift;
	reg [2:0] comdata_shift_cnt;
	wire [2:0] comdata_shift_cnt_next = comdata_shift_cnt + 1'b1;

	wire [7:0] checksum_init = 8'h23;

	wire flash_busy;
	reg enable_flash_write;

	flash_driver #(.FLASH_ADDR_SIZE(FLASH_ADDR_SIZE)) flash_driver_inst(
		.clk(~clk),	// invert clock to ensuare stable signal on rising edge
		.addr(addr_to_flash),
		.data_in(comdata_shift[15:0]), .data_out(),
		.enable_read(1'b0),
		.enable_write(enable_flash_write),
		.enable_erase(1'b0),
		.busy(flash_busy),
		.flash_addr(flash_addr), .flash_data(flash_data),
		.flash_ctl(flash_ctl));

	always @(negedge clk)
		if (~rst) begin
			prev_flash_data <= 0;
			flash_write_cnt <= 0;
		end else if (enable_flash_write) begin
			prev_flash_data <= comdata_shift[15:0];
			flash_write_cnt <= flash_write_cnt + 1'b1;
		end

	localparam
		IDLE = 3'b000,
		WRITE_RECV_META = 3'b001,
		WRITE_SEND_META_ACK = 3'b011,
		WRITE_INIT_TRANSFER = 3'b010,
		WRITE_RECV_DATA = 3'b110,
		WRITE_SEND_DATA_ACK = 3'b111,
		ERROR = 3'b101;

	reg [2:0] state = IDLE;

	reg err_flash_too_slow = 0;

	assign led = {state, 5'b0,
		3'b0, err_flash_too_slow, uart_RxD_waiting_data,
		uart_TxD_busy, uart_RxD_data_ready, flash_busy};

	always @(posedge clk) begin
		if (~rst)
			frame_cnt <= 0;
		else if (uart_enable_recv & uart_RxD_data_ready) begin
			comdata_shift <= {comdata_shift[39:0], data_from_com};
			frame_cnt <= frame_cnt + 1'b1;
		end
	end

	always @(posedge clk) begin
		if (!rst) 
			state <= IDLE;
		else case (state)
			IDLE: begin
				uart_enable_recv <= 1;
				if (uart_RxD_data_ready) begin
					if (data_from_com == CMD_WRITE) begin
						state <= WRITE_RECV_META;
						checksum <= checksum_init;
						comdata_shift_cnt <= 0;
					end
				end
			end

			WRITE_RECV_META:
				if (uart_RxD_data_ready) begin
					comdata_shift_cnt <= comdata_shift_cnt_next;
					checksum <= checksum ^ data_from_com;
					if (comdata_shift_cnt_next == 6)
						state <= WRITE_SEND_META_ACK;
				end
			WRITE_SEND_META_ACK: begin
				start_addr <= comdata_shift[FLASH_ADDR_SIZE-1+24:24];
				end_addr <= comdata_shift[FLASH_ADDR_SIZE-1:0];
				data_to_com <= checksum;
				state <= WRITE_INIT_TRANSFER;
				uart_enable_recv <= 0;
			end
			WRITE_INIT_TRANSFER: begin
				uart_enable_recv <= 1;
				comdata_shift_cnt[0] <= 0;
				checksum <= checksum_init;
				state <= WRITE_RECV_DATA;
			end
			WRITE_RECV_DATA: begin
				if (uart_RxD_data_ready) begin
					if (flash_busy) begin
						state <= ERROR;
						err_flash_too_slow <= 1;
					end
					comdata_shift_cnt[0] <= comdata_shift_cnt_next[0];
					enable_flash_write <= comdata_shift_cnt[0];
					if (comdata_shift_cnt[0]) begin
						addr_to_flash <= start_addr;
						checksum <= checksum ^ data_from_com ^
							comdata_shift[7:0];

						if (start_addr_next == end_addr)
							state <= WRITE_SEND_DATA_ACK;
						start_addr <= start_addr_next;
					end 
				end else
					enable_flash_write <= 0;
			end
			WRITE_SEND_DATA_ACK: begin
				enable_flash_write <= 0;
				if (!flash_busy) begin
					data_to_com <= checksum;
					uart_enable_recv <= 0;
					state <= IDLE;
				end
			end

			ERROR:
				state <= ERROR;	// loop forever

			default:
				state <= IDLE;
		endcase
	end

endmodule

