`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2022 06:15:38 PM
// Design Name: 
// Module Name: Gaussian3x3
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// approximates gaussian kernel of 
//          | 1, 2, 1 |
//  1/16 *  | 2, 4, 2 |
//          | 1, 2, 1 |
module Gaussian3x3(
    input [11:0]  inPixel_lu,
    input [11:0]  inPixel_lm,
    input [11:0]  inPixel_ld,
    input [11:0]  inPixel_mu,
    input [11:0]  inPixel_mm,
    input [11:0]  inPixel_md,
    input [11:0]  inPixel_ru,
    input [11:0]  inPixel_rm,
    input [11:0]  inPixel_rd,
    
    output [11:0] blurredPixel
    );
    genvar i;
    wire [17:0] cornerPixels;   // 3 pixels, 6 bits each (F*4 << 0 == 0x3C)
    wire [20:0] edgePixels;     // 3 pixels, 7 bits each (F*4 << 1 == 0x78)
    wire [17:0] middlePixel;    // 3 pixels, 6 bits each (F   << 2 == 0x3C)
    wire [8*3-1:0] addVal;      // 3 pixels, 8 bits each (0x3C + 0x78 + 0x3C == 0xF0)
    generate
        for (i = 0; i < 3; i=i+1) begin
            // just add the corners together
            assign cornerPixels[6*(i+1)-1:6*i] = inPixel_lu[4*(i+1)-1:4*i] +
                                                 inPixel_ld[4*(i+1)-1:4*i] +
                                                 inPixel_ru[4*(i+1)-1:4*i] +
                                                 inPixel_rd[4*(i+1)-1:4*i];
            // multiply these by two and add, do by left shifting once
            assign edgePixels[7*(i+1)-1:7*i]   = {inPixel_rm[4*(i+1)-1:4*i] +
                                                  inPixel_mu[4*(i+1)-1:4*i] +
                                                  inPixel_md[4*(i+1)-1:4*i] +
                                                  inPixel_lm[4*(i+1)-1:4*i]  , 1'b0};

            // multiply by 4, left shift twice
            assign middlePixel[6*(i+1)-1:6*i]  = {inPixel_mm[4*(i+1)-1:4*i] , 2'b00};

            // add these all up
            assign addVal[8*(i+1)-1:8*i] = cornerPixels[6*(i+1)-1:6*i] + edgePixels[7*(i+1)-1:7*i] + middlePixel[6*(i+1)-1:6*i];

            // divide by 16, right shift by 4 (take upper 4 bits of each pixel), if MSB == 1, we overflowed, just set as max pixel value
            // MSB shouldn't ever == 1, only had it when I was adding 1 for every addition.
            assign blurredPixel[4*(i+1)-1:4*i] = addVal[8*(i+1)-1:8*i + 4];
        end
    endgenerate
endmodule
