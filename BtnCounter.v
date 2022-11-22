`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/22/2022 04:21:48 PM
// Design Name: 
// Module Name: BtnCounter
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


module BtnCounter(
    input btnIn,
    input clk,
    
    output [2**maxCnt-1:0] cnt
    );
    parameter maxCnt;
endmodule
