/*
 * $File: ps2.v
 * $Date: Fri Dec 20 11:10:48 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */


module ps2(
	input clk,
	input ps2_clk,
	input ps2_data,

	// kbd_enb would be asserted for 1 cycle,
	// during which kbd_data is valid
	output reg kbd_enb_hi,
	output reg kbd_enb_lo,
	output reg [3:0] kbd_data);

	reg [7:0] recv_data;

	reg [3:0] recv_cnt;
	reg [1:0] state;
	localparam READY = 2'b00, RECV = 2'b01,
		SEND_LO = 2'b11, SEND_HI = 2'b10;

	// data out
	always @(*) begin
		kbd_enb_hi = 0;
		kbd_enb_lo = 0;
		kbd_data <= 0;
		case (state)
			SEND_LO: begin
				kbd_enb_lo = 1'b1;
				kbd_data <= recv_data[3:0];
			end
			SEND_HI: begin
				kbd_enb_hi = 1'b1;
				kbd_data <= recv_data[7:4];
			end
		endcase
	end

	reg ps2_clk1, ps2_clk2;
	assign ps2_sample_now = ~ps2_clk1 & ps2_clk2;

	always @(posedge clk) begin
		ps2_clk1 <= ps2_clk;
		ps2_clk2 <= ps2_clk1;
		case (state)
			READY:
				if (ps2_sample_now && !ps2_data) begin
					state <= RECV;
					recv_cnt <= 0;
				end
			RECV:
				if (ps2_sample_now) begin
					if (recv_cnt == 4'h8) begin
						if (^({recv_data, ps2_data}))
							state <= SEND_LO;
						else
							state <= READY;
					end else begin
						recv_cnt <= recv_cnt + 1'b1;
						recv_data <= {ps2_data, recv_data[7:1]};
					end
				end
			SEND_LO:
				state <= SEND_HI;
			SEND_HI:
				state <= READY;
		endcase
	end

endmodule

