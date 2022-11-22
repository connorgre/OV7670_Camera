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
    input               BTNC,
    input               BTNL,
    input               BTNU,
    // switches
    input [15:0]        SW
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
    wire btnlPressed;
    wire btnuPressed;
    
    wire cameraOff = btncPressed;
    wire edgeDetectEnable = btnlPressed;
    wire edgeBrightnessShift = btnuPressed;
    
    ButtonToggle btncTog (BTNC, clk25, btncPressed);
    ButtonToggle btnlTog (BTNL, clk25, btnlPressed);
    Debouncer    btnuDeb (BTNU, clk25, btnuPressed);
    wire [9:0]  camX;
    wire [8:0]  camY;
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
                                .outX(camX),
                                .outY(camY),
                                .pixelValue(pixelValue),
                                .pixelValid(pixelValid)
    );

    wire [3:0] memR;
    wire [3:0] memG;
    wire [3:0] memB;
    wire [9:0] vgaX;
    wire [8:0] vgaY;
    // the read latency is up to 2 clock cycles... I'm fixing this by using clk100 as the
    // read clock, but it's possible I need delay the write by two cycles.
    
    // don't overwrite.
    // both ports are clocked at 100 purposely.
    wire writeEn = ((camX <= 640) && (camY <= 480)&& (~cameraOff));
    FrameBuffer frameBuf (  .writeClk(clk100), 
                            .inX(camX),
                            .inY(camY),
                            .writeEn(pixelValid & writeEn),
                            .pixelIn(pixelValue),
                            
                            .readClk(clk100),
                            .outX(vgaX),
                            .outY(vgaY),
                            .outR(memR),
                            .outG(memG),
                            .outB(memB)
    );
    
    wire [3:0] edgeR;
    wire [3:0] edgeG;
    wire [3:0] edgeB;
    Sobel_Edge_Detection edgeDetect (   .xAddr(vgaX),
                                        .pixelR(memR),
                                        .pixelG(memG),
                                        .pixelB(memB),
                                        .clk25(clk25),
                                        
                                        .cutThresh(SW[3:0]),
                                        .rThresh(SW[15:12]),
                                        .gThresh(SW[11:8]),
                                        .bThresh(SW[7:4]),
                                        .shiftBrightness(edgeBrightnessShift),
                                        
                                        .outR(edgeR),
                                        .outG(edgeG),
                                        .outB(edgeB));
    wire [3:0] vgaR = (edgeDetectEnable) ? edgeR : memR;
    wire [3:0] vgaG = (edgeDetectEnable) ? edgeG : memG;
    wire [3:0] vgaB = (edgeDetectEnable) ? edgeB : memB;
    VGA vga (   .pixel_clk(clk25),
                .vgaInR(vgaR),
                .vgaInG(vgaG),
                .vgaInB(vgaB),
                .outX(vgaX),
                .outY(vgaY),
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
        if ((camX + camY) == 0 && atZero == 0) begin
            frameCnt <= frameCnt + 1;
            atZero <= 1;
        end else if ((camX + camY) != 0) begin
            atZero <= 0;
        end
    end
    
endmodule
