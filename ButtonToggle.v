`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/22/2022 02:29:56 PM
// Design Name: 
// Module Name: ButtonToggle
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


module ButtonToggle(
    input btnIn,
    input clk,
    output reg toggleOut = 0
    );
    
    wire btnPressed;
    Debouncer btnDeb(btnIn, clk, btnPressed);
    
    always@(posedge btnPressed)
        toggleOut <= ~toggleOut;
    
endmodule
