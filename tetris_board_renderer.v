`timescale 1ns / 1ps

module tetris_board_renderer #(
    parameter CELL_SIZE = 16,
    parameter GRID_X = 320,
    parameter GRID_Y = 40
)(
    input  wire [9:0] hcount,
    input  wire [9:0] vcount,
    input  wire       video_on,
    input  wire       started,
    input  wire       game_over,

    input  wire [199:0] board_bits,
    input  wire [4:0]   piece_y,
    input  wire [3:0]   piece_x,
    input  wire [2:0]   piece_type,
    input  wire [1:0]   piece_rot,

    output reg  [11:0] rgb,
    output reg         on
);

    // ------------------------------------------------------------
    // COLORS
    // ------------------------------------------------------------
    function [11:0] piece_color;
        input [2:0] t;
        begin
            case (t)
                3'd0: piece_color = 12'h0FF; // I
                3'd1: piece_color = 12'hFF0; // O
                3'd2: piece_color = 12'hF0F; // T
                3'd3: piece_color = 12'h0F0; // S
                3'd4: piece_color = 12'hF00; // Z
                3'd5: piece_color = 12'h00F; // J
                3'd6: piece_color = 12'hFA0; // L
                default: piece_color = 12'hFFF;
            endcase
        end
    endfunction

    // ------------------------------------------------------------
    // GRID BOUNDS
    // ------------------------------------------------------------
    localparam GRID_W = 10 * CELL_SIZE;
    localparam GRID_H = 20 * CELL_SIZE;

    wire inside_grid =
        (hcount >= GRID_X) &&
        (hcount <  GRID_X + GRID_W) &&
        (vcount >= GRID_Y) &&
        (vcount <  GRID_Y + GRID_H);

    wire [9:0] gx = hcount - GRID_X;
    wire [9:0] gy = vcount - GRID_Y;

    wire [3:0] cell_x = gx / CELL_SIZE;
    wire [4:0] cell_y = gy / CELL_SIZE;

    // ------------------------------------------------------------
    // SHAPE TABLES - MATCH GAME LOGIC EXACTLY
    // ------------------------------------------------------------
    function integer cell_dx(input [2:0] t, input [1:0] r, input [1:0] idx);
        begin
            cell_dx = 0;   // default value
            case (t)

                // I piece
                3'd0: begin
                    case (r)
                        2'd0, 2'd2: begin
                            case (idx)
                            0: cell_dx = -1;
                            1: cell_dx =  0;
                            2: cell_dx =  1;
                            3: cell_dx =  2;
                            endcase
                        end
                        default: cell_dx = 0;
                    endcase
                end

                // O piece
                3'd1: begin
                    case (idx)
                        0: cell_dx = 0;
                        1: cell_dx = 1;
                        2: cell_dx = 0;
                        3: cell_dx = 1;
                    endcase
                end

                // T piece
                3'd2: begin
                    case (r)
                        2'd0: begin
                            case (idx)
                                0: cell_dx = -1;
                                1: cell_dx =  0;
                                2: cell_dx =  1;
                                3: cell_dx =  0;
                            endcase
                        end
                        2'd1: begin
                            case (idx)
                                0: cell_dx = 0;
                                1: cell_dx = 0;
                                2: cell_dx = 0;
                                3: cell_dx = 1;
                            endcase
                        end
                        2'd2: begin
                            case (idx)
                                0: cell_dx = -1;
                                1: cell_dx =  0;
                                2: cell_dx =  1;
                                3: cell_dx =  0;
                            endcase
                        end
                        default: begin
                            case (idx)
                                0: cell_dx =  0;
                                1: cell_dx =  0;
                                2: cell_dx =  0;
                                3: cell_dx = -1;
                            endcase
                        end
                    endcase
                end

                // S piece
                3'd3: begin
                    case (r)
                        2'd0, 2'd2: begin
                            case (idx)
                                0: cell_dx =  0;
                                1: cell_dx =  1;
                                2: cell_dx = -1;
                                3: cell_dx =  0;
                            endcase
                        end
                        default: begin
                            case (idx)
                                0: cell_dx = 0;
                                1: cell_dx = 0;
                                2: cell_dx = 1;
                                3: cell_dx = 1;
                            endcase
                        end
                    endcase
                end

                // Z piece
                3'd4: begin
                    case (r)
                        2'd0, 2'd2: begin
                            case (idx)
                                0: cell_dx = -1;
                                1: cell_dx =  0;
                                2: cell_dx =  0;
                                3: cell_dx =  1;
                            endcase
                        end
                        default: begin
                            case (idx)
                                0: cell_dx = 1;
                                1: cell_dx = 1;
                                2: cell_dx = 0;
                                3: cell_dx = 0;
                            endcase
                        end
                    endcase
                end

                // J piece
                3'd5: begin
                    case (r)
                        2'd0: begin
                            case (idx)
                                0: cell_dx = -1;
                                1: cell_dx = -1;
                                2: cell_dx =  0;
                                3: cell_dx =  1;
                            endcase
                        end
                        2'd1: begin
                            case (idx)
                                0: cell_dx = 0;
                                1: cell_dx = 1;
                                2: cell_dx = 0;
                                3: cell_dx = 0;
                            endcase
                        end
                        2'd2: begin
                            case (idx)
                                0: cell_dx = -1;
                                1: cell_dx =  0;
                                2: cell_dx =  1;
                                3: cell_dx =  1;
                            endcase
                        end
                        default: begin
                            case (idx)
                                0: cell_dx = 0;
                                1: cell_dx = 0;
                                2: cell_dx = 0;
                                3: cell_dx = -1;
                            endcase
                        end
                    endcase
                end

                // L piece
                3'd6: begin
                    case (r)
                        2'd0: begin
                            case (idx)
                                0: cell_dx =  1;
                                1: cell_dx = -1;
                                2: cell_dx =  0;
                                3: cell_dx =  1;
                            endcase
                        end
                        2'd1: begin
                            case (idx)
                                0: cell_dx = 0;
                                1: cell_dx = 0;
                                2: cell_dx = 0;
                                3: cell_dx = 1;
                            endcase
                        end
                        2'd2: begin
                            case (idx)
                                0: cell_dx = -1;
                                1: cell_dx =  0;
                                2: cell_dx =  1;
                                3: cell_dx = -1;
                            endcase
                        end
                        default: begin
                            case (idx)
                                0: cell_dx = -1;
                                1: cell_dx =  0;
                                2: cell_dx =  0;
                                3: cell_dx =  0;
                            endcase
                        end
                    endcase
                end

                default: cell_dx = 0;

            endcase
        end
    endfunction

    function integer cell_dy(input [2:0] t, input [1:0] r, input [1:0] idx);
        begin
            cell_dy = 0;   // default value
            case (t)

                // I piece
                3'd0: begin
                    case (r)
                        2'd0, 2'd2: cell_dy = 0;
                        default: begin
                            case (idx)
                                0: cell_dy = -1;
                                1: cell_dy =  0;
                                2: cell_dy =  1;
                                3: cell_dy =  2;
                            endcase
                        end
                    endcase
                end

                // O piece
                3'd1: begin
                    case (idx)
                        0: cell_dy = 0;
                        1: cell_dy = 0;
                        2: cell_dy = 1;
                        3: cell_dy = 1;
                    endcase
                end

                // T piece
                3'd2: begin
                    case (r)
                        2'd0: begin
                            case (idx)
                                0: cell_dy = 0;
                                1: cell_dy = 0;
                                2: cell_dy = 0;
                                3: cell_dy = 1;
                            endcase
                        end
                        2'd1: begin
                            case (idx)
                                0: cell_dy = -1;
                                1: cell_dy =  0;
                                2: cell_dy =  1;
                                3: cell_dy =  0;
                            endcase
                        end
                        2'd2: begin
                            case (idx)
                                0: cell_dy =  0;
                                1: cell_dy =  0;
                                2: cell_dy =  0;
                                3: cell_dy = -1;
                            endcase
                        end
                        default: begin
                            case (idx)
                                0: cell_dy = -1;
                                1: cell_dy =  0;
                                2: cell_dy =  1;
                                3: cell_dy =  0;
                            endcase
                        end
                    endcase
                end

                // S piece
                3'd3: begin
                    case (r)
                        2'd0, 2'd2: begin
                            case (idx)
                                0: cell_dy = 0;
                                1: cell_dy = 0;
                                2: cell_dy = 1;
                                3: cell_dy = 1;
                            endcase
                        end
                        default: begin
                            case (idx)
                                0: cell_dy = -1;
                                1: cell_dy =  0;
                                2: cell_dy =  0;
                                3: cell_dy =  1;
                            endcase
                        end
                    endcase
                end

                // Z piece
                3'd4: begin
                    case (r)
                        2'd0, 2'd2: begin
                            case (idx)
                                0: cell_dy = 0;
                                1: cell_dy = 0;
                                2: cell_dy = 1;
                                3: cell_dy = 1;
                            endcase
                        end
                        default: begin
                            case (idx)
                                0: cell_dy = -1;
                                1: cell_dy =  0;
                                2: cell_dy =  0;
                                3: cell_dy =  1;
                            endcase
                        end
                    endcase
                end

                // J piece
                3'd5: begin
                    case (r)
                        2'd0: begin
                            case (idx)
                                0: cell_dy = 0;
                                1: cell_dy = 1;
                                2: cell_dy = 1;
                                3: cell_dy = 1;
                            endcase
                        end
                        2'd1: begin
                            case (idx)
                                0: cell_dy = -1;
                                1: cell_dy = -1;
                                2: cell_dy =  0;
                                3: cell_dy =  1;
                            endcase
                        end
                        2'd2: begin
                            case (idx)
                                0: cell_dy = 0;
                                1: cell_dy = 0;
                                2: cell_dy = 0;
                                3: cell_dy = 1;
                            endcase
                        end
                        default: begin
                            case (idx)
                                0: cell_dy = -1;
                                1: cell_dy =  0;
                                2: cell_dy =  1;
                                3: cell_dy =  1;
                            endcase
                        end
                    endcase
                end

                // L piece
                3'd6: begin
                    case (r)
                        2'd0: begin
                            case (idx)
                                0: cell_dy = 0;
                                1: cell_dy = 1;
                                2: cell_dy = 1;
                                3: cell_dy = 1;
                            endcase
                        end
                        2'd1: begin
                            case (idx)
                                0: cell_dy = -1;
                                1: cell_dy =  0;
                                2: cell_dy =  1;
                                3: cell_dy =  1;
                            endcase
                        end
                        2'd2: begin
                            case (idx)
                                0: cell_dy = 0;
                                1: cell_dy = 0;
                                2: cell_dy = 0;
                                3: cell_dy = 1;
                            endcase
                        end
                        default: begin
                            case (idx)
                                0: cell_dy = -1;
                                1: cell_dy = -1;
                                2: cell_dy =  0;
                                3: cell_dy =  1;
                            endcase
                        end
                    endcase
                end

                default: cell_dy = 0;

            endcase
        end
    endfunction

    // ------------------------------------------------------------
    // MAIN RENDER LOGIC
    // ------------------------------------------------------------
    integer k;
    integer bx, by;

    always @(*) begin
        on  = 0;
        rgb = 12'h000;

        if (video_on && started && inside_grid) begin

            // Locked blocks
            if (board_bits[cell_y*10 + cell_x]) begin
                on  = 1;
                rgb = 12'h666;
            end

            // Active piece
            for (k = 0; k < 4; k = k + 1) begin
                bx = piece_x + cell_dx(piece_type, piece_rot, k[1:0]);
                by = piece_y + cell_dy(piece_type, piece_rot, k[1:0]);

                if (cell_x == bx && cell_y == by) begin
                    on  = 1;
                    rgb = piece_color(piece_type);
                end
            end
        end
    end

endmodule
