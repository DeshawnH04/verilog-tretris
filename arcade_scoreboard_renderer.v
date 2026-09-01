`timescale 1ns / 1ps

module arcade_scoreboard_renderer #(
    parameter PANEL_X      = 40,
    parameter PANEL_WIDTH  = 240
)(
    input  wire        clk,
    input  wire        pixel_tick,
    input  wire [9:0]  hcount,
    input  wire [9:0]  vcount,
    input  wire        video_on,
    input  wire        started,
    input  wire [15:0] score,
    input  wire [9:0]  lines,
    input  wire [7:0]  level,
    input  wire [15:0] hi_score,
    output reg  [11:0] rgb
);

    wire reset_conv = 1'b0;

    //------------------------------------------------------------
    // PANEL + BORDER
    //------------------------------------------------------------
    wire panel =
        (hcount >= PANEL_X && hcount < PANEL_X + PANEL_WIDTH &&
         vcount >= 40      && vcount < 200);

    wire border =
        (hcount >= PANEL_X - 2 && hcount < PANEL_X + PANEL_WIDTH + 2 &&
         vcount >= 38          && vcount < 202) &&
        !panel;

    localparam PANEL_COLOR  = 12'h012;
    localparam BORDER_COLOR = 12'h0AF;

    //------------------------------------------------------------
    // ROW POSITIONS
    //------------------------------------------------------------
    localparam ROW1_LABEL_Y  = 60;
    localparam ROW1_DIGITS_Y = 76;
    localparam ROW2_LABEL_Y  = 110;
    localparam ROW2_DIGITS_Y = 126;

    //------------------------------------------------------------
    // LAYOUT
    //------------------------------------------------------------
    localparam COL_WIDTH = PANEL_WIDTH / 2;
    localparam LEFT_COL_X  = PANEL_X;
    localparam RIGHT_COL_X = PANEL_X + COL_WIDTH;
    localparam DIGIT_W = 32;

    function integer label_width;
        input integer len;
        begin
            label_width = len * 8;
        end
    endfunction

    function integer center_x;
        input integer col_x;
        input integer col_w;
        input integer item_w;
        begin
            center_x = col_x + (col_w - item_w) / 2;
        end
    endfunction

    //------------------------------------------------------------
    // PRECOMPUTED POSITIONS
    //------------------------------------------------------------
    localparam SCORE_LABEL_X  = center_x(LEFT_COL_X,  COL_WIDTH, label_width(5));
    localparam SCORE_DIGITS_X = center_x(LEFT_COL_X,  COL_WIDTH, DIGIT_W);

    localparam HI_LABEL_X     = center_x(RIGHT_COL_X, COL_WIDTH, label_width(8));
    localparam HI_DIGITS_X    = center_x(RIGHT_COL_X, COL_WIDTH, DIGIT_W);

    localparam LINES_LABEL_X  = center_x(LEFT_COL_X,  COL_WIDTH, label_width(5));
    localparam LINES_DIGITS_X = center_x(LEFT_COL_X,  COL_WIDTH, DIGIT_W);

    localparam LEVEL_LABEL_X  = center_x(RIGHT_COL_X, COL_WIDTH, label_width(5));
    localparam LEVEL_DIGITS_X = center_x(RIGHT_COL_X, COL_WIDTH, DIGIT_W);

    //------------------------------------------------------------
    // BCD CONVERTERS
    //------------------------------------------------------------
    wire [3:0] score_d3, score_d2, score_d1, score_d0;
    wire [3:0] hi_d3, hi_d2, hi_d1, hi_d0;
    wire [3:0] lines_d3, lines_d2, lines_d1, lines_d0;
    wire [3:0] level_d3, level_d2, level_d1, level_d0;

    bin16_to_bcd4 score_bcd (
        .clk(clk),
        .reset(reset_conv),
        .binary(score),
        .d3(score_d3), .d2(score_d2), .d1(score_d1), .d0(score_d0)
    );

    bin16_to_bcd4 hi_bcd (
        .clk(clk),
        .reset(reset_conv),
        .binary(hi_score),
        .d3(hi_d3), .d2(hi_d2), .d1(hi_d1), .d0(hi_d0)
    );

    bin16_to_bcd4 lines_bcd (
        .clk(clk),
        .reset(reset_conv),
        .binary({6'd0, lines}),
        .d3(lines_d3), .d2(lines_d2), .d1(lines_d1), .d0(lines_d0)
    );

    bin16_to_bcd4 level_bcd (
        .clk(clk),
        .reset(reset_conv),
        .binary({8'd0, level}),
        .d3(level_d3), .d2(level_d2), .d1(level_d1), .d0(level_d0)
    );

    //------------------------------------------------------------
    // LABELS (ASCII + REVERSED BYTE ORDER)
    //------------------------------------------------------------
    wire score_label_on, hi_label_on, lines_label_on, level_label_on;
    wire [11:0] score_label_rgb, hi_label_rgb, lines_label_rgb, level_label_rgb;

    // SCORE ? reversed: E R O C S
    text_renderer #(.TEXT_LEN(5), .COLOR(12'h0FF)) score_label (
        .hcount(hcount), .vcount(vcount),
        .x(SCORE_LABEL_X), .y(ROW1_LABEL_Y),
        .text({8'h45,8'h52,8'h4F,8'h43,8'h53}),
        .rgb(score_label_rgb),
        .on(score_label_on)
    );

    // HI-SCORE ? reversed: E R O C S - I H
    text_renderer #(.TEXT_LEN(8), .COLOR(12'h0FF)) hi_label (
        .hcount(hcount), .vcount(vcount),
        .x(HI_LABEL_X), .y(ROW1_LABEL_Y),
        .text({8'h45,8'h52,8'h4F,8'h43,8'h53,8'h2D,8'h49,8'h48}),
        .rgb(hi_label_rgb),
        .on(hi_label_on)
    );

    // LINES ? reversed: S E N I L
    text_renderer #(.TEXT_LEN(5), .COLOR(12'h0FF)) lines_label (
        .hcount(hcount), .vcount(vcount),
        .x(LINES_LABEL_X), .y(ROW2_LABEL_Y),
        .text({8'h53,8'h45,8'h4E,8'h49,8'h4C}),
        .rgb(lines_label_rgb),
        .on(lines_label_on)
    );

    // LEVEL ? reversed: L E V E L
    text_renderer #(.TEXT_LEN(5), .COLOR(12'h0FF)) level_label (
        .hcount(hcount), .vcount(vcount),
        .x(LEVEL_LABEL_X), .y(ROW2_LABEL_Y),
        .text({8'h4C,8'h45,8'h56,8'h45,8'h4C}),
        .rgb(level_label_rgb),
        .on(level_label_on)
    );

    //------------------------------------------------------------
    // DIGITS (ALL WIRES DECLARED)
    //------------------------------------------------------------
    wire score_digit_on, hi_on, lines_on, level_on;
    wire [11:0] score_digit_rgb, hi_rgb, lines_rgb, level_rgb;

    digit_renderer score_digits(
        .hcount(hcount),
        .vcount(vcount),
        .x(SCORE_DIGITS_X),
        .y(ROW1_DIGITS_Y),
        .d3(score_d3), .d2(score_d2), .d1(score_d1), .d0(score_d0),
        .rgb(score_digit_rgb),
        .on(score_digit_on)
    );

    digit_renderer hi_digits(
        .hcount(hcount),
        .vcount(vcount),
        .x(HI_DIGITS_X),
        .y(ROW1_DIGITS_Y),
        .d3(hi_d3), .d2(hi_d2), .d1(hi_d1), .d0(hi_d0),
        .rgb(hi_rgb),
        .on(hi_on)
    );

    digit_renderer lines_digits(
        .hcount(hcount),
        .vcount(vcount),
        .x(LINES_DIGITS_X),
        .y(ROW2_DIGITS_Y),
        .d3(lines_d3), .d2(lines_d2), .d1(lines_d1), .d0(lines_d0),
        .rgb(lines_rgb),
        .on(lines_on)
    );

    digit_renderer level_digits(
        .hcount(hcount),
        .vcount(vcount),
        .x(LEVEL_DIGITS_X),
        .y(ROW2_DIGITS_Y),
        .d3(level_d3), .d2(level_d2), .d1(level_d1), .d0(level_d0),
        .rgb(level_rgb),
        .on(level_on)
    );

    //------------------------------------------------------------
    // TITLE (unchanged)
    //------------------------------------------------------------
    wire title_on;
    wire [11:0] title_rgb;

    text_renderer #(.TEXT_LEN(11), .COLOR(12'hFFF)) title_text (
        .hcount(hcount),
        .vcount(vcount),
        .x(320 - (11*8)/2),
        .y(240 - 4),
        .text({"T","R","A","T","S"," ","S","S","E","R","P"}),
        .rgb(title_rgb),
        .on(title_on)
    );

    //------------------------------------------------------------
    // PARALLEL COLOR SELECT
    //------------------------------------------------------------
    reg [11:0] next_rgb;

    always @(*) begin
        next_rgb = 12'h000;

        if (!started) begin
            if (title_on)
                next_rgb = title_rgb;
        end else begin
            if (panel) next_rgb = PANEL_COLOR;

            if (score_digit_on) next_rgb = score_digit_rgb;
            if (hi_on)          next_rgb = hi_rgb;
            if (lines_on)       next_rgb = lines_rgb;
            if (level_on)       next_rgb = level_rgb;

            if (score_label_on) next_rgb = score_label_rgb;
            if (hi_label_on)    next_rgb = hi_label_rgb;
            if (lines_label_on) next_rgb = lines_label_rgb;
            if (level_label_on) next_rgb = level_label_rgb;

            if (border) next_rgb = BORDER_COLOR;
        end
    end

    //------------------------------------------------------------
    // PIPELINE STAGE
    //------------------------------------------------------------
    reg [11:0] rgb_stage;

    always @(posedge clk) begin
        if (pixel_tick)
            rgb_stage <= next_rgb;
    end

    //------------------------------------------------------------
    // FINAL OUTPUT
    //------------------------------------------------------------
    always @(posedge clk) begin
        if (!video_on)
            rgb <= 12'h000;
        else if (pixel_tick)
            rgb <= rgb_stage;
    end

endmodule
