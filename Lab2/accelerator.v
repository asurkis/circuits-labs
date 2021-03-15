`timescale 1ns / 1ps

module accelerator(
	input rst_i,
	input clk_i,
	input [7:0] a_in,
	input [7:0] b_in,
	output busy_out,
	output [7:0] y_out
);

reg [7:0] a;
reg [8:0] x;
reg [15:0] t;
reg [7:0] r;
reg [7:0] m;
reg [3:0] state;
reg [7:0] mult_i1;
reg [7:0] mult_i2;
wire [15:0] mult_out;
reg mult_reset;
wire mult_busy;

mult mult_1(
	.clk_i(clk_i),
	.rst_i(mult_reset),
	.a_bi(mult_i1),
	.b_bi(mult_i2),
	.busy_o(mult_busy),
	.y_bo(mult_out)
);

localparam STATE0 = 4'b0000;
localparam STATE1 = 4'b0001;
localparam STATE2 = 4'b0010;
localparam STATE3 = 4'b0011;
localparam STATE4 = 4'b0100;
localparam STATE5 = 4'b0101;
localparam STATE6 = 4'b0110;
localparam STATE7 = 4'b0111;
localparam STATE8 = 4'b1000;
localparam STATE9 = 4'b1001;
localparam STATE10 = 4'b1010;

assign busy_out = rst_i | |state;
assign y_out = r;

always @(posedge clk_i) begin
	if (rst_i) begin
		a <= a_in;
		x <= b_in;
		t <= 0;
		r <= 4;
		m <= 4;
		state <= STATE1;
		mult_reset <= 0;
	end else begin
		case (state)
			STATE0:
				begin
				end
			STATE1:
				begin
					if (|m) begin
						mult_reset <= 1;
						mult_i1 <= r;
						mult_i2 <= r;
						state <= STATE2;
					end else begin
						state <= STATE5;
					end
				end
			STATE2:
				begin
					if (mult_busy) begin
						mult_reset <= 0;
					end else begin
						mult_reset <= 1;
						mult_i1 <= mult_out;
						mult_i2 <= r;
						state <= STATE3;
					end
				end
			STATE3:
				begin
					mult_reset <= 0;
					if (!mult_busy) begin
						if (x < mult_out) begin
							r <= r - m;
						end else if (x > mult_out) begin
							r <= r + m;
						end else begin
							m <= 0;
						end
						state <= STATE4;
					end
				end
			STATE4:
				begin
					m <= m >> 1;
					state <= STATE1;
				end
			STATE5:
				begin
					x <= a + r;
					m <= 64;
					state <= STATE6;
				end
			STATE6:
				begin
					r <= 0;
					state <= STATE7;
				end
			STATE7:
				begin
					t <= r | m;
					state <= STATE8;
					if (|m) begin
						state <= STATE8;
					end else begin
						state <= STATE0;
					end
				end
			STATE8:
				begin
					r <= r >> 1;
					if (x >= t) begin
						state <= STATE9;
					end else begin
						state <= STATE10;
					end
				end
			STATE9:
				begin
					x <= x - t;
					r <= r | m;
					state <= STATE10;
				end
			STATE10:
				begin
					m <= m >> 2;
					state <= STATE7;
				end
		endcase
	end
end

endmodule