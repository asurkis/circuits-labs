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
reg [3:0] state, state_next;
reg [7:0] mult_i1;
reg [7:0] mult_i2;
wire [15:0] mult_out;
reg mult_reset;
wire mult_busy;

reg [8:0] sum_i1;
reg [8:0] sum_i2;
wire [8:0] sum_o;

reg [8:0] sub_i1;
reg [8:0] sub_i2;
wire [8:0] sub_o;

adder adder1(
    .a(sum_i1),
    .b(sum_i2),
    .y(sum_o)
);

substractor sub1(
    .a(sub_i1),
    .b(sub_i2),
    .y(sub_o)
);

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
localparam STATE11 = 4'b1011;
localparam STATE12 = 4'b1100;
localparam STATE13 = 4'b1101;
localparam STATE14 = 4'b1110;
localparam STATE15 = 4'b1111;

assign busy_out = rst_i | |state;
assign y_out = r;

always @(posedge clk_i) 
    if (rst_i) begin
        state <= STATE1;
    end else begin
        state <= state_next;
    end
    
always @* begin
        case(state)
            STATE0: state_next = STATE0;
            STATE1: state_next = |m ? STATE2 : STATE5;
            STATE2: state_next = mult_busy ? STATE2 : STATE3;
            STATE3: state_next = mult_busy ? STATE3 : STATE4;
            STATE4: state_next = STATE1;
            STATE5: state_next = STATE6;
            STATE6: state_next = STATE7;
            STATE7: state_next = |m ? STATE8 : STATE0;
            STATE8: state_next = x >= t ? STATE9 : STATE11;
            STATE9: state_next = STATE10;
            STATE10: state_next = STATE11;
            STATE11: state_next = STATE7;
        endcase
end

always @(posedge rst_i) begin
    
end

always @(posedge clk_i) begin
    if (rst_i) begin
        a <= a_in;
        x <= b_in;
        t <= 0;
        r <= 4;
        m <= 4;
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
                end
            end
        STATE3:
            begin
                mult_reset <= 0;
                if (!mult_busy) begin
                    sub_i1 <= r;
                    sum_i1 <= r;
                    if (x == mult_out) begin
                        m <= 0;
                        sum_i2 <= 0;
                        sub_i2 <= 0;
                    end else begin
                        sub_i2 <= m;
                        sum_i2 <= m;
                    end
                end
            end
        STATE4:
             begin
                 if (x <= mult_out) begin
                    r <= sub_o;
                    m <= m >> 1;
                 end else begin
                    r <= sum_o;
                    if (m > 1) begin
                        m <= m >> 1;
                    end
                 end
             end
        STATE5:
            begin
                sum_i1 <= a;
                sum_i2 <= r;
                m <= 64;
            end
        STATE6:
         begin
            x <= sum_o;
            r <= 0;
          end
        STATE7: t <= r | m;
        STATE8: r <= r >> 1;
        STATE9:
            begin
                sub_i1 <= x;
                sub_i2 <= t;
                r <= r | m;
            end
        STATE10: x <= sub_o;
        STATE11: m <= m >> 2;
    endcase
    end
end

endmodule