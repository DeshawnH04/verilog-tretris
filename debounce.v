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

module debounce #(parameter N = 19)(
    input  wire clk,
    input  wire reset,
    input  wire noisy,
    output reg  clean
);
    reg [N:0] count;
    reg new_state;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clean <= 0;
            new_state <= 0;
            count <= 0;
        end else begin
            if (noisy != new_state) begin
                new_state <= noisy;
                count <= 0;
            end else if (!count[N]) begin
                count <= count + 1;
            end else begin
                clean <= new_state;
            end
        end
    end
endmodule