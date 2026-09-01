`timescale 1ns / 1ps

module font8x8(
    input  [7:0] char,
    input  [2:0] row,
    output reg [7:0] bits
);

always @(*) begin
    bits = 8'b00000000;

    case (char)

    // ---------------------------------------------------------
    // SPACE
    // ---------------------------------------------------------
    " ": case(row)
        0,1,2,3,4,5,6,7: bits = 8'b00000000;
    endcase

    // ---------------------------------------------------------
    // DASH '-'
    // ---------------------------------------------------------
    "-": case(row)
        0,1,2,5,6,7: bits = 8'b00000000;
        3,4: bits = 8'b01111110;
    endcase

    // ---------------------------------------------------------
    // DIGITS 0-9
    // ---------------------------------------------------------
    "0": case(row)
        0: bits = 8'b00111100;
        1: bits = 8'b01100110;
        2: bits = 8'b01101110;
        3: bits = 8'b01110110;
        4: bits = 8'b01100110;
        5: bits = 8'b01100110;
        6: bits = 8'b00111100;
        7: bits = 8'b00000000;
    endcase

    "1": case(row)
        0: bits = 8'b00011000;
        1: bits = 8'b00111000;
        2: bits = 8'b00011000;
        3: bits = 8'b00011000;
        4: bits = 8'b00011000;
        5: bits = 8'b00011000;
        6: bits = 8'b01111110;
        7: bits = 8'b00000000;
    endcase

    "2": case(row)
        0: bits = 8'b00111100;
        1: bits = 8'b01100110;
        2: bits = 8'b00000110;
        3: bits = 8'b00011100;
        4: bits = 8'b00110000;
        5: bits = 8'b01100000;
        6: bits = 8'b01111110;
        7: bits = 8'b00000000;
    endcase

    "3": case(row)
        0: bits = 8'b00111100;
        1: bits = 8'b01100110;
        2: bits = 8'b00000110;
        3: bits = 8'b00011100;
        4: bits = 8'b00000110;
        5: bits = 8'b01100110;
        6: bits = 8'b00111100;
        7: bits = 8'b00000000;
    endcase

    "4": case(row)
        0: bits = 8'b00001100;
        1: bits = 8'b00011100;
        2: bits = 8'b00101100;
        3: bits = 8'b01001100;
        4: bits = 8'b01111110;
        5: bits = 8'b00001100;
        6: bits = 8'b00001100;
        7: bits = 8'b00000000;
    endcase

    "5": case(row)
        0: bits = 8'b01111110;
        1: bits = 8'b01100000;
        2: bits = 8'b01111100;
        3: bits = 8'b00000110;
        4: bits = 8'b00000110;
        5: bits = 8'b01100110;
        6: bits = 8'b00111100;
        7: bits = 8'b00000000;
    endcase

    "6": case(row)
        0: bits = 8'b00111100;
        1: bits = 8'b01100110;
        2: bits = 8'b01100000;
        3: bits = 8'b01111100;
        4: bits = 8'b01100110;
        5: bits = 8'b01100110;
        6: bits = 8'b00111100;
        7: bits = 8'b00000000;
    endcase

    "7": case(row)
        0: bits = 8'b01111110;
        1: bits = 8'b00000110;
        2: bits = 8'b00001100;
        3: bits = 8'b00011000;
        4: bits = 8'b00110000;
        5: bits = 8'b00110000;
        6: bits = 8'b00110000;
        7: bits = 8'b00000000;
    endcase

    "8": case(row)
        0: bits = 8'b00111100;
        1: bits = 8'b01100110;
        2: bits = 8'b01100110;
        3: bits = 8'b00111100;
        4: bits = 8'b01100110;
        5: bits = 8'b01100110;
        6: bits = 8'b00111100;
        7: bits = 8'b00000000;
    endcase

    "9": case(row)
        0: bits = 8'b00111100;
        1: bits = 8'b01100110;
        2: bits = 8'b01100110;
        3: bits = 8'b00111110;
        4: bits = 8'b00000110;
        5: bits = 8'b01100110;
        6: bits = 8'b00111100;
        7: bits = 8'b00000000;
    endcase

    // ---------------------------------------------------------
    // LETTERS A-Z
    // ---------------------------------------------------------

    "A": case(row)
        0: bits = 8'b00111100;
        1: bits = 8'b01100110;
        2: bits = 8'b01100110;
        3: bits = 8'b01111110;
        4: bits = 8'b01100110;
        5: bits = 8'b01100110;
        6: bits = 8'b01100110;
        7: bits = 8'b00000000;
        default: bits = 8'b00000000;
    endcase

    "B": case(row)
        0: bits = 8'b01111100;
        1: bits = 8'b01100110;
        2: bits = 8'b01100110;
        3: bits = 8'b01111100;
        4: bits = 8'b01100110;
        5: bits = 8'b01100110;
        6: bits = 8'b01111100;
        7: bits = 8'b00000000;
        default: bits = 8'b00000000;
    endcase

    "C": case(row)
        0: bits = 8'b00111100;
        1: bits = 8'b01100110;
        2: bits = 8'b01100000;
        3: bits = 8'b01100000;
        4: bits = 8'b01100000;
        5: bits = 8'b01100110;
        6: bits = 8'b00111100;
        7: bits = 8'b00000000;
        default: bits = 8'b00000000;
    endcase

    "D": case(row)
        0: bits = 8'b01111000;
        1: bits = 8'b01101100;
        2: bits = 8'b01100110;
        3: bits = 8'b01100110;
        4: bits = 8'b01100110;
        5: bits = 8'b01101100;
        6: bits = 8'b01111000;
        7: bits = 8'b00000000;
        default: bits = 8'b00000000;
    endcase

    "E": case(row)
        0: bits = 8'b01111110;
        1: bits = 8'b01100000;
        2: bits = 8'b01100000;
        3: bits = 8'b01111100;
        4: bits = 8'b01100000;
        5: bits = 8'b01100000;
        6: bits = 8'b01111110;
        7: bits = 8'b00000000;
        default: bits = 8'b00000000;
    endcase

    "F": case(row)
        0: bits = 8'b01111110;
        1: bits = 8'b01100000;
        2: bits = 8'b01100000;
        3: bits = 8'b01111100;
        4: bits = 8'b01100000;
        5: bits = 8'b01100000;
        6: bits = 8'b01100000;
        7: bits = 8'b00000000;
        default: bits = 8'b00000000;
    endcase

    "G": case(row)
        0: bits = 8'b00111100;
        1: bits = 8'b01100110;
        2: bits = 8'b01100000;
        3: bits = 8'b01101110;
        4: bits = 8'b01100110;
        5: bits = 8'b01100110;
        6: bits = 8'b00111100;
        7: bits = 8'b00000000;
        default: bits = 8'b00000000;
    endcase

    "H": case(row)
        0: bits = 8'b01100110;
        1: bits = 8'b01100110;
        2: bits = 8'b01100110;
        3: bits = 8'b01111110;
        4: bits = 8'b01100110;
        5: bits = 8'b01100110;
        6: bits = 8'b01100110;
        7: bits = 8'b00000000;
        default: bits = 8'b00000000;
    endcase

    "I": case(row)
        0: bits = 8'b00111100;
        1: bits = 8'b00011000;
        2: bits = 8'b00011000;
        3: bits = 8'b00011000;
        4: bits = 8'b00011000;
        5: bits = 8'b00011000;
        6: bits = 8'b00111100;
        7: bits = 8'b00000000;
        default: bits = 8'b00000000;
    endcase

    "J": case(row)
        0: bits = 8'b00011110;
        1: bits = 8'b00001100;
        2: bits = 8'b00001100;
        3: bits = 8'b00001100;
        4: bits = 8'b01101100;
        5: bits = 8'b01101100;
        6: bits = 8'b00111000;
        7: bits = 8'b00000000;
        default: bits = 8'b00000000;
    endcase

    "K": case(row)
        0: bits = 8'b01100110;
        1: bits = 8'b01101100;
        2: bits = 8'b01111000;
        3: bits = 8'b01110000;
        4: bits = 8'b01111000;
        5: bits = 8'b01101100;
        6: bits = 8'b01100110;
        7: bits = 8'b00000000;
        default: bits = 8'b00000000;
    endcase

    "L": case(row)
        0: bits = 8'b01100000;
        1: bits = 8'b01100000;
        2: bits = 8'b01100000;
        3: bits = 8'b01100000;
        4: bits = 8'b01100000;
        5: bits = 8'b01100000;
        6: bits = 8'b01111110;
        7: bits = 8'b00000000;
        default: bits = 8'b00000000;
    endcase

    "M": case(row)
        0: bits = 8'b01100011;
        1: bits = 8'b01110111;
        2: bits = 8'b01111111;
        3: bits = 8'b01101011;
        4: bits = 8'b01100011;
        5: bits = 8'b01100011;
        6: bits = 8'b01100011;
        7: bits = 8'b00000000;
        default: bits = 8'b00000000;
    endcase

    "N": case(row)
        0: bits = 8'b01100011;
        1: bits = 8'b01110011;
        2: bits = 8'b01111011;
        3: bits = 8'b01101111;
        4: bits = 8'b01100111;
        5: bits = 8'b01100011;
        6: bits = 8'b01100011;
        7: bits = 8'b00000000;
        default: bits = 8'b00000000;
    endcase

    "O": case(row)
        0: bits = 8'b00111100;
        1: bits = 8'b01100110;
        2: bits = 8'b01100110;
        3: bits = 8'b01100110;
        4: bits = 8'b01100110;
        5: bits = 8'b01100110;
        6: bits = 8'b00111100;
        7: bits = 8'b00000000;
        default: bits = 8'b00000000;
    endcase

    "P": case(row)
        0: bits = 8'b01111100;
        1: bits = 8'b01100110;
        2: bits = 8'b01100110;
        3: bits = 8'b01111100;
        4: bits = 8'b01100000;
        5: bits = 8'b01100000;
        6: bits = 8'b01100000;
        7: bits = 8'b00000000;
        default: bits = 8'b00000000;
    endcase

    "Q": case(row)
        0: bits = 8'b00111100;
        1: bits = 8'b01100110;
        2: bits = 8'b01100110;
        3: bits = 8'b01100110;
        4: bits = 8'b01101110;
        5: bits = 8'b00111100;
        6: bits = 8'b00001110;
        7: bits = 8'b00000000;
        default: bits = 8'b00000000;
    endcase

    "R": case(row)
        0: bits = 8'b01111100;
        1: bits = 8'b01100110;
        2: bits = 8'b01100110;
        3: bits = 8'b01111100;
        4: bits = 8'b01111000;
        5: bits = 8'b01101100;
        6: bits = 8'b01100110;
        7: bits = 8'b00000000;
        default: bits = 8'b00000000;
    endcase

    "S": case(row)
        0: bits = 8'b00111110;
        1: bits = 8'b01100000;
        2: bits = 8'b01111000;
        3: bits = 8'b00011100;
        4: bits = 8'b00000110;
        5: bits = 8'b01100110;
        6: bits = 8'b00111100;
        7: bits = 8'b00000000;
        default: bits = 8'b00000000;
    endcase

    "T": case(row)
        0: bits = 8'b01111110;
        1: bits = 8'b00011000;
        2: bits = 8'b00011000;
        3: bits = 8'b00011000;
        4: bits = 8'b00011000;
        5: bits = 8'b00011000;
        6: bits = 8'b00011000;
        7: bits = 8'b00000000;
        default: bits = 8'b00000000;
    endcase

    "U": case(row)
        0: bits = 8'b01100110;
        1: bits = 8'b01100110;
        2: bits = 8'b01100110;
        3: bits = 8'b01100110;
        4: bits = 8'b01100110;
        5: bits = 8'b01100110;
        6: bits = 8'b00111100;
        7: bits = 8'b00000000;
        default: bits = 8'b00000000;
    endcase

    "V": case(row)
        0: bits = 8'b01100110;
        1: bits = 8'b01100110;
        2: bits = 8'b01100110;
        3: bits = 8'b01100110;
        4: bits = 8'b00111100;
        5: bits = 8'b00111100;
        6: bits = 8'b00011000;
        7: bits = 8'b00000000;
        default: bits = 8'b00000000;
    endcase

     "W": case(row)
        0: bits = 8'b01100011;
        1: bits = 8'b01100011;
        2: bits = 8'b01101011;
        3: bits = 8'b01111111;
        4: bits = 8'b01110111;
        5: bits = 8'b01100011;
        6: bits = 8'b01100011;
        7: bits = 8'b00000000;
        default: bits = 8'b00000000;
    endcase

    "X": case(row)
        0: bits = 8'b01100110;
        1: bits = 8'b00111100;
        2: bits = 8'b00011000;
        3: bits = 8'b00011000;
        4: bits = 8'b00111100;
        5: bits = 8'b01100110;
        6: bits = 8'b01100110;
        7: bits = 8'b00000000;
        default: bits = 8'b00000000;
    endcase

    "Y": case(row)
        0: bits = 8'b01100110;
        1: bits = 8'b01100110;
        2: bits = 8'b00111100;
        3: bits = 8'b00011000;
        4: bits = 8'b00011000;
        5: bits = 8'b00011000;
        6: bits = 8'b00011000;
        7: bits = 8'b00000000;
        default: bits = 8'b00000000;
    endcase

    "Z": case(row)
        0: bits = 8'b01111110;
        1: bits = 8'b00000110;
        2: bits = 8'b00001100;
        3: bits = 8'b00011000;
        4: bits = 8'b00110000;
        5: bits = 8'b01100000;
        6: bits = 8'b01111110;
        7: bits = 8'b00000000;
        default: bits = 8'b00000000;
    endcase

    default: bits = 8'b00000000;

    endcase
end

endmodule
