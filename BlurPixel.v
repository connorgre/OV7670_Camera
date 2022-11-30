`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2022 06:36:09 PM
// Design Name: 
// Module Name: BlurPixel
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


module BlurPixel(
    input   [9:0]   inX,
    input   [1:0]   inY,
    input           writeClk,
    input   [11:0]  pixelIn,
    input           blurPixel,
    
    output  [11:0] pixelOut
    );
    
    wire [11:0] pSq [8:0];
    
    PixelBuf pBuf(  .outX(inX),
                    .outY(inY),
                    .readClk(writeClk),
                    .pixelIn(pixelIn),
                    .outPixel_lu(pSq[0]),
                    .outPixel_lm(pSq[1]),
                    .outPixel_ld(pSq[2]),
                    .outPixel_mu(pSq[3]),
                    .outPixel_mm(pSq[4]),
                    .outPixel_md(pSq[5]),
                    .outPixel_ru(pSq[6]),
                    .outPixel_rm(pSq[7]),
                    .outPixel_rd(pSq[8])  
     );
     
     wire [11:0] gaussBlur;
     wire [11:0] averageBlur;
     
     Gaussian3x3 gausFilter(    .inPixel_lu(pSq[0]),
                                .inPixel_lm(pSq[1]),
                                .inPixel_ld(pSq[2]),
                                .inPixel_mu(pSq[3]),
                                .inPixel_mm(pSq[4]),
                                .inPixel_md(pSq[5]),
                                .inPixel_ru(pSq[6]),
                                .inPixel_rm(pSq[7]),
                                .inPixel_rd(pSq[8]),
                                .blurredPixel(gaussBlur)
    );
    
    Average3x3 avgFilter(   .inPixel_lu(pSq[0]),
                            .inPixel_lm(pSq[1]),
                            .inPixel_ld(pSq[2]),
                            .inPixel_mu(pSq[3]),
                            .inPixel_mm(pSq[4]),
                            .inPixel_md(pSq[5]),
                            .inPixel_ru(pSq[6]),
                            .inPixel_rm(pSq[7]),
                            .inPixel_rd(pSq[8]),
                            .blurredPixel(averageBlur)
    );

    reg [1:0] blurType = 2'b00;
    always@(posedge blurPixel) begin
        if (blurType == 2'b10) 
            blurType <= 2'b00;
        else
            blurType <= blurType + 1;
    end
    assign pixelOut = ((blurType == 2'b10) ? averageBlur : ((blurType == 2'b01) ? gaussBlur : pSq[4]));

endmodule
