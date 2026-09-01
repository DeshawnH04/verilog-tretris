`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/21/2026 06:01:11 PM
// Design Name: 
// Module Name: line_clear_timer
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

module line_clear_timer #(
    parameter DELAY = 20_000_000   // ~200 ms at 100 MHz
)(
    input  wire clk,
    input  wire reset,
    input  wire start_clear,   // 1-cycle pulse when a line is detected
    output reg  clear_done     // 1-cycle pulse when animation finishes
);

    reg [31:0] count;
    reg        active;

    always @(posedge clk) begin
        if (reset) begin
            active     <= 0;
            count      <= 0;
            clear_done <= 0;
        end else begin
            clear_done <= 0;

            if (start_clear) begin
                active <= 1;
                count  <= 0;
            end else if (active) begin
                if (count == DELAY - 1) begin
                    active     <= 0;
                    clear_done <= 1;   // 1-cycle pulse
                end else begin
                    count <= count + 1;
                end
            end
        end
    end

endmodule
