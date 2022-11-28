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
    input [3:0] absThresh,
    input [3:0] totThresh,
    
    output [2:0] outEdge
    );
    
    wire [3:0] pixelR = pixelIn[11:8];
    wire [3:0] pixelG = pixelIn[7:4];
    wire [3:0] pixelB = pixelIn[3:0];
    
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
    
    wire [5:0] totDiff = maxDiffA[11:8] + maxDiffA[7:4] + maxDiffA[3:0];
    
    wire passCutoff =  maxDiff <= cutThresh;
    // red   = max(diff(R), diff(G) ,diff(B)) >= absThresh (SW[11:8])
    // green = max(diff(R), diff(G) ,diff(B)) == cutThresh (SW[15:12])
    // blue  = diff(R) + diff(G) + diff(B)    >= totThresh (SW[7:4])
    wire redEdge    = (maxDiff >= absThresh) && passCutoff;
    wire greenEdge  = (maxDiff == cutThresh);
    wire blueEdge   = (totDiff >= totThresh) && passCutoff;

    assign outEdge = {redEdge, greenEdge, blueEdge};
endmodule
