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
module FrameBuffer(
    input           writeClk,
    input   [9:0]   inX,
    input   [8:0]   inY,
    input           writeEn,
    input   [15:0]  pixelIn,
    
    input           readClk,

    input   [9:0]   outX,
    input   [8:0]   outY,
    
    input           blurPixel,
    
    output  [11:0]  outPixel_lu,
    output  [11:0]  outPixel_lm,
    output  [11:0]  outPixel_ld,
    output  [11:0]  outPixel_mu,
    output  [11:0]  outPixel_mm,
    output  [11:0]  outPixel_md,
    output  [11:0]  outPixel_ru,
    output  [11:0]  outPixel_rm,
    output  [11:0]  outPixel_rd
    );
    
    // pixelIn is                           RRRRR_GGGGGG_BBBBB
    //                                      15-11 10---5 4---0
    // The data getting written to RAM is   RRRRx_GGGGxx_BBBBx
    //                                      15-12 10-7   4-1
    // 3 4x307,200 block memories.
  
    
    // since the blur logic requires writing 4 lines ahead of where we actually are,
    // add 4 to the y address
    wire [8:0]  writeY = (inY >= 476 && inY <= 480) ? inY - 9'd476 : inY + 9'd4;
    wire [18:0] inAddr = (writeY <= 480 && inX <= 640) ? (writeY * 640 + inX) : 19'h0_0000;
    
    // we want to be reading 4 lines ahead to write into our buffer
    wire [9:0] readX = outX;
    wire [8:0] readY = (outY >= 476) ? outY - 9'd476 : outY + 9'd4;
    
    wire [18:0] readAddr = (readY <= 480 && readX <= 640) ? (readY * 640 + readX) : 19'h0_0000;
    
    wire [3:0] redIn   = {pixelIn[15:12]};//, 1'b0};
    wire [3:0] greenIn = {pixelIn[10:7]};//,  1'b0};
    wire [3:0] blueIn  = {pixelIn[4:1]};//,   1'b0};

    wire [11:0] writePixel;    
    BlurPixel blurPix ( .inX(inX),
                        .inY(inY[1:0]),
                        .writeClk(writeClk),
                        .pixelIn({redIn, greenIn, blueIn}),
                        .blurPixel(blurPixel),
                        .pixelOut(writePixel)
    );

    wire [3:0] readPixR;
    wire [3:0] readPixG;
    wire [3:0] readPixB;
    
    blk_mem_gen_0 ramRed (  .addra(inAddr),
                            .clka(writeClk),
                            .dina(writePixel[11:8]),
                            .ena(1'b1),
                            .wea(writeEn),
                            .addrb(readAddr),
                            .clkb(readClk),
                            .doutb(readPixR),
                            .enb(1'b1)                            
    );
    blk_mem_gen_0 ramBlue ( .addra(inAddr),
                            .clka(writeClk),
                            .dina(writePixel[3:0]),
                            .ena(1'b1),
                            .wea(writeEn),
                            .addrb(readAddr),
                            .clkb(readClk),
                            .doutb(readPixB),
                            .enb(1'b1)                            
    );
    blk_mem_gen_0 ramGreen (.addra(inAddr),
                            .clka(writeClk),
                            .dina(writePixel[7:4]),
                            .ena(1'b1),
                            .wea(writeEn),
                            .addrb(readAddr),
                            .clkb(readClk),
                            .doutb(readPixG),
                            .enb(1'b1)                            
    );
    
    PixelBuf pixelBuf(  .outX(outX),
                        .outY(outY[1:0]),
                        .readClk(readClk),
                        .pixelIn({readPixR, readPixG, readPixB}),
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
    
endmodule
