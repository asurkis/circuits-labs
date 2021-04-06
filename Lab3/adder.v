`timescale 1ns / 1ps

module adder(
    input [8:0]a,
    input [8:0]b,
    output [8:0]y
    );
    
    assign y = a + b;
endmodule

