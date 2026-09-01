`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/21/2026 05:34:22 PM
// Design Name: 
// Module Name: lock_delay_timer
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


module lock_delay_timer #(
    parameter DELAY = 25_000_000   // 0.25 sec at 100 MHz
)(
    input  wire clk,
    input  wire reset,
    input  wire touching_ground,   // from game logic
    input  wire player_action,     // move/rotate/soft_drop
    output reg  lock_now           // 1-cycle pulse
);

    reg [31:0] count;

    always @(posedge clk) begin
        if (reset) begin
            count    <= 0;
            lock_now <= 0;
        end else begin
            // If piece is not touching ground, reset timer
            if (!touching_ground) begin
                count    <= 0;
                lock_now <= 0;
            end
            // If player moves/rotates, reset timer
            else if (player_action) begin
                count    <= 0;
                lock_now <= 0;
            end
            // Otherwise, count up
            else begin
                if (count == DELAY - 1) begin
                    count    <= 0;
                    lock_now <= 1;   // 1-cycle pulse
                end else begin
                    count    <= count + 1;
                    lock_now <= 0;
                end
            end
        end
    end

endmodule

