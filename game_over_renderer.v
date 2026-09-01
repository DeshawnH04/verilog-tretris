`timescale 1ns / 1ps

module game_over_renderer(
    input  wire [9:0] hcount,
    input  wire [9:0] vcount,
    input  wire       video_on,
    input  wire       game_over,
    output reg  [11:0] rgb,
    output reg         on
);

    // Centered position for 9 chars * 8px * scale 2 = 144px wide
    localparam SCALE = 2;

    localparam TEXT_W = 9 * 8 * SCALE;   // 144
    localparam TEXT_H = 16 * SCALE;      // 32

    localparam X0 = (640 - TEXT_W) / 2;  // 248
    localparam Y0 = (480 - TEXT_H) / 2;  // 224

    integer cx, cy;
    integer char_index, row;
    reg [7:0] font_bits;

    // FONT ROM
    function [7:0] font_row;
        input [7:0] ch;
        input [3:0] row;
        begin
            case (ch)
                "G": case(row)
                        0: font_row = 8'b00111100;
                        1: font_row = 8'b01100110;
                        2: font_row = 8'b01100000;
                        3: font_row = 8'b01101110;
                        4: font_row = 8'b01100110;
                        5: font_row = 8'b01100110;
                        6: font_row = 8'b00111100;
                        default: font_row = 0;
                    endcase
                "A": case(row)
                        0: font_row = 8'b00011000;
                        1: font_row = 8'b00111100;
                        2: font_row = 8'b01100110;
                        3: font_row = 8'b01111110;
                        4: font_row = 8'b01100110;
                        5: font_row = 8'b01100110;
                        6: font_row = 8'b01100110;
                        default: font_row = 0;
                    endcase
                "M": case(row)
                        0: font_row = 8'b01100110;
                        1: font_row = 8'b01111110;
                        2: font_row = 8'b01111110;
                        3: font_row = 8'b01100110;
                        4: font_row = 8'b01100110;
                        5: font_row = 8'b01100110;
                        6: font_row = 8'b01100110;
                        default: font_row = 0;
                    endcase
                "E": case(row)
                        0: font_row = 8'b01111110;
                        1: font_row = 8'b01100000;
                        2: font_row = 8'b01111100;
                        3: font_row = 8'b01100000;
                        4: font_row = 8'b01100000;
                        5: font_row = 8'b01100000;
                        6: font_row = 8'b01111110;
                        default: font_row = 0;
                    endcase
                "O": case(row)
                        0: font_row = 8'b00111100;
                        1: font_row = 8'b01100110;
                        2: font_row = 8'b01100110;
                        3: font_row = 8'b01100110;
                        4: font_row = 8'b01100110;
                        5: font_row = 8'b01100110;
                        6: font_row = 8'b00111100;
                        default: font_row = 0;
                    endcase
                "V": case(row)
                        0: font_row = 8'b01100110;
                        1: font_row = 8'b01100110;
                        2: font_row = 8'b01100110;
                        3: font_row = 8'b01100110;
                        4: font_row = 8'b00111100;
                        5: font_row = 8'b00011000;
                        6: font_row = 8'b00011000;
                        default: font_row = 0;
                    endcase
                "R": case(row)
                        0: font_row = 8'b01111100;
                        1: font_row = 8'b01100110;
                        2: font_row = 8'b01100110;
                        3: font_row = 8'b01111100;
                        4: font_row = 8'b01101100;
                        5: font_row = 8'b01100110;
                        6: font_row = 8'b01100110;
                        default: font_row = 0;
                    endcase
                default: font_row = 0;
            endcase
        end
    endfunction

    // TEXT STRING
    reg [7:0] text [0:8];
    initial begin
        text[0] = "G";
        text[1] = "A";
        text[2] = "M";
        text[3] = "E";
        text[4] = " ";
        text[5] = "O";
        text[6] = "V";
        text[7] = "E";
        text[8] = "R";
    end

    // RENDER
    always @(*) begin
        on  = 0;
        rgb = 12'h000;

        if (video_on && game_over) begin
            cx = hcount - X0;
            cy = vcount - Y0;

            if (cx >= 0 && cy >= 0 && cx < TEXT_W && cy < TEXT_H) begin
                char_index = cx / (8 * SCALE);
                row        = cy / SCALE;

                font_bits = font_row(text[char_index], row);

                if (font_bits[7 - ((cx / SCALE) % 8)]) begin
                    on  = 1;
                    rgb = 12'hFFF;
                end
            end
        end
    end

endmodule
