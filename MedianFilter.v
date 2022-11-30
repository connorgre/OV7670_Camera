`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/28/2022 10:22:11 PM
// Design Name: 
// Module Name: MedianFilter
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

// contains 4 extra clocks.
module MedianFilter(
    input         readClk,
    input         useMedian,
    input [11:0]  inPixel_lu,
    input [11:0]  inPixel_lm,
    input [11:0]  inPixel_ld,
    input [11:0]  inPixel_mu,
    input [11:0]  inPixel_mm,
    input [11:0]  inPixel_md,
    input [11:0]  inPixel_ru,
    input [11:0]  inPixel_rm,
    input [11:0]  inPixel_rd,
    
    output [11:0] medOut
    );
    
    reg  [11:0] origPix [4:0];
    wire [3:0] numR ['hF:0];
    wire [3:0] numG ['hF:0];
    wire [3:0] numB ['hF:0];
    
    genvar i;
    generate
        for(i=0; i < 'hF; i=i+1) begin
            assign numR[i] =    (inPixel_lu[11:8] == i) + 
                                (inPixel_lm[11:8] == i) + 
                                (inPixel_ld[11:8] == i) + 
                                (inPixel_mu[11:8] == i) + 
                                (inPixel_mm[11:8] == i) + 
                                (inPixel_md[11:8] == i) + 
                                (inPixel_ru[11:8] == i) + 
                                (inPixel_rm[11:8] == i) + 
                                (inPixel_rd[11:8] == i);

            assign numG[i] =    (inPixel_lu[7:4] == i) + 
                                (inPixel_lm[7:4] == i) + 
                                (inPixel_ld[7:4] == i) + 
                                (inPixel_mu[7:4] == i) + 
                                (inPixel_mm[7:4] == i) + 
                                (inPixel_md[7:4] == i) + 
                                (inPixel_ru[7:4] == i) + 
                                (inPixel_rm[7:4] == i) + 
                                (inPixel_rd[7:4] == i);

            assign numB[i] =    (inPixel_lu[3:0] == i) + 
                                (inPixel_lm[3:0] == i) + 
                                (inPixel_ld[3:0] == i) + 
                                (inPixel_mu[3:0] == i) + 
                                (inPixel_mm[3:0] == i) + 
                                (inPixel_md[3:0] == i) + 
                                (inPixel_ru[3:0] == i) + 
                                (inPixel_rm[3:0] == i) + 
                                (inPixel_rd[3:0] == i);
        end
    endgenerate
    
    reg [3:0] numRreg ['hF:0];
    reg [3:0] numGreg ['hF:0];
    reg [3:0] numBreg ['hF:0];
    integer j;
    always@(posedge readClk) begin
        origPix[0] <= inPixel_mm;
        for (j=0; j < 'hF; j=j+1) begin
            numRreg[j] <= numR[j];
            numGreg[j] <= numG[j];
            numBreg[j] <= numB[j];
        end
    end
    
    wire [3:0] totR1 ['hF:0];
    wire [3:0] totG1 ['hF:0];
    wire [3:0] totB1 ['hF:0];
    
    assign totR1[0] = numRreg[0];
    assign totG1[0] = numGreg[0];
    assign totB1[0] = numBreg[0];
    
    assign totR1[4] = numRreg[4];
    assign totG1[4] = numGreg[4];
    assign totB1[4] = numBreg[4];
    
    assign totR1[8] = numRreg[8];
    assign totG1[8] = numGreg[8];
    assign totB1[8] = numBreg[8];
    
    assign totR1[12] = numRreg[12];
    assign totG1[12] = numGreg[12];
    assign totB1[12] = numBreg[12];
    genvar k;
    generate
        for(k=1; k<'h4; k=k+1) begin
            assign totR1[k]    = totR1[k-1]    + numRreg[k];
            assign totG1[k]    = totG1[k-1]    + numGreg[k];
            assign totB1[k]    = totB1[k-1]    + numBreg[k];
            assign totR1[k+4]  = totR1[k+4-1]  + numRreg[k+4];
            assign totG1[k+4]  = totG1[k+4-1]  + numGreg[k+4];
            assign totB1[k+4]  = totB1[k+4-1]  + numBreg[k+4];
            assign totR1[k+8]  = totR1[k+8-1]  + numRreg[k+8];
            assign totG1[k+8]  = totG1[k+8-1]  + numGreg[k+8];
            assign totB1[k+8]  = totB1[k+8-1]  + numBreg[k+8];
            assign totR1[k+12] = totR1[k+12-1] + numRreg[k+12];
            assign totG1[k+12] = totG1[k+12-1] + numGreg[k+12];
            assign totB1[k+12] = totB1[k+12-1] + numBreg[k+12];
        end
    endgenerate
    
    reg [3:0] totRreg1 ['hF:0];
    reg [3:0] totGreg1 ['hF:0];
    reg [3:0] totBreg1 ['hF:0];
    
    reg [3:0] totRreg ['hF:0];
    reg [3:0] totGreg ['hF:0];
    reg [3:0] totBreg ['hF:0];
    
    integer m;  
    always@(posedge readClk) begin
        origPix[1] <= origPix[0];
        for (m=0; m < 'hF; m=m+1) begin
            totRreg1[m] <= totR1[m];
            totGreg1[m] <= totG1[m];
            totBreg1[m] <= totB1[m];
        end
    end
    
    wire [3:0] totR ['hF:0];
    wire [3:0] totG ['hF:0];
    wire [3:0] totB ['hF:0];
    genvar n;
    generate
        for(n=0; n<4; n=n+1) begin
            assign totR[n] = totRreg1[n];
            assign totG[n] = totGreg1[n];
            assign totB[n] = totBreg1[n];
        end
        for(n=4; n<8; n=n+1) begin
            assign totR[n] = totRreg1[n]  + totRreg1[3];
            assign totG[n] = totGreg1[n]  + totGreg1[3];
            assign totB[n] = totBreg1[n]  + totBreg1[3];
        end
        for(n=8; n<12; n=n+1) begin
            assign totR[n] = totRreg1[n]  + totRreg1[7] + totRreg1[3];
            assign totG[n] = totGreg1[n]  + totGreg1[7] + totGreg1[3];
            assign totB[n] = totBreg1[n]  + totBreg1[7] + totBreg1[3];
        end
        for(n=12; n<16; n=n+1) begin
            assign totR[n] = totRreg1[n]  + totRreg1[11] + totRreg1[7] + totRreg1[3];
            assign totG[n] = totGreg1[n]  + totGreg1[11] + totGreg1[7] + totGreg1[3];
            assign totB[n] = totBreg1[n]  + totBreg1[11] + totBreg1[7] + totBreg1[3];
        end
    endgenerate
    
    integer o;
    always@(posedge readClk) begin
        origPix[2] <= origPix[1];
        for (o=0; o < 'hF; o=o+1) begin
            totRreg[o] <= totR[o];
            totGreg[o] <= totG[o];
            totBreg[o] <= totB[o];
        end
    end
    
    wire [3:0] medR1;
    wire [3:0] medG1;
    wire [3:0] medB1;
    
    assign medR1 =  (totRreg[0]  > 4'h4) ? 4'h0 :
                    (totRreg[1]  > 4'h4) ? 4'h1 :
                    (totRreg[2]  > 4'h4) ? 4'h2 :
                    (totRreg[3]  > 4'h4) ? 4'h3 :
                    (totRreg[4]  > 4'h4) ? 4'h4 :
                    (totRreg[5]  > 4'h4) ? 4'h5 :
                    (totRreg[6]  > 4'h4) ? 4'h6 :
                    (totRreg[7]  > 4'h4) ? 4'h7 : 4'hF;
                    
                    
                    
    assign medG1 =  (totGreg[0]  > 4'h4) ? 4'h0 :
                    (totGreg[1]  > 4'h4) ? 4'h1 :
                    (totGreg[2]  > 4'h4) ? 4'h2 :
                    (totGreg[3]  > 4'h4) ? 4'h3 :
                    (totGreg[4]  > 4'h4) ? 4'h4 :
                    (totGreg[5]  > 4'h4) ? 4'h5 :
                    (totGreg[6]  > 4'h4) ? 4'h6 :
                    (totGreg[7]  > 4'h4) ? 4'h7 : 4'hF;
                    
                    
                    
    assign medB1 =  (totBreg[0]  > 4'h4) ? 4'h0 :
                    (totBreg[1]  > 4'h4) ? 4'h1 :
                    (totBreg[2]  > 4'h4) ? 4'h2 :
                    (totBreg[3]  > 4'h4) ? 4'h3 :
                    (totBreg[4]  > 4'h4) ? 4'h4 :
                    (totBreg[5]  > 4'h4) ? 4'h5 :
                    (totBreg[6]  > 4'h4) ? 4'h6 :
                    (totBreg[7]  > 4'h4) ? 4'h7 : 4'hF;
                    
                    
    
    reg [3:0] medRreg;
    reg [3:0] medGreg;
    reg [3:0] medBreg;
    
    reg [3:0] totRreg2 [6:0];
    reg [3:0] totGreg2 [6:0];
    reg [3:0] totBreg2 [6:0];
    
    integer p;
    always@(posedge readClk) begin
        origPix[3] <= origPix[2];
        medRreg <= medR1;
        medGreg <= medG1;
        medBreg <= medB1;

        for (p=0; p < 7; p=p+1) begin
            totRreg2[p] <= totRreg[8+p];
            totGreg2[p] <= totGreg[8+p];
            totBreg2[p] <= totBreg[8+p];
        end
    end
    
    wire [3:0] medR;
    wire [3:0] medG;
    wire [3:0] medB;
    
    assign medR =   (medRreg != 4'hF)     ? medRreg : 
                    (totRreg2[0]  > 4'h4) ? 4'h8 :
                    (totRreg2[1]  > 4'h4) ? 4'h9 :
                    (totRreg2[2] > 4'h4) ? 4'hA :
                    (totRreg2[3] > 4'h4) ? 4'hB :
                    (totRreg2[4] > 4'h4) ? 4'hC :
                    (totRreg2[5] > 4'h4) ? 4'hD :
                    (totRreg2[6] > 4'h4) ? 4'hE : 4'hF;
                    
    assign medG =   (medGreg != 4'hF)     ? medGreg :
                    (totGreg2[0]  > 4'h4) ? 4'h8 :
                    (totGreg2[1]  > 4'h4) ? 4'h9 :
                    (totGreg2[2] > 4'h4) ? 4'hA :
                    (totGreg2[3] > 4'h4) ? 4'hB :
                    (totGreg2[4] > 4'h4) ? 4'hC :
                    (totGreg2[5] > 4'h4) ? 4'hD :
                    (totGreg2[6] > 4'h4) ? 4'hE : 4'hF;
                    
    assign medB =   (medBreg != 4'hF)     ? medBreg :
                    (totBreg2[0]  > 4'h4) ? 4'h8 :
                    (totBreg2[1]  > 4'h4) ? 4'h9 :
                    (totBreg2[2] > 4'h4) ? 4'hA :
                    (totBreg2[3] > 4'h4) ? 4'hB :
                    (totBreg2[4] > 4'h4) ? 4'hC :
                    (totBreg2[5] > 4'h4) ? 4'hD :
                    (totBreg2[6] > 4'h4) ? 4'hE : 4'hF;

    reg [11:0] medPix;
    always@(posedge readClk) begin
        origPix[4] <= origPix[3];
        medPix <= {medR, medG, medB};
    end

    assign medOut = (useMedian) ? medPix : origPix[4];
endmodule
