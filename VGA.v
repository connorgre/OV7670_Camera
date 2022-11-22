`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2022 06:42:32 PM
// Design Name: 
// Module Name: VGA
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


module VGA(
    input   wire pixel_clk,   //25MHZ clk
    // From memory
    input       [3:0] vgaInR,
    input       [3:0] vgaInG,
    input       [3:0] vgaInB,
    output      [9:0] outX,
    output      [8:0] outY,
    
    // To VGA
    output  reg [3:0] VGA_R,
    output  reg [3:0] VGA_G,
    output  reg [3:0] VGA_B,
    output  wire VGA_HS,
    output  wire VGA_VS
    );

wire [10:0] vga_hcnt, vga_vcnt;
wire vga_blank;

wire inBounds = ((vga_vcnt <= 480) && (vga_hcnt <= 640));
assign outX = vga_hcnt;
assign outY = vga_vcnt;

// Instantiate VGA controller
vga_controller_640_60 vga_controller(
    .pixel_clk(pixel_clk),
    .HS(VGA_HS),
    .VS(VGA_VS),
    .hcounter(vga_hcnt),
    .vcounter(vga_vcnt),
    .blank(vga_blank)
);

// Generate figure to be displayed
// Decide the color for the current pixel at index (hcnt, vcnt).
// This example displays an white square at the center of the screen with a colored checkerboard background.
always @(*) begin
    // Set pixels to black during Sync. Failure to do so will result in dimmed colors or black screens.
    // also write 0 if we are out of bounds for the VGA display
    if (vga_blank | ~inBounds) begin 
        VGA_R = 0;
        VGA_G = 0;
        VGA_B = 0;
    end
    else begin  // Image to be displayed
        VGA_R = vgaInR;
        VGA_G = vgaInG;
        VGA_B = vgaInB;
    end
end

endmodule
