`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/22/2022 12:38:06 PM
// Design Name: 
// Module Name: Sobel_Edge_Detection
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

// calculates the pixel difference between top and left pixel.
module Sobel_Edge_Detection(
    input [9:0]  xAddr,
    input [11:0] pixelIn,
    input        clk25,
    // threshold values to display RGB colors at.  Will show a pixel if
    // value is above colorThresh and below cutThresh
    input [3:0] cutThresh,
    input [3:0] rThresh,
    input [3:0] gThresh,
    input [3:0] bThresh,
    input       shiftBrightness,
    
    output [11:0] outPixel
    );
    
    wire [3:0] pixelR = pixelIn[11:8];
    wire [3:0] pixelG = pixelIn[7:4];
    wire [3:0] pixelB = pixelIn[3:0];
    
    localparam weakThresh   = 1;
    localparam midThresh    = 4;
    localparam strongThresh = 7;
    localparam vsThresh     = 10;
    localparam topThresh    = 14;
    reg [11:0] prevLine [639:0];
    reg [11:0] prevXPixel;
    reg [11:0] currPixelReg;
    wire [11:0] currPixel = {pixelR, pixelG, pixelB};
    reg [11:0] prevYPixel;
    always@(posedge clk25) begin
        prevLine[xAddr] <= currPixel;
        prevYPixel <= prevLine[xAddr];
        currPixelReg <= currPixel;
        prevXPixel <= currPixelReg;
    end

    // get X and Y difference
    wire [11:0] diffX = (currPixel > prevXPixel) ? (currPixel - prevXPixel) : (prevXPixel - currPixel);
    wire [11:0] diffY = (currPixel > prevYPixel) ? (currPixel - prevYPixel) : (prevYPixel - currPixel);
    
    // difference in each direction for each pixel
    wire [11:0] maxDiffA;
    assign maxDiffA[11:8] = (diffX[11:8] > diffY[11:8]) ? diffX[11:8] : diffY[11:8];
    assign maxDiffA[7:4]  = (diffX[7:4]  > diffY[7:4])  ? diffX[7:4]  : diffY[7:4];
    assign maxDiffA[3:0]  = (diffX[3:0]  > diffY[3:0])  ? diffX[3:0]  : diffY[3:0];
    
    // get the maximum difference.
    wire [3:0] maxDiffB = (maxDiffA[11:8] > maxDiffA[7:4]) ? maxDiffA[11:8] : maxDiffA[7:4];
    wire [3:0] maxDiff  = (maxDiffA[3:0]  > maxDiffB)      ? maxDiffA[3:0]  : maxDiffB;
    
    wire passCutoff =  maxDiff <= cutThresh;
    wire redEdge    = (maxDiff >= rThresh) && passCutoff;
    wire greenEdge  = (maxDiff >= gThresh) && passCutoff;
    wire blueEdge   = (maxDiff >= bThresh) && passCutoff;

    wire [3:0] dimmedR;
    wire [3:0] dimmedG;
    wire [3:0] dimmedB;
    
    Pixel_Brightness_Shifter brightShift (  .pixelR(pixelR),
                                            .pixelG(pixelG),
                                            .pixelB(pixelB),
                                            .shiftSig(shiftBrightness),
                                            .rOut(dimmedR),
                                            .gOut(dimmedG),
                                            .bOut(dimmedB));

    assign outPixel[11:8] = (redEdge)   ? 4'hF : dimmedR;
    assign outPixel[7:4]  = (greenEdge) ? 4'hF : dimmedG;
    assign outPixel[3:0]  = (blueEdge)  ? 4'hF : dimmedB;
endmodule
