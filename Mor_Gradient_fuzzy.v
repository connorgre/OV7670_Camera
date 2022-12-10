`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/28/2022 05:11:49 PM
// Design Name: 
// Module Name: Mor_Gradient
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Morphological Gradient
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Mor_Gradient_fuzzy(z0, z1, z2, z3, z4, z5, z6, z7, z8, D1, D2, D3, D4, S);
    // usually grayscale image has 8 to 24 bits per pixel
    //color image has 24 bits per pixel
    //reg [639:0] pixels [0:319];
    //two dimensional pixels, each pixel contains a 8-bit number(0 to 255)
    parameter bit = 8;

    input [7:0] z0, z1, z2, z3, z4, z5, z6, z7, z8;
    output wire [7:0] D1, D2, D3, D4, S;
    // need to have an input binary file here to fill out pixels
    //just testing for now
    
    // now try to use a state machine
    wire [7:0] D1_a, D1_b, D2_a, D2_b, D3_a, D3_b, D4_a, D4_b;    
    
    assign D1_a = (z4 >= z0) ? (z4 - z0):(z0 - z4);
    assign D1_b = (z8 >= z4) ? (z8 - z4):(z4 - z8);
    assign D1   = D1_a + D1_b;
    assign D2_a = (z4 >= z1) ? (z4 - z1):(z1 - z4);
    assign D2_b = (z7 >= z4) ? (z7 - z4):(z4 - z7);
    assign D2   = D2_a + D2_b;
    assign D3_a = (z4 >= z2) ? (z4 - z2):(z2 - z4);
    assign D3_b = (z6 >= z4) ? (z6 - z4):(z4 - z6);
    assign D3   = D3_a + D3_b;
    assign D4_a = (z4 >= z3) ? (z4 - z3):(z3 - z4);
    assign D4_b = (z5 >= z4) ? (z5 - z4):(z4 - z5);
    assign D4   = D4_a + D4_b;
    assign S    = (D1 + D2 + D3 + D4);
endmodule

