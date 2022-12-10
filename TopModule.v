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
    input               BTNR,
    input               BTND,
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
    wire btnrPressed;
    wire btndPressed;
    
    wire cameraOn = btncPressed;
    wire edgeDetectEnable = btnlPressed;
    wire edgeBrightnessShift = btnuPressed;
    wire blurImage = btnrPressed;
    wire blurEnd   = btndPressed;
    
    ButtonToggle btncTog (BTNC, clk25, btncPressed);
    ButtonToggle btnlTog (BTNL, clk25, btnlPressed);
    Debouncer    btnrDeb (BTNR, clk25, btnrPressed);
    Debouncer    btnuDeb (BTNU, clk25, btnuPressed);
    Debouncer    btndDeb (BTND, clk25, btndPressed);
    
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

    // don't overwrite memory.  All extra processing must be done on separate, smaller pixel buffers.
    //                          Then, for every clock cycle of latency introduced by processing and 
    //                          using the extra buffers, read extra lines ahead to populate the buffers
    //                          in time so the final output is the vgaX and vgaY
    //                          
    //                          Right now, all this extra processing is done in the frame buffer, as it is
    //                          easier to keep track of how far ahead we need to read like this.
    wire writeEn = ((camX <= 640) && (camY <= 480) && (cameraOn));
    wire [11:0] pSq [8:0];
    wire [11:0] edgeOut;
    wire [11:0] vgaPixel;
    FrameBuffer frameBuf (  .writeClk(OV7670_PCLK), 
                            .inX(camX),
                            .inY(camY),
                            .writeEn(pixelValid & writeEn),
                            .pixelIn(pixelValue),
                            .edgePixelIn(edgeOut),
                            .blurPixel(blurImage),
                            .blurEnd(blurEnd),
                            .useMedian(SW[15:14]),
                            .readClk(clk50),
                            .vgaClk(clk25),
                            .outX(vgaX),
                            .outY(vgaY),
                            .outPixel_lu(pSq[0]),
                            .outPixel_lm(pSq[1]),
                            .outPixel_ld(pSq[2]),
                            .outPixel_mu(pSq[3]),
                            .outPixel_mm(pSq[4]),
                            .outPixel_md(pSq[5]),
                            .outPixel_ru(pSq[6]),
                            .outPixel_rm(pSq[7]),
                            .outPixel_rd(pSq[8]),
                            .outPixel_toVGA(vgaPixel)                            
    );

    // this pixel is piped back into the frame buffer, bc we need to
    // put it into an extra pixel buffer to run the median filter over
    // it after the edges have been detected.
    wire frameDone = (vgaY == 9'h000);
    reg changeColor;
    reg [3:0] frameCounter;
    always@(posedge frameDone) begin
        if (SW[10:8] > 3'h0) begin
            if (frameCounter == {SW[10:8], 1'b1}) begin
                changeColor <= ~changeColor;
                frameCounter <= 4'h0;
            end else begin
                frameCounter <= frameCounter + 1;
            end
        end
    end
    
    ResolvePixel pixResolve (   .xAddr(vgaX),
                                .inPixel_lu(pSq[0]),
                                .inPixel_lm(pSq[1]),
                                .inPixel_ld(pSq[2]),
                                .inPixel_mu(pSq[3]),
                                .inPixel_mm(pSq[4]),
                                .inPixel_md(pSq[5]),
                                .inPixel_ru(pSq[6]),
                                .inPixel_rm(pSq[7]),
                                .inPixel_rd(pSq[8]),
                                .clk25(clk25),
                                .clk100(clk100),
                                // sobel.
                                .cutThresh(4'hF),       // this was determined as a good threshold value.
                                .absThresh(SW[7:4]),
                                .totThresh(SW[7:4]),
                                .numEdgesNeeded(SW[3:0]),
                                .sobelKernelThresh(SW[3:0]),
                                .gradThresh(SW[6:0]),       // 4 is a good threshold.  This is for adding extra gradient colors.  goes from 8 to 24
                                .gradMax(SW[7]),
                                .frameDone(changeColor),
                                .shiftBrightness(edgeBrightnessShift),
                                .edgeDetectEnable(edgeDetectEnable),
                                .edgeType(SW[13:11]),
                                .outPixel(edgeOut)
    );

    VGA vga (   .pixel_clk(clk25),
                .vgaInR(vgaPixel[11:8]),
                .vgaInG(vgaPixel[7:4]),
                .vgaInB(vgaPixel[3:0]),
                .outX(vgaX),
                .outY(vgaY),
                .VGA_R(vga_red),
                .VGA_B(vga_blue),
                .VGA_G(vga_green),
                .VGA_HS(vga_hsync),
                .VGA_VS(vga_vsync)
    );

    wire [15:0] const0 = 16'h0000;
    seg7decimal({const0, SW}, clk100, SEG, AN, DP);
    assign LED = SW;
    
endmodule
