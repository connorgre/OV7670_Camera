`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2022 08:13:16 PM
// Design Name: 
// Module Name: Min
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


module Min(
    input [9:0] D1,
    input [9:0] D2,
    input [9:0] D3,
    input [9:0] D4,
    output [9:0] min
    );
    
    assign min = (D1 < D2) ? (
                              (D1 < D3) ? (
                                           (D1 < D4) ? 
                                                       D1 
                                                     : D4
                                          )
                                        : (
                                           (D3 < D4) ?
                                                       D3 
                                                     :  D4
                                          )
                             )
                           : (
                              (D2 < D3) ? (
                                           (D2 < D4) ? 
                                                       D2 
                                                     : D4
                                          )
                                        : (
                                           (D3 < D4) ?
                                                       D3 
                                                     : D4
                                          )
                             );                              
                                                                        
endmodule
