`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2022 01:04:55 PM
// Design Name: 
// Module Name: TrueAverage
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


module TrueAverage3x3(
    input [11:0]  inPixel_lu,
    input [11:0]  inPixel_lm,
    input [11:0]  inPixel_ld,
    input [11:0]  inPixel_mu,
    input [11:0]  inPixel_mm,
    input [11:0]  inPixel_md,
    input [11:0]  inPixel_ru,
    input [11:0]  inPixel_rm,
    input [11:0]  inPixel_rd,
    
    output [11:0] blurredPixel
    );
    
    wire [17:0] topRow;
    wire [17:0] midRow;
    wire [17:0] botRow;
    wire [11:0] topAve;
    wire [11:0] midAve;
    wire [11:0] botAve;
    
    wire [17:0] aveSum;

    wire [11:0] average;
    genvar i;
    generate
        for (i=0; i<3; i=i+1) begin
            assign topRow[6*(i+1)-1:6*i] = inPixel_lu[4*(i+1)-1:4*i] + inPixel_mu[4*(i+1)-1:4*i] + inPixel_ru[4*(i+1)-1:4*i];
            assign midRow[6*(i+1)-1:6*i] = inPixel_lm[4*(i+1)-1:4*i] + inPixel_mm[4*(i+1)-1:4*i] + inPixel_rm[4*(i+1)-1:4*i];
            assign botRow[6*(i+1)-1:6*i] = inPixel_ld[4*(i+1)-1:4*i] + inPixel_md[4*(i+1)-1:4*i] + inPixel_rd[4*(i+1)-1:4*i];
            
            Divider6BitBy3 (topRow[6*(i+1)-1:6*i], topAve[4*(i+1)-1:4*i]);
            Divider6BitBy3 (midRow[6*(i+1)-1:6*i], midAve[4*(i+1)-1:4*i]);
            Divider6BitBy3 (botRow[6*(i+1)-1:6*i], botAve[4*(i+1)-1:4*i]);
            
            assign aveSum[6*(i+1)-1:6*i] = topAve[4*(i+1)-1:4*i] + midAve[4*(i+1)-1:4*i] + botAve[4*(i+1)-1:4*i];
            
            Divider6BitBy3 (aveSum[6*(i+1)-1:6*i], average[4*(i+1)-1:4*i]);
        end
    endgenerate
    
    assign blurredPixel = average;
    
endmodule
