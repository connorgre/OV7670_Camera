`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/22/2022 04:35:58 PM
// Design Name: 
// Module Name: Pixel_BrightNess_Shifter
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


module Pixel_Brightness_Shifter(
    input [3:0] pixelR,
    input [3:0] pixelG,
    input [3:0] pixelB,
    input       shiftSig,
    
    output [3:0] rOut,
    output [3:0] gOut,
    output [3:0] bOut
    );
    
    wire [3:0] rShift [4:0];
    assign rShift[0] =          pixelR;
    assign rShift[1] = {1'b0,   pixelR[3:1]};
    assign rShift[2] = {2'b00,  pixelR[3:2]};
    assign rShift[3] = {3'b000, pixelR[3]};
    assign rShift[4] =  4'b0000;
    
    wire [3:0] gShift [4:0];
    assign gShift[0] =          pixelG;
    assign gShift[1] = {1'b0,   pixelG[3:1]};
    assign gShift[2] = {2'b00,  pixelG[3:2]};
    assign gShift[3] = {3'b000, pixelG[3]};
    assign gShift[4] =  4'b0000;
    
    wire [3:0] bShift [4:0];
    assign bShift[0] =          pixelB;
    assign bShift[1] = {1'b0,   pixelB[3:1]};
    assign bShift[2] = {2'b00,  pixelB[3:2]};
    assign bShift[3] = {3'b000, pixelB[3]};
    assign bShift[4] =  4'b0000;
    
    reg [2:0] shiftCnt = 3'b000;
    always@(posedge shiftSig) begin
        if(shiftCnt == 4)
            shiftCnt <= 3'b000;
        else
            shiftCnt <= shiftCnt + 1;
    end
    
    assign rOut = rShift[shiftCnt];
    assign gOut = gShift[shiftCnt];
    assign bOut = bShift[shiftCnt];
    
endmodule
