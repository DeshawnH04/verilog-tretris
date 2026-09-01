`timescale 1ns / 1ps

module bin16_to_bcd4(
    input  wire       clk,
    input  wire       reset,
    input  wire [15:0] binary,
    output reg  [3:0] d3,
    output reg  [3:0] d2,
    output reg  [3:0] d1,
    output reg  [3:0] d0
);

    reg [15:0] last_binary;
    reg [15:0] shift_reg;
    reg [3:0]  bcd3, bcd2, bcd1, bcd0;
    reg [4:0]  count;
    reg        busy;

    reg [3:0] n3, n2, n1, n0;
    reg [15:0] sr_next;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            last_binary <= 16'd0;
            shift_reg   <= 16'd0;
            bcd3        <= 4'd0;
            bcd2        <= 4'd0;
            bcd1        <= 4'd0;
            bcd0        <= 4'd0;
            d3          <= 4'd0;
            d2          <= 4'd0;
            d1          <= 4'd0;
            d0          <= 4'd0;
            count       <= 5'd0;
            busy        <= 1'b0;
        end else begin
            if (!busy) begin
                if (binary != last_binary) begin
                    last_binary <= binary;
                    shift_reg   <= binary;
                    bcd3        <= 4'd0;
                    bcd2        <= 4'd0;
                    bcd1        <= 4'd0;
                    bcd0        <= 4'd0;
                    count       <= 5'd16;
                    busy        <= 1'b1;
                end
            end else begin
                n3 = (bcd3 >= 5) ? (bcd3 + 4'd3) : bcd3;
                n2 = (bcd2 >= 5) ? (bcd2 + 4'd3) : bcd2;
                n1 = (bcd1 >= 5) ? (bcd1 + 4'd3) : bcd1;
                n0 = (bcd0 >= 5) ? (bcd0 + 4'd3) : bcd0;

                sr_next = {shift_reg[14:0], 1'b0};

                bcd3 <= {n3[2:0], n2[3]};
                bcd2 <= {n2[2:0], n1[3]};
                bcd1 <= {n1[2:0], n0[3]};
                bcd0 <= {n0[2:0], shift_reg[15]};
                shift_reg <= sr_next;

                if (count == 5'd1) begin
                    d3   <= {n3[2:0], n2[3]};
                    d2   <= {n2[2:0], n1[3]};
                    d1   <= {n1[2:0], n0[3]};
                    d0   <= {n0[2:0], shift_reg[15]};
                    busy <= 1'b0;
                    count <= 5'd0;
                end else begin
                    count <= count - 5'd1;
                end
            end
        end
    end

endmodule