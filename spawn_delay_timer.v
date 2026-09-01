`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/21/2026 06:16:40 PM
// Design Name: 
// Module Name: spawn_delay_timer
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

module spawn_delay_timer #(
    parameter DELAY = 5_000_000   // ~50 ms at 100 MHz
)(
    input  wire clk,
    input  wire reset,
    input  wire start_spawn_delay,   // 1-cycle pulse
    output reg  spawn_now            // 1-cycle pulse
);

    reg [31:0] count;
    reg        active;

    always @(posedge clk) begin
        if (reset) begin
            active    <= 0;
            count     <= 0;
            spawn_now <= 0;
        end else begin
            spawn_now <= 0;

            if (start_spawn_delay) begin
                active <= 1;
                count  <= 0;
            end else if (active) begin
                if (count == DELAY - 1) begin
                    active    <= 0;
                    spawn_now <= 1;   // 1-cycle pulse
                end else begin
                    count <= count + 1;
                end
            end
        end
    end

endmodule

