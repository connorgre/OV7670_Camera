`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/28/2022 04:21:47 PM
// Design Name: 
// Module Name: fuzzy_vec
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


module fuzzy_vec#(parameter bit = 4)(clk, rst, z1, z2, z3, z4, z5, z6, z7, z8, z9, D1_vec, D2_vec, D3_vec, D4_vec);
    reg [7:0] pixels [10:0][0:20];
    input [7:0] z1, z2, z3, z4, z5, z6, z7, z8, z9;
    input clk, rst;
    output [23:0] D1_vec, D2_vec, D3_vec, D4_vec;
    
    reg [bit-1:0] D1, D2, D3, D4;
    // need to have an input binary file here to fill out pixels
    //just testing for now
    integer i,j;
    reg [7:0] cnt = 8'hf0;
    reg set_initial; // to help set initial value for low high
    
    always @(*) begin
        for(i = 0; i <= 10; i = i + 1) begin
            for(j = 0; j <= 20; j = j + 1) begin
                pixels[i][j] <= cnt;
                cnt = cnt + 1;
                if (cnt == 8'hff) cnt = 8'h00;
            end
        end 
    end
    
    // now try to use a state machine
    reg [7:0] z [0:8]; //have 9 zs and each z has 8 bits
    reg [7:0] D1_a, D1_b, D2_a, D2_b, D3_a, D3_b, D4_a, D4_b;
    reg [7:0] D1_temp, D2_temp, D3_temp, D4_temp;

    localparam [1:0]
        //idle = 2'b00,
        calculate = 2'b00,
        compare = 2'b01;
    reg [1:0] state, state_next;
    always @(posedge clk) begin
        if(rst) begin
            D1 <= 8'b0;
            D2 <= 8'b0;
            D3 <= 8'b0;
            D4 <= 8'b0;
            state <= calculate;
            set_initial <= 0;
        end
        else state <= state_next;

    end

    reg [7:0] dlow1, dhigh1, dlow2, dhigh2, dlow3, dhigh3, dlow4, dhigh4;
    wire [7:0] dmid1, dmid2, dmid3, dmid4;
    reg init = 0;
    always @(*) begin
        case(state)
            calculate: begin
                D1_a = (z5 >= z2) ? (z5 - z2):(z2 - z5);
                D1_b = (z8 >= z5) ? (z8 - z5):(z5 - z8);
                D1   = D1_a + D1_b;
                D2_a = (z5 >= z4) ? (z5 - z4):(z4 - z5);
                D2_b = (z6 >= z5) ? (z6 - z5):(z5 - z6);
                D2   = D2_a + D2_b;
                D3_a = (z5 >= z1) ? (z5 - z1):(z1 - z5);
                D3_b = (z9 >= z5) ? (z9 - z5):(z5 - z9);
                D3   = D3_a + D3_b;               
                D4_a = (z5 >= z3) ? (z5 - z3):(z3 - z5);
                D4_b = (z7 >= z5) ? (z7 - z5):(z5 - z7);
                D4   = D4_a + D4_b;

                if (init == 0) begin
                    dlow1  = D1;
                    dhigh1 = D1;
                    dlow2  = D2;
                    dhigh2 = D2;
                    dlow3  = D3;
                    dhigh3 = D3;
                    dlow4  = D4;
                    dhigh4 = D4;
                end

                state_next = compare;
            end
            compare: begin
                init = 1;
                dlow1  = (dlow1 <= D1) ? dlow1  : D1;
                dhigh1 = (dhigh1 > D1) ? dhigh1 : D1;
                dlow2  = (dlow2 <= D2) ? dlow2  : D2;
                dhigh2 = (dhigh2 > D2) ? dhigh2 : D2;
                dlow3  = (dlow3 <= D3) ? dlow3  : D3;
                dhigh3 = (dhigh3 > D3) ? dhigh3 : D3;
                dlow4  = (dlow4 <= D4) ? dlow4  : D4;
                dhigh4 = (dhigh4 > D4) ? dhigh4 : D4;

                state_next = calculate;
            end
            default: state_next = calculate;
        endcase
    end
    assign dmid1 = dlow1 + (dhigh1 - dlow1)/2;
    assign dmid2 = dlow2 + (dhigh2 - dlow2)/2;
    assign dmid3 = dlow3 + (dhigh3 - dlow3)/2;
    assign dmid4 = dlow4 + (dhigh4 - dlow4)/2;

    assign D1_vec = {dhigh1, dmid1, dlow1};
    assign D2_vec = {dhigh2, dmid2, dlow2};
    assign D3_vec = {dhigh3, dmid3, dlow3};
    assign D4_vec = {dhigh4, dmid4, dlow4};


endmodule
