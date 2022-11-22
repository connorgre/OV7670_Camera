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
    input   [18:0]  inAddr,
    input           writeEn,
    input   [15:0]  pixelIn,
    
    input           readClk,
    input   [18:0]  outAddr,
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
    blk_mem_gen_0 ramRed (  .addra(inAddr),
                            .clka(writeClk),
                            .dina(pixelIn[15:12]),
                            .ena(1'b1),
                            .wea(writeEn),
                            .addrb(outAddr),
                            .clkb(readClk),
                            .doutb(outR),
                            .enb(1'b1)                            
    );
    blk_mem_gen_0 ramBlue ( .addra(inAddr),
                            .clka(writeClk),
                            .dina(pixelIn[4:1]),
                            .ena(1'b1),
                            .wea(writeEn),
                            .addrb(outAddr),
                            .clkb(readClk),
                            .doutb(outB),
                            .enb(1'b1)                            
    );
    blk_mem_gen_0 ramGreen (.addra(inAddr),
                            .clka(writeClk),
                            .dina(pixelIn[10:7]),
                            .ena(1'b1),
                            .wea(writeEn),
                            .addrb(outAddr),
                            .clkb(readClk),
                            .doutb(outG),
                            .enb(1'b1)                            
    );
    
endmodule
