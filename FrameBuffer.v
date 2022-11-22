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
    output  [3:0]   outR,
    output  [3:0]   outG,
    output  [3:0]   outB
    );
    
    // I am unsure if the data getting written is correct...  The RGB may be in a different order
    // right now I assume pixelIn is        RRRRR_GGGGGG_BBBBB
    //                                      15-11 10---5 4---0
    // The data getting written to RAM is   RRRRx_GGGGxx_BBBBx
    //                                      15-12 10-7   4-1
    // 3 4x307,200 block memories.
    
    wire [18:0] inAddr = (inY <= 480 && inX <= 640) ? (inY * 640 + inX) : 19'h0_0000;
    wire [18:0] outAddr = (outY <= 480 && outX <= 640) ? (outY * 640 + outX) : 19'h0_0000;
    
    
    wire [3:0] redIn   = {pixelIn[15:12]};//, 1'b0};
    wire [3:0] greenIn = {pixelIn[10:7]};//,  1'b0};
    wire [3:0] blueIn  = {pixelIn[4:1]};//,   1'b0};
    
    blk_mem_gen_0 ramRed (  .addra(inAddr),
                            .clka(writeClk),
                            .dina(redIn),
                            .ena(1'b1),
                            .wea(writeEn),
                            .addrb(outAddr),
                            .clkb(readClk),
                            .doutb(outR),
                            .enb(1'b1)                            
    );
    blk_mem_gen_0 ramBlue ( .addra(inAddr),
                            .clka(writeClk),
                            .dina(blueIn),
                            .ena(1'b1),
                            .wea(writeEn),
                            .addrb(outAddr),
                            .clkb(readClk),
                            .doutb(outB),
                            .enb(1'b1)                            
    );
    blk_mem_gen_0 ramGreen (.addra(inAddr),
                            .clka(writeClk),
                            .dina(greenIn),
                            .ena(1'b1),
                            .wea(writeEn),
                            .addrb(outAddr),
                            .clkb(readClk),
                            .doutb(outG),
                            .enb(1'b1)                            
    );
    
endmodule
