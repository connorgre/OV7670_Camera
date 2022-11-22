`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/22/2022 05:30:20 PM
// Design Name: 
// Module Name: ResolvePixel
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

// takes in a 3x3 grid of pixels and returns the correct pixel.
module ResolvePixel(
    input [9:0] xAddr,
    input [11:0]  inPixel_lu,
    input [11:0]  inPixel_lm,
    input [11:0]  inPixel_ld,
    input [11:0]  inPixel_mu,
    input [11:0]  inPixel_mm,
    input [11:0]  inPixel_md,
    input [11:0]  inPixel_ru,
    input [11:0]  inPixel_rm,
    input [11:0]  inPixel_rd,
    input         clk25,
    input         clk100,
    
    // sobel edge detection signals
    input [3:0] cutThresh,
    input [3:0] rThresh,
    input [3:0] gThresh,
    input [3:0] bThresh,
    input       shiftBrightness,
    input       edgeDetectEnable,
    
    output [3:0] outR,
    output [3:0] outG,
    output [3:0] outB
    );
    
    
    wire [11:0] sobelOut_mm;
    Sobel_Edge_Detection sobelEdge (    .xAddr(xAddr),
                                        .pixelIn(inPixel_mm),
                                        .clk25(clk25),
                                        .cutThresh(cutThresh),
                                        .rThresh(rThresh),
                                        .gThresh(gThresh),
                                        .bThresh(bThresh),
                                        .shiftBrightness(shiftBrightness),
                                        .outPixel(sobelOut_mm));
    assign outR = (edgeDetectEnable) ? sobelOut_mm[11:8] : inPixel_mm;
    assign outG = (edgeDetectEnable) ? sobelOut_mm[7:4]  : inPixel_mm;
    assign outB = (edgeDetectEnable) ? sobelOut_mm[3:0]  : inPixel_mm;
endmodule
