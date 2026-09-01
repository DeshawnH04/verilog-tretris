`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/06/2026 12:57:24 PM
// Design Name: 
// Module Name: tetris_vga_top
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


module tetris_vga_top(
    input wire clk,
    input wire reset,
    output wire hsync,
    output wire vsync,
    output wire [3:0] vga_r,
    output wire [3:0] vga_b,
    output wire [3:0] vga_g
    );
    // 25 MHz pixel tick generation from 100 MHz clock
    reg [1:0] div_reg;
    wire pixel_tick;

    always @(posedge clk or posedge reset) begin
        if (reset)
            div_reg <= 2'b00;
        else
            div_reg <= div_reg + 2'b01;
    end

    assign pixel_tick = (div_reg == 2'b00);

    // VGA timing signals
    wire video_on;
    wire [9:0] x;
    wire [9:0] y;

    vga_controller vga_unit (
        .clk(clk),
        .reset(reset),
        .pixel_tick(pixel_tick),
        .hsync(hsync),
        .vsync(vsync),
        .video_on(video_on),
        .x(x),
        .y(y)
    );

    // Solid blue screen during active video region
    assign vga_r = (video_on) ? 4'h0 : 4'h0;
    assign vga_g = (video_on) ? 4'h0 : 4'h0;
    assign vga_b = (video_on) ? 4'hF : 4'h0;
endmodule
