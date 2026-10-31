`timescale 1ns / 1ps

module trig_top(
    input  wire       clk,
    input  wire       trig_enable,
    input  wire       pC,
    input  wire       pU,
    input  wire       pD,
    input  wire       pL,
    input  wire       pR,
    input  wire [3:0] digit,
    input  wire       digit_valid,
    input  wire       digit_conflict,
    input  wire [12:0] pixel_index,
    output wire [15:0] pixel_data
    );

    wire [9:0] angle;
    wire [1:0] function_select;
    wire signed [31:0] value;
    wire undefined;
    wire radian_mode;
    wire [2:0] digit_count;
    wire [3:0] pending_digit;
    wire pending_valid;

    trig_ctrl u_ctrl (
        .clk(clk),
        .pC(pC && trig_enable), .pU(pU && trig_enable),
        .pD(pD && trig_enable), .pL(pL && trig_enable),
        .pR(pR && trig_enable), .digit(digit),
        .digit_valid(digit_valid), .angle(angle),
        .function_select(function_select), .digit_count(digit_count),
        .radian_mode(radian_mode),
        .pending_digit(pending_digit), .pending_valid(pending_valid)
    );

    trig_lut u_lut (
        .angle(angle), .function_select(function_select),
        .radian_mode(radian_mode), .value(value),
        .undefined(undefined)
    );

    trig_display u_display (
        .pixel_index(pixel_index), .angle(angle), .value(value),
        .function_select(function_select), .radian_mode(radian_mode),
        .undefined(undefined),
        .pending_digit(pending_digit), .pending_valid(pending_valid),
        .digit_conflict(digit_conflict),
        .pixel_data(pixel_data)
    );
endmodule
