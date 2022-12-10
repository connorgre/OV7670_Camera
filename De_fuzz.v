`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2022 07:25:04 PM
// Design Name: 
// Module Name: De_fuzz
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


module De_fuzz(
    input [9:0] Mmin,
    input [9:0] Mmid,
    input [9:0] Mmax,
    output [7:0] defuzzed
    );
    
    wire [20:0] AMmin     = (((((1<<8)-Mmin)>>1)+(1<<6))*Mmin)>>1;
    wire [20:0] AMmid     = (((((1<<8)-Mmid)>>1)+(1<<6))*Mmid)   ;
    wire [20:0] AMmax     = (((((1<<8)-Mmax)>>1)+(1<<6))*Mmax)>>1;
    
    wire [20:0] Aoverlap1 = ((Mmin >= (1<<7)) && (Mmid >= (1<<7))) ? (1<<13):(
                                                                            (Mmin < Mmid) ? (((((1<<8)-Mmin)>>1) - (Mmin>>1))*Mmin)>>1 :
                                                                                            (((((1<<8)-Mmid)>>1) - (Mmid>>1))*Mmid)>>1                                                                                                                                                                                                   
                                                                            );
                                                                            
    wire [20:0] Aoverlap2 = ((Mmax >= (1<<7)) && (Mmid >= (1<<7))) ? (1<<13):(
                                                                            (Mmax < Mmid) ? (((((1<<8)-Mmax)>>1) - (Mmax>>1))*Mmax)>>1 :
                                                                                            (((((1<<8)-Mmid)>>1) - (Mmid>>1))*Mmid)>>1                                                                                                                                                                                                   
                                                                            ); 
    wire [22:0] avg = (AMmin + AMmid + AMmax - Aoverlap1 - Aoverlap2)>>7;
    //assign defuzzed = (avg > (((1<<7)+(1<<6))*3)) ? 8'h00
    //                                              : (avg> ((1<<6)*3)) ? 8'h0f : 
     //                                                                   8'hff;
     assign defuzzed = avg[7:0];   
      //assign defuzzed = (Mmin > Mmid) ? 8'hff : 
       //                                       ((Mmid>Mmax) ? 8'h0f : 8'hff);
endmodule
