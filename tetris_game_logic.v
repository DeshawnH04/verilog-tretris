// ===================== TETRIS GAME LOGIC =====================

`timescale 1ns / 1ps

module tetris_game_logic(
    input  wire         clk,
    input  wire         reset,
    input  wire         game_tick,
    input  wire         lock_now,
    input  wire         clear_done,
    output reg          start_clear,
    input  wire         spawn_now,
    output reg          start_spawn_delay,
    input  wire         move_left,
    input  wire         move_right,
    input  wire         move_down,
    input  wire         rotate,
    output reg  [199:0] board_bits,
    output reg  [4:0]   piece_y,
    output reg  [3:0]   piece_x,
    output reg  [2:0]   piece_type,
    output reg  [1:0]   piece_rot,
    output reg          game_over,
    output wire         touching_ground,
    output reg [15:0]   score,
    output reg [9:0]    total_lines,
    output reg [7:0]    level,
    output reg [15:0]   hi_score
);

    // ============================================================
    // FSM STATES
    // ============================================================
    localparam S_PLAY       = 3'd0;
    localparam S_LOCK       = 3'd1;
    localparam S_SCAN       = 3'd2;
    localparam S_SCORE      = 3'd3;
    localparam S_WAIT_CLEAR = 3'd4;
    localparam S_WAIT_SPAWN = 3'd5;

    reg [2:0] state;

    reg [9:0] board [0:19];
    integer r, c;

    reg [2:0] piece_seed;
    reg [7:0] rng_counter;
    reg [2:0] next_seed;
    reg [19:0] full_rows;
    reg [4:0] lines_cleared_r;
    reg       touching_ground_r;

    reg lock_now_latched;

    integer i;
    integer bx, by;
    integer lines_cleared_next;

    assign touching_ground = touching_ground_r;

    // ============================================================
    // SHAPE OFFSETS
    // ============================================================
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

    // ============================================================
    // COLLISION CHECK
    // ============================================================
    function collides(
        input [3:0] x,
        input [4:0] y,
        input [2:0] t,
        input [1:0] r
    );
        integer k;
        integer cx, cy;
        begin
            collides = 0;
            for (k = 0; k < 4; k = k + 1) begin
                cx = x + cell_dx(t, r, k[1:0]);
                cy = y + cell_dy(t, r, k[1:0]);

                if (cx < 0 || cx > 9 || cy > 19)
                    collides = 1;
                else if (cy >= 0 && board[cy][cx])
                    collides = 1;
            end
        end
    endfunction

    // ============================================================
    // NEXT PIECE TYPE
    // ============================================================
    function [2:0] next_piece_type(input [2:0] seed);
        begin
            case (seed)
                3'd1: next_piece_type = 3'd0; // I
                3'd2: next_piece_type = 3'd1; // O
                3'd3: next_piece_type = 3'd2; // T
                3'd4: next_piece_type = 3'd3; // S
                3'd5: next_piece_type = 3'd4; // Z
                3'd6: next_piece_type = 3'd5; // J
                3'd7: next_piece_type = 3'd6; // L
                default: next_piece_type = 3'd0;
            endcase
        end
    endfunction

    // ============================================================
    // MAIN FSM
    // ============================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (r = 0; r < 20; r = r + 1)
                board[r] <= 10'b0;

            piece_x <= 3;
            piece_y <= 0;
            piece_type <= 0;
            piece_rot <= 0;
            piece_seed  <= 3'b001;
            rng_counter <= 8'd1;
            next_seed   <= 3'b001;

            game_over <= 0;
            start_clear <= 0;
            start_spawn_delay <= 0;
            full_rows <= 0;
            lines_cleared_r <= 0;
            touching_ground_r <= 0;
            lock_now_latched <= 0;
            state <= S_PLAY;

            score       <= 0;
            total_lines <= 0;
            level       <= 0;
            hi_score    <= hi_score;

        end else begin
            start_clear <= 0;
            start_spawn_delay <= 0;
            rng_counter <= rng_counter + 8'd1;

            touching_ground_r <= collides(piece_x, piece_y + 1, piece_type, piece_rot);

            if (lock_now)
                lock_now_latched <= 1;
            else if (state == S_LOCK)
                lock_now_latched <= 0;

            if (!game_over) begin
                case (state)

                    // ============================================================
                    // PLAY
                    // ============================================================
                    S_PLAY: begin

                        // ---------------- WALL-KICK ROTATION ----------------
                        if (rotate) begin
                            if (!collides(piece_x, piece_y, piece_type, piece_rot + 1)) begin
                                piece_rot <= piece_rot + 1;

                            end else if (!collides(piece_x + 1, piece_y, piece_type, piece_rot + 1)) begin
                                piece_x <= piece_x + 1;
                                piece_rot <= piece_rot + 1;

                            end else if (!collides(piece_x - 1, piece_y, piece_type, piece_rot + 1)) begin
                                piece_x <= piece_x - 1;
                                piece_rot <= piece_rot + 1;
                            end
                        end

                        // ---------------- MOVEMENT ----------------
                        else if (move_left) begin
                            if (!collides(piece_x - 1, piece_y, piece_type, piece_rot))
                                piece_x <= piece_x - 1;

                        end else if (move_right) begin
                            if (!collides(piece_x + 1, piece_y, piece_type, piece_rot))
                                piece_x <= piece_x + 1;

                        end else if (move_down || game_tick) begin
                            if (!collides(piece_x, piece_y + 1, piece_type, piece_rot)) begin
                                piece_y <= piece_y + 1;
                                if (move_down)
                                    score <= score + 1;

                            end else if (lock_now_latched) begin
                                state <= S_LOCK;
                            end
                        end
                    end

                    // ============================================================
                    // LOCK PIECE
                    // ============================================================
                    S_LOCK: begin
                        for (i = 0; i < 4; i = i + 1) begin
                            bx = piece_x + cell_dx(piece_type, piece_rot, i[1:0]);
                            by = piece_y + cell_dy(piece_type, piece_rot, i[1:0]);
                            if (bx >= 0 && bx <= 9 && by >= 0 && by <= 19)
                                board[by][bx] <= 1;
                        end
                        state <= S_SCAN;
                    end

                    // ============================================================
                    // SCAN ROWS
                    // ============================================================
                    S_SCAN: begin
                        lines_cleared_next = 0;
                        for (r = 0; r < 20; r = r + 1) begin
                            if (board[r] == 10'b1111111111) begin
                                full_rows[r] <= 1;
                                lines_cleared_next = lines_cleared_next + 1;
                            end else begin
                                full_rows[r] <= 0;
                            end
                        end
                        lines_cleared_r <= lines_cleared_next;
                        state <= S_SCORE;
                    end

                    // ============================================================
                    // SCORE
                    // ============================================================
                    S_SCORE: begin
                        if (lines_cleared_r != 0) begin

                            case (lines_cleared_r)
                                1: score <= score + (40  * (level + 1));
                                2: score <= score + (100 * (level + 1));
                                3: score <= score + (300 * (level + 1));
                                4: score <= score + (1200 * (level + 1));
                            endcase

                            total_lines <= total_lines + lines_cleared_r;

                            if (total_lines + lines_cleared_r >= (level + 1) * 10)
                                level <= level + 1;

                            if (score > hi_score)
                                hi_score <= score;

                            start_clear <= 1;
                            state <= S_WAIT_CLEAR;

                        end else begin
                            start_spawn_delay <= 1;
                            state <= S_WAIT_SPAWN;
                        end
                    end

                    // ============================================================
                    // WAIT CLEAR
                    // ============================================================
                    S_WAIT_CLEAR: begin
                        if (clear_done) begin
                            for (r = 19; r >= 0; r = r - 1) begin
                                if (full_rows[r]) begin
                                    for (c = r; c > 0; c = c - 1)
                                        board[c] <= board[c - 1];
                                    board[0] <= 0;
                                end
                            end
                            start_spawn_delay <= 1;
                            state <= S_WAIT_SPAWN;
                        end
                    end

                    // ============================================================
                    // SPAWN NEW PIECE
                    // ============================================================
                    S_WAIT_SPAWN: begin
                        if (spawn_now) begin
                            piece_x  <= 3;
                            piece_y  <= 0;
                            piece_rot <= 0;

                            next_seed = {
                                piece_seed[1:0],
                                piece_seed[2] ^ piece_seed[1] ^ rng_counter[0] ^ rng_counter[3]
                            };

                            if (next_seed == 3'b000)
                                next_seed = 3'b001;

                            piece_seed <= next_seed;
                            piece_type <= next_piece_type(next_seed);

                            if (collides(3, 0, next_piece_type(next_seed), 0))
                                game_over <= 1;

                            state <= S_PLAY;
                        end
                    end

                endcase
            end
        end
    end

    // ============================================================
    // FLATTEN BOARD
    // ============================================================
    always @(*) begin
        for (r = 0; r < 20; r = r + 1)
            for (c = 0; c < 10; c = c + 1)
                board_bits[r*10 + c] = board[r][c];
    end

endmodule
