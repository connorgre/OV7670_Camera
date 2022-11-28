`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2022 03:40:59 PM
// Design Name: 
// Module Name: PopCnt9
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


module PopCnt9(
    input [8:0]  in,
    output [3:0] cnt
    );
    
    assign cnt = {3'h0, in[8]} + 
                 {3'h0, in[7]} + 
                 {3'h0, in[6]} + 
                 {3'h0, in[5]} + 
                 {3'h0, in[4]} + 
                 {3'h0, in[3]} + 
                 {3'h0, in[2]} + 
                 {3'h0, in[1]} + 
                 {3'h0, in[0]};
endmodule
