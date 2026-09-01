`timescale 1ns / 1ps

module vga_controller(
    input wire clk,
    input wire reset,        // ACTIVE-LOW RESET
    input wire pixel_tick,
    output wire hsync,
    output wire vsync,
    output wire video_on,
    output wire [9:0] x,
    output wire [9:0] y
);

    // Horizontal timing
    localparam H_DISPLAY = 640;
    localparam H_FP      = 16;
    localparam H_SYNC    = 96;
    localparam H_BP      = 48;
    localparam H_TOTAL   = 800;

    // Vertical timing
    localparam V_DISPLAY = 480;
    localparam V_FP      = 10;
    localparam V_SYNC    = 2;
    localparam V_BP      = 33;
    localparam V_TOTAL   = 525;

    reg [9:0] h_count = 0;
    reg [9:0] v_count = 0;

    // ------------------------------------------------------------
    // ACTIVE-LOW RESET
    // ------------------------------------------------------------
    always @(posedge clk) begin
    if (!reset) begin
        h_count <= 0;
        v_count <= 0;
    end 
    else if (pixel_tick) begin
        if (h_count == H_TOTAL - 1) begin
            h_count <= 0;
            if (v_count == V_TOTAL - 1)
                v_count <= 0;
            else
                v_count <= v_count + 1;
        end 
        else begin
            h_count <= h_count + 1;
        end
    end
end


    // Sync pulses (active LOW)
    assign hsync = ~((h_count >= (H_DISPLAY + H_FP)) &&
                     (h_count <  (H_DISPLAY + H_FP + H_SYNC)));

    assign vsync = ~((v_count >= (V_DISPLAY + V_FP)) &&
                     (v_count <  (V_DISPLAY + V_FP + V_SYNC)));

    // Visible area
    assign video_on = (h_count < H_DISPLAY) && (v_count < V_DISPLAY);

    assign x = h_count;
    assign y = v_count;

endmodule
