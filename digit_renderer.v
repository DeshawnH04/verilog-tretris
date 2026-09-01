`timescale 1ns / 1ps

module digit_renderer(
    input  wire [9:0] hcount,
    input  wire [9:0] vcount,
    input  wire [9:0] x,
    input  wire [9:0] y,
    input  wire [3:0] d3,
    input  wire [3:0] d2,
    input  wire [3:0] d1,
    input  wire [3:0] d0,
    output wire [11:0] rgb,
    output wire        on
);

    wire [11:0] rgb0, rgb1, rgb2, rgb3;
    wire on0, on1, on2, on3;

    digit8x8 r0(
        .hcount(hcount),
        .vcount(vcount),
        .x(x + 24),
        .y(y),
        .digit(d0),
        .rgb(rgb0),
        .on(on0)
    );

    digit8x8 r1(
        .hcount(hcount),
        .vcount(vcount),
        .x(x + 16),
        .y(y),
        .digit(d1),
        .rgb(rgb1),
        .on(on1)
    );

    digit8x8 r2(
        .hcount(hcount),
        .vcount(vcount),
        .x(x + 8),
        .y(y),
        .digit(d2),
        .rgb(rgb2),
        .on(on2)
    );

    digit8x8 r3(
        .hcount(hcount),
        .vcount(vcount),
        .x(x),
        .y(y),
        .digit(d3),
        .rgb(rgb3),
        .on(on3)
    );

    assign on  = on0 | on1 | on2 | on3;

    assign rgb = on0 ? rgb0 :
                 on1 ? rgb1 :
                 on2 ? rgb2 :
                 on3 ? rgb3 :
                 12'h000;

endmodule