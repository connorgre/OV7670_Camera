`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/02/2022 04:05:56 PM
// Design Name: 
// Module Name: MG_total
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


module MG_total#(parameter pixel_x = 640, parameter pixel_y = 480)(clk, D1_array, D2_array, D3_array, D4_array, S_array);
    input clk;
    //wire length = (pixel_x - 2)*(pixel_y - 2);
    output reg [304963:0] D1_array;
    output reg [304963:0] D2_array;
    output reg [304963:0] D3_array;
    output reg [304963:0] D4_array;
    output reg [304963:0] S_array;
    
    reg D1, D2, D3, D4, S;
    // have a file to read and transfer it into the 2d array
    reg pixels [pixel_x-1:0][pixel_y-1:0];
    
    
    reg [8:0] z;
    reg D1_a, D1_b, D2_a, D2_b, D3_a, D3_b, D4_a, D4_b;
    integer i,j;
    integer k = 0; 
    always @(posedge clk) begin
        for(i = 1; i < pixel_x - 1; i = i + 1) begin
            for(j = 1; j < pixel_y - 1; j = j + 1) begin
                z[0] <= pixels[i - 1][j - 1];
                z[1] <= pixels[i][j - 1];
                z[2] <= pixels[i + 1][j - 1];
                z[3] <= pixels[i - 1][j];
                z[4] <= pixels[i][j];
                z[5] <= pixels[i + 1][j];
                z[6] <= pixels[i - 1][j + 1];
                z[7] <= pixels[i][j + 1];
                z[8] <= pixels[i + 1][j + 1];
                
                
                D1_a = (z[4] >= z[0]) ? (z[4] - z[0]):(z[0] - z[4]);
                D1_b = (z[8] >= z[4]) ? (z[8] - z[4]):(z[4] - z[8]);
                D1 = D1_a + D1_b;
                D2_a = (z[4] >= z[1]) ? (z[4] - z[1]):(z[1] - z[4]);
                D2_b = (z[7] >= z[4]) ? (z[7] - z[4]):(z[4] - z[7]);
                D2 = D2_a + D2_b;
                D3_a = (z[4] >= z[2]) ? (z[4] - z[2]):(z[2] - z[4]);
                D3_b = (z[6] >= z[4]) ? (z[6] - z[4]):(z[4] - z[6]);
                D3 = D3_a + D3_b;
                D4_a = (z[4] >= z[3]) ? (z[4] - z[3]):(z[3] - z[4]);
                D4_b = (z[5] >= z[4]) ? (z[5] - z[4]):(z[4] - z[5]);
                D4 = D4_a + D4_b;
                
                S = D1 + D2 + D3 + D4;
                
                S_array[k] = S;
                D1_array[k] = D1;
                D2_array[k] = D2;
                D3_array[k] = D3;
                D4_array[k] = D4;
                k = k + 1;
                
            end
        end
    end
    


endmodule
