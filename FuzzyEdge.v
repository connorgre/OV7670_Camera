`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2022 03:25:25 PM
// Design Name: 
// Module Name: FuzzyEdge
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


module FuzzyEdge(
    input [11:0]  inPixel_lu,
    input [11:0]  inPixel_lm,
    input [11:0]  inPixel_ld,
    input [11:0]  inPixel_mu,
    input [11:0]  inPixel_mm,
    input [11:0]  inPixel_md,
    input [11:0]  inPixel_ru,
    input [11:0]  inPixel_rm,
    input [11:0]  inPixel_rd,

    output [11:0] fuzzyEdge,
    output [11:0] morEdge
    );
    
    wire [11:0] pixels [8:0];
    assign pixels[0] = inPixel_lu;
    assign pixels[1] = inPixel_lm;
    assign pixels[2] = inPixel_ld;
    assign pixels[3] = inPixel_mu;
    assign pixels[4] = inPixel_mm;
    assign pixels[5] = inPixel_md;
    assign pixels[6] = inPixel_ru;
    assign pixels[7] = inPixel_rm;
    assign pixels[8] = inPixel_rd;

    wire [11:0] bwPixels [8:0];
    wire [4:0]  bwVal [8:0];
    wire [5:0] pixelSum [8:0];
    genvar i;
    generate
        for (i=0; i<9; i=i+1) begin
            assign pixelSum[i] = pixels[i][11:8] + pixels[i][7:4] + pixels[i][3:0];
            Divider6BitBy3 div (pixelSum[i], bwVal[i]);
            assign bwPixels[i] = {bwVal[i][3:0], bwVal[i][3:0], bwVal[i][3:0]};
        end
    endgenerate
    
    // to simplify things, just append 0 to the end of the BW pixels
    // maybe 0xF could be better...
    wire [7:0] fuzzyPixelIn [8:0];
    genvar j;
    generate
        for (i=0; i<9; i=i+1) begin
            assign fuzzyPixelIn[i] = {bwPixels[i], 4'h0};
        end
    endgenerate
    
    wire [7:0] fuzzyOut;
    wire [7:0] morGradOut;
    fuzzy_vec fuzzEdge (    .z0(fuzzyPixelIn[0]),
                            .z1(fuzzyPixelIn[1]),
                            .z2(fuzzyPixelIn[2]),
                            .z3(fuzzyPixelIn[3]),
                            .z4(fuzzyPixelIn[4]),
                            .z5(fuzzyPixelIn[5]),
                            .z6(fuzzyPixelIn[6]),
                            .z7(fuzzyPixelIn[7]),
                            .z8(fuzzyPixelIn[8]),
                            .rgb(fuzzyOut),
                            .S(morGradOut)
    );
    // idk if this will yield the best results, however it's the simplest for now.
    reg [3:0] fuzzyG;
    reg [3:0] morG;
    always@(*) begin
        if (fuzzyOut[7:4] > 4'b1000) begin
            fuzzyG <= fuzzyOut[3:0];
        end else if (fuzzyOut[7:4] > 4'b0100) begin
            fuzzyG <= {1'b0, fuzzyOut[3:1]};
        end else if (fuzzyOut[7:4] > 4'b0010) begin
            fuzzyG <= {2'b00, fuzzyOut[3:2]};
        end else
            fuzzyG <= {3'b000, fuzzyOut[3]};
            
        if (morGradOut[7:4] > 4'b1000) begin
            morG <= morGradOut[3:0];
        end else if (morGradOut[7:4] > 4'b0100) begin
            morG <= {1'b0, morGradOut[3:1]};
        end else if (morGradOut[7:4] > 4'b0010) begin
            morG <= {2'b00, morGradOut[3:2]};
        end else
            morG <= {3'b000, morGradOut[3]};
    end

    wire [11:0] fuzzyPixel = {fuzzyOut[7:4],   fuzzyG, 4'h0};
    wire [11:0] morPixel   = {morGradOut[7:4], morG,   4'h0};
    
    assign fuzzyEdge = fuzzyPixel;
    assign morEdge = morPixel;
endmodule
