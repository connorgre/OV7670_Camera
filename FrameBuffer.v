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
    output reg [11:0]  outPixel_lu,
    output reg [11:0]  outPixel_lm,
    output reg [11:0]  outPixel_ld,
    output reg [11:0]  outPixel_mu,
    output reg [11:0]  outPixel_mm,
    output reg [11:0]  outPixel_md,
    output reg [11:0]  outPixel_ru,
    output reg [11:0]  outPixel_rm,
    output reg [11:0]  outPixel_rd
    );
    
    // I am unsure if the data getting written is correct...  The RGB may be in a different order
    // pixelIn is                           RRRRR_GGGGGG_BBBBB
    //                                      15-11 10---5 4---0
    // The data getting written to RAM is   RRRRx_GGGGxx_BBBBx
    //                                      15-12 10-7   4-1
    // 3 4x307,200 block memories.
    
    
    
    wire [18:0] inAddr = (inY <= 480 && inX <= 640) ? (inY * 640 + inX) : 19'h0_0000;
    
    // we want to be reading 4 lines ahead to write into our buffer
    wire [9:0] readX = outX;
    wire [8:0] readY = (outY >= 476) ? outY - 9'd476 : outY + 9'd4;
    
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
    
    // buffer to hold 4 lines of pixels. Do this so we can output 9 pixels at a time.
    reg [11:0] pixelBuf [679:0] [3:0];
    wire [1:0] yUp = outY[1:0] - 2'b01;
    wire [1:0] yM  = outY[1:0];
    wire [1:0] yDn = outY[1:0] + 2'b01;
    always@(posedge readClk) begin
        pixelBuf[outX][yM] <= {readPixR, readPixG, readPixB};
        outPixel_lu <= pixelBuf[outX-1][yUp];
        outPixel_lm <= pixelBuf[outX-1][yM];
        outPixel_ld <= pixelBuf[outX-1][yUp];
        outPixel_mu <= pixelBuf[outX][yUp];
        outPixel_mm <= pixelBuf[outX][yM];
        outPixel_md <= pixelBuf[outX][yDn];
        outPixel_ru <= pixelBuf[outX+1][yUp];
        outPixel_rm <= pixelBuf[outX+1][yM];
        outPixel_rd <= pixelBuf[outX+1][yDn];
    end
    
endmodule
