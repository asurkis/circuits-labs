`timescale 1ns / 1ps

module circuit(
    input x1,
    input x2,
    input x3,
    input x4,
    input x5,
    input x6,
    input x7,
    input x8,
    output y1,
    output y2,
    output y3
    );
    
    
    wire not_x2, not_x3, not_x4, not_x5, not_x6, not_x7, not_x8;
    
    nand(not_x2, x2, x2);
    nand(not_x3, x3, x3);
    nand(not_x4, x4, x4);
    nand(not_x5, x5, x5);
    nand(not_x6, x6, x6);
    nand(not_x7, x7, x7);
    nand(not_x8, x8, x8);
    
    wire x2_or_x4_in, x3_or_x4_in, x5_or_x6_in, x6_or_x8_in, x7_or_x8_in;
    
    nand(x2_or_x4_in, not_x2, not_x4);
    nand(x3_or_x4_in, not_x3, not_x4);
    nand(x5_or_x6_in, not_x5, not_x6);
    nand(x6_or_x8_in, not_x6, not_x8);
    nand(x7_or_x8_in, not_x7, not_x8);
    
    wire x2_or_x4_out, x3_or_x4_out, x5_or_x6_out, x6_or_x8_out, x7_or_x8_out;
    
    nand(x2_or_x4_out, x2_or_x4_in, x2_or_x4_in);
    nand(x3_or_x4_out, x3_or_x4_in, x3_or_x4_in);
    nand(x5_or_x6_out, x5_or_x6_in, x5_or_x6_in);
    nand(x6_or_x8_out, x6_or_x8_in, x6_or_x8_in);
    nand(x7_or_x8_out, x7_or_x8_in, x7_or_x8_in);
    
    
    nand(y1, x2_or_x4_out, x6_or_x8_out);
    nand(y2, x3_or_x4_out, x7_or_x8_out);
    nand(y3, x5_or_x6_out, x7_or_x8_out);
    
endmodule
