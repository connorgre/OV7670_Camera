`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2022 05:47:59 PM
// Design Name: 
// Module Name: TopModule
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


module TopModule(
    input clk100,
    // VGA OUT
    output  [3:0]   vga_red,
    output  [3:0]   vga_green,
    output  [3:0]   vga_blue,
    output          vga_hsync,
    output          vga_vsync,
    
    //LED
    output  [15:0]   LED,
    
    // Camera Pins
    input wire [7:0]    OV7670_D,
    input               OV7670_HREF,
    input               OV7670_VSYNC,
    input               OV7670_PCLK,
    inout               OV7670_SIOD,
    output              OV7670_SIOC,
    output              OV7670_PWDN,
    output              OV7670_RESET,
    output              OV7670_XCLK,
    
    // 7 Segment Display
    output  [6:0]       SEG,
    output  [7:0]       AN,
    output              DP,
    
    // Buttons
    input               btnc
    );
    reg clk50 = 0;
    reg clk25 = 0;
    always@(posedge clk100) begin
        clk50 <= ~clk50;
    end
    always@(posedge clk50) begin
        clk25 <= ~clk25;
    end
    wire btncPressed;
    Debouncer btncDeb (btnc, clk25, btncPressed);
    
    wire [18:0] pixelAddr;
    wire [15:0] pixelValue;
    wire        pixelValid;
    
    
    
    Camera_Controller camCtrl ( .clk25(clk25),
                                .OV7670_D(OV7670_D),
                                .OV7670_HREF(OV7670_HREF),
                                .OV7670_VSYNC(OV7670_VSYNC),
                                .OV7670_PCLK(OV7670_PCLK),
                                .OV7670_SIOD(OV7670_SIOD),
                                .OV7670_SIOC(OV7670_SIOC),
                                .OV7670_PWDN(OV7670_PWDN),
                                .OV7670_RESET(OV7670_RESET),
                                .OV7670_XCLK(OV7670_XCLK),
                                .pixelAddr(pixelAddr),
                                .pixelValue(pixelValue),
                                .pixelValid(pixelValid)
    );

    wire [3:0] memR;
    wire [3:0] memG;
    wire [3:0] memB;
    wire [18:0] vgaAddr;
    // the read latency is up to 2 clock cycles... I'm fixing this by using clk100 as the
    // read clock, but it's possible I need delay the write by two cycles.
    
    // don't overwrite.
    // both buffers are clocked at 100 purposely.
    wire writeEn = ((pixelAddr < 19'd307200) && (~btncPressed));
    FrameBuffer frameBuf (  .writeClk(clk100), 
                            .inAddr(pixelAddr),
                            .writeEn(pixelValid & writeEn),
                            .pixelIn(pixelValue),
                            
                            .readClk(clk100),
                            .outAddr(vgaAddr),
                            .outR(memR),
                            .outG(memG),
                            .outB(memB)
    );
    
    VGA vga (   .pixel_clk(clk25),
                .mem_R(memR),
                .mem_G(memG),
                .mem_B(memB),
                .pixelAddr(vgaAddr),
                .VGA_R(vga_red),
                .VGA_B(vga_blue),
                .VGA_G(vga_green),
                .VGA_HS(vga_hsync),
                .VGA_VS(vga_vsync)
    );
    reg [31:0] numPixels = 32'h0000_0000;
    always@(posedge pixelValid)
        numPixels <= numPixels + 1;
    seg7decimal(numPixels, clk100, SEG, AN, DP);
    
    reg [15:0] frameCnt = 16'h0000;
    reg atZero = 0;
    assign LED = frameCnt;
    always@(posedge clk100) begin
        if (pixelAddr == 19'h0_0000 && atZero == 0) begin
            frameCnt <= frameCnt + 1;
            atZero <= 1;
        end else if (pixelAddr != 19'h0_0000) begin
            atZero <= 0;
        end
    end
    
endmodule
