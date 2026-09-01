`timescale 1ns / 1ps

module digit8x8(
    input  [9:0] hcount,
    input  [9:0] vcount,
    input  [9:0] x,
    input  [9:0] y,
    input  [3:0] digit,
    output [11:0] rgb,
    output        on
);
    // ---------------------------------------------------------
    // LOCAL COORDINATES
    // ---------------------------------------------------------
    wire inside_x = (hcount >= x) && (hcount < x + 8);
    wire inside_y = (vcount >= y) && (vcount < y + 8);
    wire inside   = inside_x && inside_y;

    wire [2:0] col = hcount - x;   // 0-7
    wire [2:0] row = vcount - y;   // 0-7

    reg [7:0] bits;

    // ---------------------------------------------------------
    // DIGIT FONT ROM (8×8)
    // ---------------------------------------------------------
    always @(*) begin
        case (digit)
            4'd0: case (row)
                0: bits = 8'b01111100;
                1: bits = 8'b11000110;
                2: bits = 8'b11001110;
                3: bits = 8'b11011110;
                4: bits = 8'b11110110;
                5: bits = 8'b01111100;
                default: bits = 8'b00000000;
            endcase
            4'd1: case (row)
                0: bits = 8'b00110000;
                1: bits = 8'b01110000;
                2: bits = 8'b00110000;
                3: bits = 8'b00110000;
                4: bits = 8'b00110000;
                5: bits = 8'b11111100;
                default: bits = 8'b00000000;
            endcase
            4'd2: case (row)
                0: bits = 8'b01111100;
                1: bits = 8'b11000110;
                2: bits = 8'b00001100;
                3: bits = 8'b00111000;
                4: bits = 8'b01100000;
                5: bits = 8'b11111110;
                default: bits = 8'b00000000;
            endcase
            4'd3: case (row)
                0: bits = 8'b01111100;
                1: bits = 8'b11000110;
                2: bits = 8'b00001100;
                3: bits = 8'b00111100;
                4: bits = 8'b11000110;
                5: bits = 8'b01111100;
                default: bits = 8'b00000000;
            endcase
            4'd4: case (row)
                0: bits = 8'b00011100;
                1: bits = 8'b00111100;
                2: bits = 8'b01101100;
                3: bits = 8'b11001100;
                4: bits = 8'b11111110;
                5: bits = 8'b00001100;
                default: bits = 8'b00000000;
            endcase
            4'd5: case (row)
                0: bits = 8'b11111110;
                1: bits = 8'b11000000;
                2: bits = 8'b11111100;
                3: bits = 8'b00000110;
                4: bits = 8'b11000110;
                5: bits = 8'b01111100;
                default: bits = 8'b00000000;
            endcase
            4'd6: case (row)
                0: bits = 8'b01111100;
                1: bits = 8'b11000000;
                2: bits = 8'b11111100;
                3: bits = 8'b11000110;
                4: bits = 8'b11000110;
                5: bits = 8'b01111100;
                default: bits = 8'b00000000;
            endcase
            4'd7: case (row)
                0: bits = 8'b11111110;
                1: bits = 8'b00000110;
                2: bits = 8'b00001100;
                3: bits = 8'b00011000;
                4: bits = 8'b00110000;
                5: bits = 8'b01100000;
                default: bits = 8'b00000000;
            endcase
            4'd8: case (row)
                0: bits = 8'b01111100;
                1: bits = 8'b11000110;
                2: bits = 8'b01111100;
                3: bits = 8'b11000110;
                4: bits = 8'b11000110;
                5: bits = 8'b01111100;
                default: bits = 8'b00000000;
            endcase
            4'd9: case (row)
                0: bits = 8'b01111100;
                1: bits = 8'b11000110;
                2: bits = 8'b01111110;
                3: bits = 8'b00000110;
                4: bits = 8'b00001100;
                5: bits = 8'b01111000;
                default: bits = 8'b00000000;
            endcase
            default: bits = 8'b00000000;
        endcase
    end

    // ---------------------------------------------------------
    // PIXEL OUTPUT (with bounds check)
    // ---------------------------------------------------------
    assign on  = inside && bits[7 - col];
    assign rgb = 12'h0FF;  // bright blue

endmodule
