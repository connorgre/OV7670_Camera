`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2022 08:08:31 PM
// Design Name: 
// Module Name: Sobel3x3GradDirection
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


module Sobel3x3GradDirection(
    input [11:0]  inPixel_lu,
    input [11:0]  inPixel_lm,
    input [11:0]  inPixel_ld,
    input [11:0]  inPixel_mu,
  //input [11:0]  inPixel_mm,
    input [11:0]  inPixel_md,
    input [11:0]  inPixel_ru,
    input [11:0]  inPixel_rm,
    input [11:0]  inPixel_rd,

    input [6:0]   edgeThresh,
    input         gradMax,
    input [4:0]   colorShift,
    
    output [11:0] sobelEdge
    );
    
    wire [11:0] pixels [7:0];
    assign pixels[0] = inPixel_lu;
    assign pixels[1] = inPixel_lm;
    assign pixels[2] = inPixel_ld;
    assign pixels[3] = inPixel_mu;
    assign pixels[4] = inPixel_md;
    assign pixels[5] = inPixel_ru;
    assign pixels[6] = inPixel_rm;
    assign pixels[7] = inPixel_rd;

    wire [11:0] bwPixels [7:0];
    wire [4:0]  bwVal [7:0];
    wire [5:0] pixelSum [7:0];
    genvar i;
    generate
        for (i=0; i<8; i=i+1) begin
            assign pixelSum[i] = pixels[i][11:8] + pixels[i][7:4] + pixels[i][3:0];
            Divider6BitBy3 div (pixelSum[i], bwVal[i]);
            assign bwPixels[i] = {bwVal[i][3:0], bwVal[i][3:0], bwVal[i][3:0]};
        end
    endgenerate

    // only actually need the 8 bits bc greyscale
    wire [23:0] hOut;
    wire [23:0] vOut;
    wire [23:0] dlOut;
    wire [23:0] drOut;

    Sobel3x3 sobel3x3 ( .inPixel_lu(bwPixels[0]),
                        .inPixel_lm(bwPixels[1]),
                        .inPixel_ld(bwPixels[2]),
                        .inPixel_mu(bwPixels[3]),
                     // .inPixel_mm(bwPixels[0]),
                        .inPixel_md(bwPixels[4]),
                        .inPixel_ru(bwPixels[5]),
                        .inPixel_rm(bwPixels[6]),
                        .inPixel_rd(bwPixels[7]),
                        .hOut(hOut),
                        .vOut(vOut),
                        .sobelEdge()
    );

    // permute the pixels to get diagonal edges with same filter
    Sobel3x3 diagSob  ( .inPixel_lu(bwPixels[3]),
                        .inPixel_lm(bwPixels[0]),
                        .inPixel_ld(bwPixels[1]),
                        .inPixel_mu(bwPixels[5]),
                     // .inPixel_mm(bwPixels[0]),
                        .inPixel_md(bwPixels[2]),
                        .inPixel_ru(bwPixels[6]),
                        .inPixel_rm(bwPixels[7]),
                        .inPixel_rd(bwPixels[4]),
                        .hOut(dlOut),
                        .vOut(drOut),
                        .sobelEdge()
    );

    wire [3:0] edgeDir = {hOut[7], vOut[7], dlOut[7], drOut[7]};
    wire [6:0] edgeDiffs[3:0];
    assign edgeDiffs[0] = drOut[6:0];
    assign edgeDiffs[1] = dlOut[6:0];
    assign edgeDiffs[2] = vOut[6:0];
    assign edgeDiffs[3] = hOut[6:0];
    
    wire [6:0] maxDD  = (edgeDiffs[0] > edgeDiffs[1]) ? edgeDiffs[0] : edgeDiffs[1];
    wire [6:0] maxTL  = (edgeDiffs[2] > edgeDiffs[3]) ? edgeDiffs[2] : edgeDiffs[3];
    wire [6:0] max    = (maxDD > maxTL) ? maxDD : maxTL;
    wire [6:0] diff   = (maxDD > maxTL) ? (maxDD - maxTL) : (maxTL - maxDD);

    wire [11:0] maxPixel;
    genvar j;
    generate
        for(j=0; j<3; j=j+1) begin
            assign maxPixel[4*(j+1)-1:4*j] = (max > 7'h0F) ? 4'hF : max[3:0];
        end
    endgenerate

    reg [11:0] edgePixel = 12'h000;

    reg [11:0] edgeColorRom [23:0];
    initial begin
        edgeColorRom[0]  = 12'hF00;     // RED 
        edgeColorRom[1]  = 12'hF30;
        edgeColorRom[2]  = 12'hF70;     // ORANGE
        edgeColorRom[3]  = 12'hFB0;
        edgeColorRom[4]  = 12'hFF0;     // YELLOW
        edgeColorRom[5]  = 12'hBF0;
        edgeColorRom[6]  = 12'h7F0;     // LIME
        edgeColorRom[7]  = 12'h3F0;
        edgeColorRom[8]  = 12'h0F0;     // GREEN
        edgeColorRom[9]  = 12'h0F3;
        edgeColorRom[10] = 12'h0F7;     // TURQUOISE
        edgeColorRom[11] = 12'h0FB;
        edgeColorRom[12] = 12'h0FF;     // CYAN
        edgeColorRom[13] = 12'h0BF;
        edgeColorRom[14] = 12'h07F;     // BLUE
        edgeColorRom[15] = 12'h03F;
        edgeColorRom[16] = 12'h00F;     // BLUE
        edgeColorRom[17] = 12'h30F;
        edgeColorRom[18] = 12'h70F;     // VIOLET
        edgeColorRom[19] = 12'hB0F;
        edgeColorRom[20] = 12'hF0F;     // MAGENTA
        edgeColorRom[21] = 12'hF0B;
        edgeColorRom[22] = 12'hF07;     // RED-MAGENTA
        edgeColorRom[23] = 12'hF03;
    end
    
    
    genvar k;
    wire [4:0] colorIdx [23:0];
    generate
        for (k=0; k<24; k=k+1) begin
            assign colorIdx[k] = (k + colorShift <= 23) ? k + colorShift : (k + colorShift) - 23;
        end
    endgenerate

    always@(*) begin
        if (max > 7'h00) begin
            if (max == edgeDiffs[0]) begin /////////// upleft -> downright /////
                if(edgeDir[0])
                    if (diff < edgeThresh)
                        if (maxTL == edgeDiffs[2])  // upish
                            edgePixel <= edgeColorRom[colorIdx[22]];
                        else                        // leftish
                            edgePixel <= edgeColorRom[colorIdx[20]];
                    else
                        edgePixel <= edgeColorRom[colorIdx[21]];       // upleft
                else
                    if (diff < edgeThresh)
                        if (maxTL == edgeDiffs[2])  // downish
                            edgePixel <= edgeColorRom[colorIdx[10]];
                        else                        // rightish
                            edgePixel <= edgeColorRom[colorIdx[8]];
                    else
                        edgePixel <= edgeColorRom[colorIdx[9]];       // downright
            end else if (max == edgeDiffs[1]) begin // upright -> downleft /////
                if(edgeDir[1])
                    if (diff < edgeThresh)
                        if (maxTL == edgeDiffs[2])  // upish
                            edgePixel <= edgeColorRom[colorIdx[2]];
                        else                        // rightish
                            edgePixel <= edgeColorRom[colorIdx[4]];
                    else
                        edgePixel <= edgeColorRom[colorIdx[3]];   //dl -- Orange      - yellowish
                else
                    if (diff < edgeThresh)
                        if (maxTL == edgeDiffs[2])  // downish
                            edgePixel <= edgeColorRom[colorIdx[14]];
                        else                        // leftish
                            edgePixel <= edgeColorRom[colorIdx[16]];
                    else
                        edgePixel <= edgeColorRom[colorIdx[15]];   //ul -- Blue        - cyanish                    
            end else if (max == edgeDiffs[2]) begin // up -> down //////////////
                if(edgeDir[2])
                    if (diff < edgeThresh)
                        if (maxDD == edgeDiffs[0])  
                            edgePixel <= edgeColorRom[colorIdx[23]];   // leftish
                        else
                            edgePixel <= edgeColorRom[colorIdx[1]];   // rightish
                    else
                        edgePixel <= edgeColorRom[colorIdx[0]];   //u -- red
                else
                    if (diff < edgeThresh)
                        if (maxDD == edgeDiffs[0])
                            edgePixel <= edgeColorRom[colorIdx[11]];   // rightish
                        else
                            edgePixel <= edgeColorRom[colorIdx[13]];   // leftish
                    else
                        edgePixel <= edgeColorRom[colorIdx[12]];   //d -- cyan
            end else begin /////////////////////////////////////////////////////
                if (edgeDir[3])
                    if (diff < edgeThresh)
                        if (maxDD == edgeDiffs[0])  
                            edgePixel <= edgeColorRom[colorIdx[5]];   // downish
                        else
                            edgePixel <= edgeColorRom[colorIdx[7]];   // upish
                    else
                        edgePixel <= edgeColorRom[colorIdx[6]];   //l -- lime
                else
                    if (diff < edgeThresh)
                        if (maxDD == edgeDiffs[0])  
                            edgePixel <= edgeColorRom[colorIdx[19]];   // downish
                        else
                            edgePixel <= edgeColorRom[colorIdx[17]];   // upish
                    else
                        edgePixel <= edgeColorRom[colorIdx[18]];   //r -- violet
            end
        end else
            edgePixel <= 12'h000;
    end

    // And these together to keep intensity information.
    assign sobelEdge = (gradMax) ? edgePixel : edgePixel & maxPixel;
endmodule
