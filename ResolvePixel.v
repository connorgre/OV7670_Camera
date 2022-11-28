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
    input [3:0] absThresh,
    input [3:0] totThresh,
    input [3:0] numEdgesNeeded,
    input       shiftBrightness,
    input       edgeDetectEnable,
    
    output [3:0] outR,
    output [3:0] outG,
    output [3:0] outB
    );

    wire [12*9-1:0] inPixels9x9;
    wire [3*9-1:0]  outEdge9x9;
    wire [2:0]      isEdge;
    assign inPixels9x9 = {  inPixel_lu,
                            inPixel_lm,
                            inPixel_ld,
                            inPixel_mu,
                            inPixel_mm,
                            inPixel_md,
                            inPixel_ru,
                            inPixel_rm,
                            inPixel_rd
                         };
    genvar i;
    generate
        for (i = 0; i < 9; i=i+1) begin
        // rThresh is locked at cutThresh, this will make any edges at cutThresh
        // be white (assuming gThresh and bThresh < cutThresh)
            Sobel_Edge_Detection sobelEdge (    .xAddr(xAddr),
                                                .pixelIn(inPixels9x9[12*(i+1)-1 : 12*i]),
                                                .clk25(clk25),
                                                .cutThresh(cutThresh),
                                                .absThresh(absThresh),
                                                .totThresh(totThresh),
                                                .outEdge(outEdge9x9[3*(i+1)-1 : 3*i]));
        end
    endgenerate
    // this is to make writing it easier
    wire [3*9-1:0]  oe = outEdge9x9;
    //                          lu      lm      ld      mu       mm       md       ru       rm       rd
    wire [8:0] blueEdgeBits  = {oe[0] , oe[3] , oe[6] , oe[9]  , oe[12] , oe[15] , oe[18] , oe[21] , oe[24]};
    wire [8:0] greenEdgeBits = {oe[1] , oe[4] , oe[7] , oe[10] , oe[13] , oe[16] , oe[19] , oe[22] , oe[25]};
    wire [8:0] redEdgeBits   = {oe[2] , oe[5] , oe[8] , oe[11] , oe[14] , oe[17] , oe[20] , oe[23] , oe[26]};

    wire [3:0] blueEdges;
    wire [3:0] greenEdges;
    wire [3:0] redEdges;

    PopCnt9 blueCnt  (.in(blueEdgeBits),  .cnt(blueEdges));
    PopCnt9 greenCnt (.in(greenEdgeBits), .cnt(greenEdges));
    PopCnt9 redCnt   (.in(redEdgeBits),   .cnt(redEdges));

    // if numEdgesNeeded == 0, then use the middle pixel as the determination
    wire redEdge   = (numEdgesNeeded[3:0] == 4'h0) ? oe[14] : (redEdges[3:0]   > numEdgesNeeded[3:0]);
    wire greenEdge = (numEdgesNeeded[3:0] == 4'h0) ? oe[13] : (greenEdges[3:0] > numEdgesNeeded[3:0]);
    wire blueEdge  = (numEdgesNeeded[3:0] == 4'h0) ? oe[12] : (blueEdges[3:0]  > numEdgesNeeded[3:0]);

    wire [3:0] dimmedR;
    wire [3:0] dimmedG;
    wire [3:0] dimmedB;
    Pixel_Brightness_Shifter brightShift (  .pixelR(inPixel_mm[11:8]),
                                            .pixelG(inPixel_mm[7:4]),
                                            .pixelB(inPixel_mm[3:0]),
                                            .shiftSig(shiftBrightness),
                                            .rOut(dimmedR),
                                            .gOut(dimmedG),
                                            .bOut(dimmedB));

    wire [3:0] edgeR = (redEdge)   ? 4'hF : dimmedR;
    wire [3:0] edgeG = (greenEdge) ? 4'hF : dimmedG;
    wire [3:0] edgeB = (blueEdge)  ? 4'hF : dimmedB;

    assign outR = (edgeDetectEnable) ? edgeR : inPixel_mm[11:8];
    assign outG = (edgeDetectEnable) ? edgeG : inPixel_mm[7:4];
    assign outB = (edgeDetectEnable) ? edgeB : inPixel_mm[3:0];
endmodule
