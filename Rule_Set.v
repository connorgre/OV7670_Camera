`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/02/2022 04:34:27 PM
// Design Name: 
// Module Name: Rule_Set
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

// this is fuzzy rule set for inference part
// have Di low med high results and send them to the mor gradient to find if S is the edge
module Rule_Set(clk, rst, z1, z2, z3, z4, z5, z6, z7, z8, z9, edge_pixel, EDGE, DONE);
    input clk, rst;
    //input [7:0] pixel_x, pixel_y;
    input [7:0] z1, z2, z3, z4, z5, z6, z7, z8, z9;
    output reg EDGE, DONE;
    output [7:0] edge_pixel;
    //[23:16] high, [15:8] med, [7:0] low
    
   // reg [7:0] pixels [10:0][0:20]; // have pixels stored here
    
    wire [7:0] LM1, MH1, LM2, MH2, LM3, MH3, LM4, MH4;
    
    
    wire [23:0] D1_vec, D2_vec, D3_vec, D4_vec;
    wire done;
    wire [7:0] S,D1, D2, D3, D4;
    Mor_Gradient MG(clk, rst, z1, z2, z3, z4, z5, z6, z7, z8, z9, S, D1, D2, D3, D4, done);
    
    fuzzy_vec FV(clk, rst, z1, z2, z3, z4, z5, z6, z7, z8, z9, D1_vec, D2_vec, D3_vec, D4_vec);
    
    assign LM1 = (D1_vec[7:0]  + D1_vec[15:8]) / 2;
    assign LM2 = (D2_vec[7:0]  + D2_vec[15:8]) / 2;
    assign LM3 = (D3_vec[7:0]  + D3_vec[15:8]) / 2;
    assign LM4 = (D4_vec[7:0]  + D4_vec[15:8]) / 2;
    assign MH1 = (D1_vec[15:8] + D1_vec[23:16]) / 2;
    assign MH2 = (D2_vec[15:8] + D2_vec[23:16]) / 2;
    assign MH3 = (D3_vec[15:8] + D3_vec[23:16]) / 2;
    assign MH4 = (D4_vec[15:8] + D4_vec[23:16]) / 2;
    
    localparam [1:0]
        check_edge = 2'b00,
        done_state = 2'b01;
    reg [1:0] state, state_next;
    always @(posedge clk) begin
        if(rst) begin
            state <= check_edge;
        end
        else state <= state_next;
    end
    
    always @(*) begin
        case(state)
            check_edge: begin
                DONE = 0;
                if((D1 >= MH1) || (D2 >= MH2) || (D3 >= MH3) || (D4 >= MH4)) begin 
                    EDGE = 1;
                end
                else if((D1 < MH1 && D1 >= LM1) || (D2 < MH2 && D2 >= LM2) || (D3 < MH3 && D3 >= LM3) || (D4 < MH4 && D4 >= LM4)) begin
                    EDGE = 1;
                end
                else EDGE = 0;
                state_next = done_state;
            end
            done_state: begin
                EDGE = 0;
                DONE = 1;
                //state_next = check_edge;
            end
            default: state_next = check_edge;
        endcase
    end
    assign edge_pixel = S;
endmodule
