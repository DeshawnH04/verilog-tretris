`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/21/2026 05:22:33 PM
// Design Name: 
// Module Name: gravity_tick_gen
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


module gravity_tick_gen #(
    parameter DIVISOR = 50_000_000   // 0.5 sec at 100 MHz
)(
    input  wire clk,
    input  wire reset,
    output reg  tick
);

    reg [31:0] count;

    always @(posedge clk) begin
        if (reset) begin
            count <= 0;
            tick  <= 0;
        end else begin
            if (count == DIVISOR - 1) begin
                count <= 0;
                tick  <= 1;      // 1-cycle pulse
            end else begin
                count <= count + 1;
                tick  <= 0;
            end
        end
    end

endmodule
