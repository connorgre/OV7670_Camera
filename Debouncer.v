`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2022 07:11:13 PM
// Design Name: 
// Module Name: Debouncer
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

// debounces after .25s if 25Mhz clock given
module Debouncer(
    input btnIn,
    input clk,
    
    output reg btnDown = 0
    );
    
    reg [19:0] btnCounter = 20'h0_0000;
    
    always@(posedge clk) begin
        if (btnIn) begin
            btnCounter <= 20'hF_FFFF;
            btnDown = 1;
        end else begin
            if (btnCounter > 20'h0_0000)
                btnCounter <= btnCounter - 1;
            else
                btnDown = 0;
        end
    end
    
    
endmodule
