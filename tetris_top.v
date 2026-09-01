`timescale 1ns / 1ps

module tetris_top(
    input  wire clk,        // 100 MHz
    input  wire reset,      // ACTIVE-LOW BUTTON

    input  wire btnU,
    input  wire btnL,
    input  wire btnR,
    input  wire btnD,
    input  wire btnC,

    output wire hsync,
    output wire vsync,

    output wire [3:0] vga_r,
    output wire [3:0] vga_g,
    output wire [3:0] vga_b,

    output wire [4:0] led
);

    //------------------------------------------------------------
    // RESET: convert ACTIVE-LOW ? ACTIVE-HIGH internal
    //------------------------------------------------------------
    wire reset_h = ~reset;

    //------------------------------------------------------------
    // CLEAN 25 MHz pixel_tick generator
    //------------------------------------------------------------
    reg [1:0] pix_div = 0;
    reg       pixel_tick = 0;

    always @(posedge clk) begin
        pix_div <= pix_div + 1;
        pixel_tick <= (pix_div == 0);
    end

    //------------------------------------------------------------
    // VGA TIMING
    //------------------------------------------------------------
    wire video_on;
    wire [9:0] hcount, vcount;

    vga_controller vga_inst (
        .clk(clk),
        .reset(~reset_h),      // VGA expects ACTIVE-LOW reset
        .pixel_tick(pixel_tick),
        .hsync(hsync),
        .vsync(vsync),
        .video_on(video_on),
        .x(hcount),
        .y(vcount)
    );

    //------------------------------------------------------------
    // START BUTTON ? started flag
    //------------------------------------------------------------
    reg started = 0;

    // game_over comes from game logic
    wire game_over;

    always @(posedge clk or posedge reset_h) begin
        if (reset_h)
            started <= 0;

        else if (btnU) begin
            if (game_over)
                started <= 0;   // return to title screen
            else
                started <= 1;   // start game
        end
    end

    //------------------------------------------------------------
    // GAME LOGIC SIGNALS
    //------------------------------------------------------------
    wire [199:0] board_bits;
    wire [4:0]   piece_y;
    wire [3:0]   piece_x;
    wire [2:0]   piece_type;
    wire [1:0]   piece_rot;
    wire         touching_ground;

    wire [15:0] score;
    wire [9:0]  total_lines;
    wire [7:0]  level;
    wire [15:0] hi_score;

    wire start_clear, start_spawn_delay;
    wire clear_done, spawn_now, lock_now, game_tick;

    //------------------------------------------------------------
    // CONTROLLER
    //------------------------------------------------------------
    wire move_left, move_right, move_down, rotate, start_game;

    tetris_controller controller_inst (
        .clk(clk),
        .reset(reset_h),
        .btnL(btnL),
        .btnR(btnR),
        .btnD(btnD),
        .btnC(btnC),
        .btnU(btnU),
        .move_left(move_left),
        .move_right(move_right),
        .soft_drop(move_down),
        .rotate(rotate),
        .start_game(start_game)
    );

    //------------------------------------------------------------
    // PLAYER ACTION
    //------------------------------------------------------------
    wire player_action = move_left | move_right | rotate | btnD;

    //------------------------------------------------------------
    // GAME ENABLE (FREEZE GAME UNTIL START)
    //------------------------------------------------------------
    wire game_enable = started;

    //------------------------------------------------------------
    // TIMERS (GATED BY game_enable)
    //------------------------------------------------------------
    lock_delay_timer #(.DELAY(20_000_000)) lock_timer (
        .clk(clk),
        .reset(reset_h | ~game_enable),
        .touching_ground(touching_ground),
        .player_action(player_action),
        .lock_now(lock_now)
    );

    line_clear_timer #(.DELAY(20_000_000)) clear_timer (
        .clk(clk), .reset(reset_h | ~game_enable),
        .start_clear(start_clear),
        .clear_done(clear_done)
    );

    spawn_delay_timer #(.DELAY(5_000_000)) spawn_timer (
        .clk(clk), .reset(reset_h | ~game_enable),
        .start_spawn_delay(start_spawn_delay),
        .spawn_now(spawn_now)
    );

    gravity_tick_gen gravity_inst (
        .clk(clk),
        .reset(reset_h | ~game_enable),
        .tick(game_tick)
    );

    //------------------------------------------------------------
    // MAIN GAME LOGIC
    //------------------------------------------------------------
    tetris_game_logic game_core (
        .clk(clk),
        .reset(reset_h | ~game_enable),

        .game_tick(game_tick),
        .lock_now(lock_now),
        .clear_done(clear_done),
        .start_clear(start_clear),
        .spawn_now(spawn_now),
        .start_spawn_delay(start_spawn_delay),

        .move_left(move_left),
        .move_right(move_right),
        .move_down(move_down),
        .rotate(rotate),

        .board_bits(board_bits),
        .piece_y(piece_y),
        .piece_x(piece_x),
        .piece_type(piece_type),
        .piece_rot(piece_rot),
        .game_over(game_over),
        .touching_ground(touching_ground),

        .score(score),
        .total_lines(total_lines),
        .level(level),
        .hi_score(hi_score)
    );

    //------------------------------------------------------------
    // RENDERERS
    //------------------------------------------------------------
    wire [11:0] rgb_grid, rgb_board, rgb_score, rgb_gameover;
    wire grid_on, board_on, gameover_on;

    tetris_grid_renderer #(.GRID_X(320), .GRID_Y(40)) grid (
        .hcount(hcount), .vcount(vcount),
        .video_on(video_on), .started(started),
        .rgb(rgb_grid), .on(grid_on)
    );

    // NOTE: no .game_over here anymore
    tetris_board_renderer #(.GRID_X(320), .GRID_Y(40)) board (
        .hcount(hcount), .vcount(vcount),
        .video_on(video_on), .started(started),
        .board_bits(board_bits),
        .piece_y(piece_y), .piece_x(piece_x),
        .piece_type(piece_type), .piece_rot(piece_rot),
        .rgb(rgb_board), .on(board_on)
    );

    game_over_renderer gameover_text (
        .hcount(hcount),
        .vcount(vcount),
        .video_on(video_on),
        .game_over(game_over),
        .rgb(rgb_gameover),
        .on(gameover_on)
    );

    arcade_scoreboard_renderer scoreboard (
        .clk(clk), .pixel_tick(pixel_tick),
        .hcount(hcount), .vcount(vcount),
        .video_on(video_on), .started(started),
        .score(score), .lines(total_lines),
        .level(level),
        .hi_score(hi_score),
        .rgb(rgb_score)
    );

    //------------------------------------------------------------
    // FINAL RGB MUX (UPDATED FOR BLACK GAME OVER SCREEN)
    //------------------------------------------------------------
    reg [11:0] rgb_next;

    always @(*) begin
        if (!video_on)
            rgb_next = 12'h000;

        else if (!started)
            rgb_next = rgb_score;   // title screen

        else if (game_over) begin
            if (gameover_on)
                rgb_next = rgb_gameover;   // GAME OVER text
            else
                rgb_next = 12'h000;        // black background
        end

        else if (board_on)
            rgb_next = rgb_board;

        else if (grid_on)
            rgb_next = rgb_grid;

        else
            rgb_next = rgb_score;
    end

    //------------------------------------------------------------
    // OUTPUT REGISTER
    //------------------------------------------------------------
    reg [11:0] rgb_reg;

    always @(posedge clk) begin
        if (pixel_tick)
            rgb_reg <= rgb_next;
    end

    assign vga_r = rgb_reg[11:8];
    assign vga_g = rgb_reg[7:4];
    assign vga_b = rgb_reg[3:0];

    //------------------------------------------------------------
    // LED DEBUG
    //------------------------------------------------------------
    assign led[0] = move_left;
    assign led[1] = move_right;
    assign led[2] = move_down;
    assign led[3] = rotate;
    assign led[4] = touching_ground;

endmodule
