`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/13/2026 02:23:09 PM
// Design Name: 
// Module Name: tetris_controller
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

module edge_detect(
    input  wire clk,
    input  wire reset,
    input  wire sig_in,
    output wire rising
);
    reg d;

    always @(posedge clk or posedge reset) begin
        if (reset)
            d <= 0;
        else
            d <= sig_in;
    end

    assign rising = sig_in & ~d;
endmodule