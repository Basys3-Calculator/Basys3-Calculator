`timescale 1ns / 1ps
// font_rom.v - 8x8 glyphs for digits, operators, labels, and hexadecimal
//
// Digits 0-9 have char codes equal to their value, so a 4-bit digit
// can be fed straight in as char_code.
//
// row  : 0 = top row of the glyph, 7 = bottom
// bits : bits[7] = leftmost pixel, bits[0] = rightmost
//        -> in the renderer: pixel_on = bits[7 - gx];
//
// Each glyph is 64 bits, top row in the most significant byte.
// Purely combinational - fine at the 6.25 MHz OLED clock.

module font_rom (
    input  wire [5:0] char_code,
    input  wire [2:0] row,
    output wire [7:0] bits
);
    `include "chars.vh"

    reg [63:0] glyph;

    always @(*) begin
        case (char_code)
            CH_0:     glyph = 64'h3C_66_6E_76_66_66_3C_00;
            CH_1:     glyph = 64'h18_38_18_18_18_18_7E_00;
            CH_2:     glyph = 64'h3C_66_06_0C_30_60_7E_00;
            CH_3:     glyph = 64'h3C_66_06_1C_06_66_3C_00;
            CH_4:     glyph = 64'h0C_1C_3C_6C_7E_0C_0C_00;
            CH_5:     glyph = 64'h7E_60_7C_06_06_66_3C_00;
            CH_6:     glyph = 64'h3C_66_60_7C_66_66_3C_00;
            CH_7:     glyph = 64'h7E_06_0C_18_18_18_18_00;
            CH_8:     glyph = 64'h3C_66_66_3C_66_66_3C_00;
            CH_9:     glyph = 64'h3C_66_66_3E_06_66_3C_00;
            CH_PLUS:  glyph = 64'h00_18_18_7E_18_18_00_00;
            CH_MINUS: glyph = 64'h00_00_00_7E_00_00_00_00;
            CH_MUL:   glyph = 64'h00_66_3C_18_3C_66_00_00;
            CH_DIV:   glyph = 64'h00_18_00_7E_00_18_00_00;
            CH_EQ:    glyph = 64'h00_00_7E_00_7E_00_00_00;
            CH_A:     glyph = 64'h18_3C_66_66_7E_66_66_00;
            CH_B:     glyph = 64'h7C_66_66_7C_66_66_7C_00;
            CH_C:     glyph = 64'h3C_66_60_60_60_66_3C_00;
            CH_D:     glyph = 64'h78_6C_66_66_66_6C_78_00;
            CH_E:     glyph = 64'h7E_60_60_7C_60_60_7E_00;
            CH_F:     glyph = 64'h7E_60_60_7C_60_60_60_00;
            CH_H:     glyph = 64'h66_66_66_7E_66_66_66_00;
            CH_I:     glyph = 64'h7E_18_18_18_18_18_7E_00;
            CH_N:     glyph = 64'h66_76_7E_6E_66_66_66_00;
            CH_O:     glyph = 64'h3C_66_66_66_66_66_3C_00;
            CH_T:     glyph = 64'h7E_18_18_18_18_18_18_00;
            CH_X:     glyph = 64'h66_66_3C_18_3C_66_66_00;
            CH_COLON: glyph = 64'h00_18_18_00_00_18_18_00;
            CH_L:     glyph = 64'h60_60_60_60_60_60_7E_00;
            CH_M:     glyph = 64'h63_77_7F_6B_63_63_63_00;
            CH_P:     glyph = 64'h7C_66_66_7C_60_60_60_00;
            CH_R:     glyph = 64'h7C_66_66_7C_78_6C_66_00;
            CH_S:     glyph = 64'h3C_66_60_3C_06_66_3C_00;
            CH_U:     glyph = 64'h66_66_66_66_66_66_3C_00;
            CH_W:     glyph = 64'h63_63_63_6B_7F_77_63_00;
            default:  glyph = 64'h00_00_00_00_00_00_00_00;   // CH_SPACE
        endcase
    end

    // Select one 8-bit row: row 0 -> glyph[63:56], row 7 -> glyph[7:0]
    assign bits = glyph[63 - {row, 3'b000} -: 8];

endmodule
