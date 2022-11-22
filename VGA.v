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
    input       [3:0] mem_R,
    input       [3:0] mem_G,
    input       [3:0] mem_B,
    output      [18:0] pixelAddr,
    
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
assign pixelAddr = vga_vcnt * 640 + vga_hcnt;

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
        VGA_R = mem_R;
        VGA_G = mem_G;
        VGA_B = mem_B;
        
        // White square at the center -- idk i guess leave this in just to
        if ((vga_hcnt >= 300 && vga_hcnt <= 340) &&
        	(vga_vcnt >= 220 && vga_vcnt <= 260)) begin
			VGA_R = 4'hf;
			VGA_G = 4'hf;
			VGA_B = 4'hf;
        end
    end
end

endmodule
