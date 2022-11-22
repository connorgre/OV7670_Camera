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
    input btnc,
    input clk25,
    
    output reg btncDown = 0
    );
    
    reg [23:0] btncCounter = 24'h00_0000;
    
    always@(posedge clk25) begin
        if (btnc) begin
            btncCounter <= 24'hFF_FFFF;
            btncDown = 1;
        end else begin
            if (btncCounter > 24'h00_0000)
                btncCounter <= btncCounter - 1;
            else
                btncDown = 0;
        end
    end
    
    
endmodule
