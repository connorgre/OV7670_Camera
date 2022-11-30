`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/29/2022 08:54:21 PM
// Design Name: 
// Module Name: Sobel3x3
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


module Sobel3x3(
    input [11:0]  inPixel_lu,
    input [11:0]  inPixel_lm,
    input [11:0]  inPixel_ld,
    input [11:0]  inPixel_mu,
  //input [11:0]  inPixel_mm,
    input [11:0]  inPixel_md,
    input [11:0]  inPixel_ru,
    input [11:0]  inPixel_rm,
    input [11:0]  inPixel_rd,

    output [11:0] sobelEdge
    );

    wire [17:0] lCol;
    wire [17:0] rCol;
    wire [17:0] uRow;
    wire [17:0] dRow;
    
    wire [14:0] sobelSum;
    wire [20:0] colSum;
    wire [20:0] rowSum;
    
    wire [2:0] lGt, uGt;
    wire [2:0] sGt;
    genvar i;
    generate
        for(i=0; i < 3; i=i+1) begin    // * 1                        *2                                 *1
            // vertical edges
            assign lCol[6*(i+1)-1:6*i] = inPixel_lu[4*(i+1)-1:4*i] + {inPixel_lm[4*(i+1)-1:4*i], 1'b0} + inPixel_ld[4*(i+1)-1:4*i];
            assign rCol[6*(i+1)-1:6*i] = inPixel_ru[4*(i+1)-1:4*i] + {inPixel_rm[4*(i+1)-1:4*i], 1'b0} + inPixel_rd[4*(i+1)-1:4*i];
            // horizontal edges
            assign uRow[6*(i+1)-1:6*i] = inPixel_lu[4*(i+1)-1:4*i] + {inPixel_mu[4*(i+1)-1:4*i], 1'b0} + inPixel_ru[4*(i+1)-1:4*i];
            assign dRow[6*(i+1)-1:6*i] = inPixel_ld[4*(i+1)-1:4*i] + {inPixel_md[4*(i+1)-1:4*i], 1'b0} + inPixel_rd[4*(i+1)-1:4*i];
            
            assign lGt[i] = (lCol[6*(i+1)-1:6*i] > rCol[6*(i+1)-1:6*i]);
            assign uGt[i] = (uRow[6*(i+1)-1:6*i] > dRow[6*(i+1)-1:6*i]);
            
            assign colSum[7*(i+1)-1:7*i] = (lGt[i]) ? (lCol[6*(i+1)-1:6*i] - rCol[6*(i+1)-1:6*i]) : (rCol[6*(i+1)-1:6*i] - lCol[6*(i+1)-1:6*i]);
            assign rowSum[7*(i+1)-1:7*i] = (uGt[i]) ? (uRow[6*(i+1)-1:6*i] - dRow[6*(i+1)-1:6*i]) : (dRow[6*(i+1)-1:6*i] - uRow[6*(i+1)-1:6*i]);
            
            assign sGt[i] = (colSum[7*(i+1)-1:7*i] > 7'h0F) || (rowSum[7*(i+1)-1:7*i] > 7'h0F);
            
            assign sobelSum[5*(i+1)-1:5*i] = (sGt[i]) ? 5'h1F : colSum[4*(i+1)-1:4*i] + rowSum[4*(i+1)-1:4*i];
            assign sobelEdge[4*(i+1)-1:4*i] = /*(sobelSum[5*(i+1)-1]) ? 4'hF :*/ sobelSum[5*(i+1)-2:5*i];
        end
    endgenerate
endmodule
