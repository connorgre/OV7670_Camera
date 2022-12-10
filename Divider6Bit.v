`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2022 08:17:12 PM
// Design Name: 
// Module Name: Divider6Bit
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


module Divider6BitBy3(
    input [5:0] in,
    output reg [4:0] out
    );
    always@(in) begin
        case(in)
            6'h0:  out <= 5'h0;
            6'h1:  out <= 5'h0;
            6'h2:  out <= 5'h0;
            6'h3:  out <= 5'h1;
            6'h4:  out <= 5'h1;
            6'h5:  out <= 5'h1;
            6'h6:  out <= 5'h2;
            6'h7:  out <= 5'h2;
            6'h8:  out <= 5'h2;
            6'h9:  out <= 5'h3;
            6'ha:  out <= 5'h3;
            6'hb:  out <= 5'h3;
            6'hc:  out <= 5'h4;
            6'hd:  out <= 5'h4;
            6'he:  out <= 5'h4;
            6'hf:  out <= 5'h5;
            6'h10: out <= 5'h5;
            6'h11: out <= 5'h5;
            6'h12: out <= 5'h6;
            6'h13: out <= 5'h6;
            6'h14: out <= 5'h6;
            6'h15: out <= 5'h7;
            6'h16: out <= 5'h7;
            6'h17: out <= 5'h7;
            6'h18: out <= 5'h8;
            6'h19: out <= 5'h8;
            6'h1a: out <= 5'h8;
            6'h1b: out <= 5'h9;
            6'h1c: out <= 5'h9;
            6'h1d: out <= 5'h9;
            6'h1e: out <= 5'ha;
            6'h1f: out <= 5'ha;
            6'h20: out <= 5'ha;
            6'h21: out <= 5'hb;
            6'h22: out <= 5'hb;
            6'h23: out <= 5'hb;
            6'h24: out <= 5'hc;
            6'h25: out <= 5'hc;
            6'h26: out <= 5'hc;
            6'h27: out <= 5'hd;
            6'h28: out <= 5'hd;
            6'h29: out <= 5'hd;
            6'h2a: out <= 5'he;
            6'h2b: out <= 5'he;
            6'h2c: out <= 5'he;
            6'h2d: out <= 5'hf;
            6'h2e: out <= 5'hf;
            6'h2f: out <= 5'hf;
            6'h30: out <= 5'h10;
            6'h31: out <= 5'h10;
            6'h32: out <= 5'h10;
            6'h33: out <= 5'h11;
            6'h34: out <= 5'h11;
            6'h35: out <= 5'h11;
            6'h36: out <= 5'h12;
            6'h37: out <= 5'h12;
            6'h38: out <= 5'h12;
            6'h39: out <= 5'h13;
            6'h3a: out <= 5'h13;
            6'h3b: out <= 5'h13;
            6'h3c: out <= 5'h14;
            6'h3d: out <= 5'h14;
            6'h3e: out <= 5'h14;
            6'h3f: out <= 5'h15;
        endcase
    end
endmodule
