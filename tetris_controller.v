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

module tetris_controller(
    input  wire clk,
    input  wire reset,

    // raw FPGA buttons
    input  wire btnL, btnR, btnD, btnC, btnU,

    // one-cycle pulses
    output reg move_left,
    output reg move_right,
    output reg soft_drop,
    output reg rotate,
    output reg start_game
);

    // debounced
    wire L_db, R_db, D_db, C_db, U_db;

    debounce dbL(.clk(clk), .reset(reset), .noisy(btnL), .clean(L_db));
    debounce dbR(.clk(clk), .reset(reset), .noisy(btnR), .clean(R_db));
    debounce dbD(.clk(clk), .reset(reset), .noisy(btnD), .clean(D_db));
    debounce dbC(.clk(clk), .reset(reset), .noisy(btnC), .clean(C_db));
    debounce dbU(.clk(clk), .reset(reset), .noisy(btnU), .clean(U_db));

    // edges
    wire L_edge, R_edge, D_edge, C_edge, U_edge;

    edge_detect eL(.clk(clk), .reset(reset), .sig_in(L_db), .rising(L_edge));
    edge_detect eR(.clk(clk), .reset(reset), .sig_in(R_db), .rising(R_edge));
    edge_detect eD(.clk(clk), .reset(reset), .sig_in(D_db), .rising(D_edge));
    edge_detect eC(.clk(clk), .reset(reset), .sig_in(C_db), .rising(C_edge));
    edge_detect eU(.clk(clk), .reset(reset), .sig_in(U_db), .rising(U_edge));

    // output pulses
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            move_left  <= 0;
            move_right <= 0;
            soft_drop  <= 0;
            rotate     <= 0;
            start_game <= 0;
        end else begin
            move_left  <= L_edge;
            move_right <= R_edge;
            soft_drop  <= D_edge;
            rotate     <= C_edge;
            start_game <= U_edge;
        end
    end
endmodule
