`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2022 06:52:33 PM
// Design Name: 
// Module Name: fuzzy_val
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


module fuzzy_val(
    input [7:0] D,
    output [9:0] min,
    output [9:0] mid,
    output [9:0] max
    );
    
    assign min = (D < (1<<7)) ? -(D<<1) + (1<<8) : 0               ;  
    assign max = (D > (1<<7)) ?  (D<<1) - (1<<8) : 0               ;
    assign mid = (D < (1<<7)) ?  (D<<1)          : -(D<<1) + (1<<9); 
    
endmodule


