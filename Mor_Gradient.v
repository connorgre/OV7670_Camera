`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/28/2022 05:11:49 PM
// Design Name: 
// Module Name: Mor_Gradient
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Morphological Gradient
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Mor_Gradient#(parameter bit = 4)(clk, rst, z1, z2, z3, z4, z5, z6, z7, z8, z9, S, D1, D2, D3, D4, done);
    // usually grayscale image has 8 to 24 bits per pixel
    //color image has 24 bits per pixel
    input [7:0] z1, z2, z3, z4, z5, z6, z7, z8, z9;
    input clk, rst;
    output reg [bit-1:0] S;
    output reg done; //reg to indicate MG done
    output [7:0] D1, D2, D3, D4;
    
    reg [bit-1:0] D1, D2, D3, D4;

    // now try to use a state machine
    reg [7:0] z [0:8]; //have 9 zs and each z has 8 bits
    reg [7:0] D1_a, D1_b, D2_a, D2_b, D3_a, D3_b, D4_a, D4_b;
    reg [7:0] D1_temp, D2_temp, D3_temp, D4_temp;
    
    localparam [1:0]
        //idle = 2'b00,
        calculate = 2'b00,
        done_state = 2'b01;
        //check_edge = 2'b10;
    reg state, state_next;
    always @(posedge clk) begin
        if(rst) begin
            state <= calculate;
        end
        else state <= state_next;

    end

    reg [7:0] dlow1, dhigh1, dlow2, dhigh2, dlow3, dhigh3, dlow4, dhigh4;
    wire [7:0] dmid1, dmid2, dmid3, dmid4;
    always @(*) begin
        if (rst) begin
            D1   = 8'b0;
            D2   = 8'b0;
            D3   = 8'b0;
            D4   = 8'b0;
            S    = 8'b0;
            done = 0;
        end
        case(state)
            calculate: begin
                done = 0;
                D1_a = (z5 >= z2) ? (z5 - z2):(z2 - z5);
                D1_b = (z8 >= z5) ? (z8 - z5):(z5 - z8);
                D1 = D1_a + D1_b;
                D2_a = (z5 >= z4) ? (z5 - z4):(z4 - z5);
                D2_b = (z6 >= z5) ? (z6 - z5):(z5 - z6);
                D2 = D2_a + D2_b;
                D3_a = (z5 >= z1) ? (z5 - z1):(z1 - z5);
                D3_b = (z9 >= z5) ? (z9 - z5):(z5 - z9);
                D3 = D3_a + D3_b;               
                D4_a = (z5 >= z3) ? (z5 - z3):(z3 - z5);
                D4_b = (z7 >= z5) ? (z7 - z5):(z5 - z7);
                D4 = D4_a + D4_b;
                
                S = D1 + D2 + D3 + D4;
                state_next = done_state;
            end
            done_state: begin
                done = 1;
                state_next = calculate;
            end
            default: state = calculate;
        endcase
    end

endmodule

