`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/13/2026 06:28:44 PM
// Design Name: 
// Module Name: pulse_stretch
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

module pulse_stretch #(
    parameter WIDTH = 22        // ~40-50 ms at 100 MHz
)(
    input  wire clk,
    input  wire reset,
    input  wire pulse_in,       // 1-cycle pulse
    output reg  led_out         // stretched LED signal
);

    reg [WIDTH-1:0] counter = 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            led_out <= 0;
        end else begin
            if (pulse_in) begin
                // load counter when pulse arrives
                counter <= {WIDTH{1'b1}};
                led_out <= 1;
            end else if (counter != 0) begin
                counter <= counter - 1;
                led_out <= 1;
            end else begin
                led_out <= 0;
            end
        end
    end
endmodule