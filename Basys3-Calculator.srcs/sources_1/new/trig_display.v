`timescale 1ns / 1ps

module trig_display(
    input  wire [12:0] pixel_index,
    input  wire [9:0] angle,
    input  wire signed [31:0] value,
    input  wire [1:0] function_select,
    input  wire       radian_mode,
    input  wire       undefined,
    input  wire [3:0] pending_digit,
    input  wire       pending_valid,
    input  wire       digit_conflict,
    output wire [15:0] pixel_data
    );

    wire [6:0] x = pixel_index % 96;
    wire [5:0] y = pixel_index / 96;
    wire [3:0] col = x[6:3];
    wire [3:0] row = y[5:3];
    wire [2:0] gx = x[2:0];
    wire [2:0] gy = y[2:0];
    wire [5:0] char_code;
    wire [7:0] font_bits;

    trig_text u_text (
        .angle(angle), .value(value), .function_select(function_select),
        .radian_mode(radian_mode),
        .undefined(undefined),
        .pending_digit(pending_digit), .pending_valid(pending_valid),
        .digit_conflict(digit_conflict),
        .row(row), .col(col), .char_code(char_code)
    );

    font_rom u_font (
        .char_code(char_code), .row(gy), .bits(font_bits)
    );

    // RGB565 text colors: reddish orange for the digit-conflict warning and
    // cyan for the pending bottom-left digit.
    wire [15:0] text_color =
        (digit_conflict && (row == 4'd6 || row == 4'd7)) ? 16'hFBE0 :
        ((pending_valid && row == 4'd7 && col == 4'd0) ? 16'h07FF : 16'hFFFF);

    assign pixel_data = font_bits[7-gx] ? text_color : 16'h0000;
endmodule
