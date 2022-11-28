`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2022 01:16:31 PM
// Design Name: 
// Module Name: PixelBuf
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

// outputs the 3x3 region of pixels around outX and outY
module PixelBuf(
    input   [9:0]   outX,
    input   [1:0]   outY,
    input           readClk,
    input   [11:0]  pixelIn,
    
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
    
    // buffer to hold 4 lines of pixels. Do this so we can output 9 pixels at a time.
    // this takes forever to synthesize if 3D ram is used bc it uses a bunch of LUTs instead
    // addressing is [{xAddr, yAddr[lowBits]}]
    reg [11:0] pixelBuf0 [679:0];
    reg [11:0] pixelBuf1 [679:0];
    reg [11:0] pixelBuf2 [679:0];
    reg [11:0] pixelBuf3 [679:0];
    reg [11:0] nextU;
    reg [11:0] nextM;
    reg [11:0] nextD;

    /*
    reg [11:0] pixelBuf [680 * 4 - 1 :0];
    wire [1:0] yUp = outY[1:0] - 2'b01;
    wire [1:0] yM  = outY[1:0];
    wire [1:0] yDn = outY[1:0] + 2'b01;
    */
    always@(posedge readClk) begin
        // write the pixel to the appropriate BRAM
        case(outY)
            2'b00: begin
                pixelBuf0[outX] <= pixelIn;
                nextU <= pixelBuf3[outX + 1];
                nextM <= pixelBuf0[outX + 1];
                nextD <= pixelBuf1[outX + 1];
            end
            2'b01: begin 
                pixelBuf1[outX] <= pixelIn;
                nextU <= pixelBuf0[outX + 1];
                nextM <= pixelBuf1[outX + 1];
                nextD <= pixelBuf2[outX + 1];
            end
            2'b10: begin 
                pixelBuf2[outX] <= pixelIn;
                nextU <= pixelBuf1[outX + 1];
                nextM <= pixelBuf2[outX + 1];
                nextD <= pixelBuf3[outX + 1];
            end
            2'b11: begin 
                pixelBuf3[outX] <= pixelIn;
                nextU <= pixelBuf2[outX + 1];
                nextM <= pixelBuf3[outX + 1];
                nextD <= pixelBuf0[outX + 1];
            end
        endcase
        // this will cause a drift of 1 pixel for the vgaOut, but thats ok.
        outPixel_lu <= outPixel_mu;
        outPixel_mu <= outPixel_ru;
        outPixel_ru <= nextU;
        outPixel_lm <= outPixel_mm;
        outPixel_mm <= outPixel_rm;
        outPixel_rm <= nextM;
        outPixel_ld <= outPixel_md;
        outPixel_md <= outPixel_rd;
        outPixel_rd <= nextD;

        /*
        pixelBuf[{outX, yM}] <= pixelIn;
        outPixel_lu <= pixelBuf[{outX-1, yUp}];
        outPixel_lm <= pixelBuf[{outX-1, yM}];
        outPixel_ld <= pixelBuf[{outX-1, yDn}];
        outPixel_mu <= pixelBuf[{outX,   yUp}];
        outPixel_mm <= pixelBuf[{outX,   yM}];
        outPixel_md <= pixelBuf[{outX,   yDn}];
        outPixel_ru <= pixelBuf[{outX+1, yUp}];
        outPixel_rm <= pixelBuf[{outX+1, yM}];
        outPixel_rd <= pixelBuf[{outX+1, yDn}];
        */
    end
endmodule
