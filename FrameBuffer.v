`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2022 05:24:58 PM
// Design Name: 
// Module Name: FrameBuffer
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

// Sets up 3 block RAMs, one for each pixel color.
// Also pipelines the intermediate frame buffers for holding
// pixelOut -> blur -> edges
module FrameBuffer(
    input           writeClk,
    input   [9:0]   inX,
    input   [8:0]   inY,
    input           writeEn,
    input   [15:0]  pixelIn,
    
    input   [11:0]  edgePixelIn,
    
    input           readClk,
    input           vgaClk,

    input   [9:0]   outX,
    input   [8:0]   outY,
    
    input           blurPixel,
    input   [1:0]   useMedian,
    
    // go to the edge detection
    output  [11:0]  outPixel_lu,
    output  [11:0]  outPixel_lm,
    output  [11:0]  outPixel_ld,
    output  [11:0]  outPixel_mu,
    output  [11:0]  outPixel_mm,
    output  [11:0]  outPixel_md,
    output  [11:0]  outPixel_ru,
    output  [11:0]  outPixel_rm,
    output  [11:0]  outPixel_rd,
    
    output  [11:0]  outPixel_toVGA
    );
    // read ahead 4 lines for every extra pixel buffer we have, as they are 4 lines each.  I think it could be cut to 2 lines per buffer, but it
    // would complicate things.  Will only do if necessary
    localparam extraBuffers = 4;
    localparam extraClocks = 10;
    localparam readAheadLines = extraBuffers * 4;
    localparam readAheadCols  = extraClocks;
    wire [8:0] readAheadSubY = 9'd480 - readAheadLines;
    // pixelIn is                           RRRRR_GGGGGG_BBBBB
    //                                      15-11 10---5 4---0
    // The data getting written to RAM is   RRRRx_GGGGxx_BBBBx
    //                                      15-12 10-7   4-1
    // 3 4x307,200 block memories.

    wire [18:0] inAddr = (inY <= 480 && inX <= 640) ? (inY * 640 + inX) : 19'h0_0000;

    // since this is pipelined, we actually need to read several lines ahead of where we actually are at in memory
    wire [9:0] readX = outX;
    wire [8:0] readY = (outY >= readAheadSubY) ? outY - readAheadSubY : outY + readAheadLines;

    wire [18:0] readAddr = (readY <= 480 && readX <= 640) ? (readY * 640 + readX) : 19'h0_0000;

    wire [3:0] redIn   = {pixelIn[15:12]};//, 1'b0};
    wire [3:0] greenIn = {pixelIn[10:7]};//,  1'b0};
    wire [3:0] blueIn  = {pixelIn[4:1]};//,   1'b0};

    wire [3:0] readPixR;
    wire [3:0] readPixG;
    wire [3:0] readPixB;
    
    blk_mem_gen_0 ramRed (  .addra(inAddr),
                            .clka(writeClk),
                            .dina(redIn),
                            .ena(1'b1),
                            .wea(writeEn),
                            .addrb(readAddr),
                            .clkb(readClk),
                            .doutb(readPixR),
                            .enb(1'b1)                            
    );
    blk_mem_gen_0 ramBlue ( .addra(inAddr),
                            .clka(writeClk),
                            .dina(blueIn),
                            .ena(1'b1),
                            .wea(writeEn),
                            .addrb(readAddr),
                            .clkb(readClk),
                            .doutb(readPixB),
                            .enb(1'b1)                            
    );
    blk_mem_gen_0 ramGreen (.addra(inAddr),
                            .clka(writeClk),
                            .dina(greenIn),
                            .ena(1'b1),
                            .wea(writeEn),
                            .addrb(readAddr),
                            .clkb(readClk),
                            .doutb(readPixG),
                            .enb(1'b1)                            
    );

    wire[11:0] med1PixOut;
    wire [11:0] medSquare[8:0];
    // +1 buf
    PixelBuf medpixBuf( .outX(outX),
                        .outY(outY[1:0]),
                        .readClk(vgaClk),
                        .pixelIn({readPixR, readPixG, readPixB}),
                        .outPixel_lu(medSquare[0]),
                        .outPixel_lm(medSquare[1]),
                        .outPixel_ld(medSquare[2]),
                        .outPixel_mu(medSquare[3]),
                        .outPixel_mm(medSquare[4]),
                        .outPixel_md(medSquare[5]),
                        .outPixel_ru(medSquare[6]),
                        .outPixel_rm(medSquare[7]),
                        .outPixel_rd(medSquare[8])
    );
    // +5 clocks
    MedianFilter medFilter1 (   .readClk(vgaClk),
                                .useMedian(useMedian[0]),
                                .inPixel_lu(medSquare[0]),
                                .inPixel_lm(medSquare[1]),
                                .inPixel_ld(medSquare[2]),
                                .inPixel_mu(medSquare[3]),
                                .inPixel_mm(medSquare[4]),
                                .inPixel_md(medSquare[5]),
                                .inPixel_ru(medSquare[6]),
                                .inPixel_rm(medSquare[7]),
                                .inPixel_rd(medSquare[8]),
                                .medOut(med1PixOut)
    );
    
    
    wire[11:0] blurPixOut;
    // +1 buf
    BlurPixel blurPix ( .inX(outX),
                        .inY(outY[1:0]),
                        .writeClk(vgaClk),
                        .pixelIn(med1PixOut),
                        .blurPixel(blurPixel),
                        .pixelOut(blurPixOut)
    );

    // +1 buf -- these go out to edge detector in top module
    PixelBuf pixelBuf(  .outX(outX),
                        .outY(outY[1:0]),
                        .readClk(vgaClk),
                        .pixelIn(blurPixOut),
                        .outPixel_lu(outPixel_lu),
                        .outPixel_lm(outPixel_lm),
                        .outPixel_ld(outPixel_ld),
                        .outPixel_mu(outPixel_mu),
                        .outPixel_mm(outPixel_mm),
                        .outPixel_md(outPixel_md),
                        .outPixel_ru(outPixel_ru),
                        .outPixel_rm(outPixel_rm),
                        .outPixel_rd(outPixel_rd)
    );
    
    // +1 buf
    wire [11:0] edgeSquare [8:0];
    PixelBuf edgeBuf (  .outX(outX),
                        .outY(outY[1:0]),
                        .readClk(vgaClk),
                        .pixelIn(edgePixelIn),
                        .outPixel_lu(edgeSquare[0]),
                        .outPixel_lm(edgeSquare[1]),
                        .outPixel_ld(edgeSquare[2]),
                        .outPixel_mu(edgeSquare[3]),
                        .outPixel_mm(edgeSquare[4]),
                        .outPixel_md(edgeSquare[5]),
                        .outPixel_ru(edgeSquare[6]),
                        .outPixel_rm(edgeSquare[7]),
                        .outPixel_rd(edgeSquare[8])
    );
    
    wire[11:0] medPixel;
    // +5 clocks
    MedianFilter medFilter2 (   .readClk(vgaClk),
                                .useMedian(useMedian[1]),
                                .inPixel_lu(edgeSquare[0]),
                                .inPixel_lm(edgeSquare[1]),
                                .inPixel_ld(edgeSquare[2]),
                                .inPixel_mu(edgeSquare[3]),
                                .inPixel_mm(edgeSquare[4]),
                                .inPixel_md(edgeSquare[5]),
                                .inPixel_ru(edgeSquare[6]),
                                .inPixel_rm(edgeSquare[7]),
                                .inPixel_rd(edgeSquare[8]),
                                .medOut(medPixel)
    );
    
    assign outPixel_toVGA = medPixel;
endmodule
