`timescale 1ns / 1ps

module text_renderer #(
    parameter TEXT_LEN = 1,
    parameter COLOR    = 12'hFFF
)(
    input  [9:0] hcount,
    input  [9:0] vcount,
    input  [9:0] x,
    input  [9:0] y,
    input  [TEXT_LEN*8-1:0] text,
    output [11:0] rgb,
    output        on
);

    wire inside_x = (hcount >= x) && (hcount < x + TEXT_LEN*8);
    wire inside_y = (vcount >= y) && (vcount < y + 8);
    wire inside   = inside_x && inside_y;

    wire [9:0] col = hcount - x;
    wire [2:0] row = vcount - y;

    wire [$clog2(TEXT_LEN)-1:0] char_index = col[9:3];

    // ? FIXED ORDER - now characters display left-to-right correctly
    wire [7:0] char = text[(char_index * 8) +: 8];

    wire [7:0] bits;
    font8x8 font(
        .char(char),
        .row(row),
        .bits(bits)
    );

    wire pixel_on = bits[7 - col[2:0]];

    assign on  = inside && pixel_on;
    assign rgb = COLOR;

endmodule
