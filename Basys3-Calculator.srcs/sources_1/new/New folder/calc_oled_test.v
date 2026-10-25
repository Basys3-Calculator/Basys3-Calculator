`timescale 1ns / 1ps
// calc_oled_test.v — hardware test for font_rom + text layout + sw_encoder
//
// Expected on the OLED (2x scaled, 6 chars x 4 rows of 16x16 cells):
//   row 0 : 5+3=8         (hardcoded)
//   row 3 : live digit from sw0-9, blank if 0 or >1 switches are on
//
// Set this as the top module for the test; swap back afterwards.

module calc_oled_test (
    input  wire        clk,
    input  wire [15:0] sw,
    output wire [7:0]  JB
);
    `include "chars.vh"

    // ---------------- clocks ----------------
    wire clk6p25m;
    slow_clock u_clk6p25m (
        .clk        (clk),
        .SLOW_CLOCK (clk6p25m)
    );

    // ---------------- switch input ----------------
    wire [3:0] digit;
    wire       digit_valid;
    sw_encoder u_sw (
        .sw          (sw[9:0]),
        .digit       (digit),
        .digit_valid (digit_valid)
    );

    // ---------------- pixel -> character cell ----------------
    wire [12:0] pixel_index;
    wire [6:0]  x = pixel_index % 96;   // 0..95
    wire [5:0]  y = pixel_index / 96;   // 0..63

    wire [2:0] char_col = x[6:4];       // 0..5  (16 px per cell)
    wire [1:0] char_row = y[5:4];       // 0..3
    wire [2:0] gx       = x[3:1];       // 0..7  (2x scale: drop bit 0)
    wire [2:0] gy       = y[3:1];

    // ---------------- character map ----------------
    reg [3:0] char_code;
    always @(*) begin
        char_code = CH_SPACE;
        if (char_row == 2'd0) begin
            case (char_col)
                3'd0: char_code = CH_5;
                3'd1: char_code = CH_PLUS;
                3'd2: char_code = CH_3;
                3'd3: char_code = CH_EQ;
                3'd4: char_code = CH_8;
                default: char_code = CH_SPACE;
            endcase
        end
        else if (char_row == 2'd3 && char_col == 3'd0 && digit_valid)
            char_code = digit;           // digit value == its char code
    end

    // ---------------- font lookup ----------------
    wire [7:0] font_row;
    font_rom u_font (
        .char_code (char_code),
        .row       (gy),
        .bits      (font_row)
    );

    wire [15:0] oled_data = font_row[7 - gx] ? 16'hFFFF : 16'h0000;

    // ---------------- OLED ----------------
    Oled_Display u_oled (
        .clk         (clk6p25m),
        .reset       (1'b0),            // NOT btnC — btnC is the confirm button later
        .pixel_index (pixel_index),
        .pixel_data  (oled_data),
        .cs          (JB[0]),
        .sdin        (JB[1]),
        .sclk        (JB[3]),
        .d_cn        (JB[4]),
        .resn        (JB[5]),
        .vccen       (JB[6]),
        .pmoden      (JB[7])
    );
    assign JB[2] = 1'b0;

endmodule
