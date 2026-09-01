module tetris_grid_renderer #(
    parameter CELL_SIZE = 16,
    parameter GRID_X = 80,     // left edge of playfield
    parameter GRID_Y = 40      // top edge of playfield
)(
    input  wire [9:0] hcount,
    input  wire [9:0] vcount,
    input  wire       video_on,
    input  wire       started,
    output reg  [11:0] rgb,
    output reg        on
);

    localparam GRID_W = 10 * CELL_SIZE;
    localparam GRID_H = 20 * CELL_SIZE;

    wire inside_grid =
        (hcount >= GRID_X) &&
        (hcount <  GRID_X + GRID_W) &&
        (vcount >= GRID_Y) &&
        (vcount <  GRID_Y + GRID_H);

    // local coordinates
    wire [9:0] gx = hcount - GRID_X;
    wire [9:0] gy = vcount - GRID_Y;

    // grid lines every 16 pixels
    wire vertical_line   = (gx % CELL_SIZE) == 0;
    wire horizontal_line = (gy % CELL_SIZE) == 0;

    always @(*) begin
        on  = 0;
        rgb = 12'h000;

        if (video_on && started && inside_grid) begin
            if (vertical_line || horizontal_line) begin
                on  = 1;
                rgb = 12'h333;   // dim gray grid lines
            end
        end
    end

endmodule
