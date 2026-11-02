`timescale 1ns / 1ps
// err_display.v - shows "Err0" .. "Err3" on the Basys 3 seven-segment display.
// The display is blank when err_valid is 0.
//
// Basys 3 seven-segment pins are active-low:
//   seg = {g, f, e, d, c, b, a}   (seg[0] = CA ... seg[6] = CG)
//   an[3] = leftmost digit, an[0] = rightmost digit
//
// Error codes (decided in calc_top):
//   0 = more than one mode switch on      (Err0)
//   1 = more than one digit switch on     (Err1)
//   2 = division by zero                  (Err2)
//   3 = tan undefined, e.g. 90 / 270 deg  (Err3)

module err_display (
    input  wire       clk,         // 100 MHz
    input  wire       err_valid,
    input  wire [1:0] err_code,
    output reg  [6:0] seg = 7'b1111111,
    output reg  [3:0] an  = 4'b1111,
    output wire       dp
);
    //                        gfedcba
    localparam [6:0] SEG_E   = 7'b0000110,
                     SEG_r   = 7'b0101111,
                     SEG_0   = 7'b1000000,
                     SEG_1   = 7'b1111001,
                     SEG_2   = 7'b0100100,
                     SEG_3   = 7'b0110000,
                     SEG_OFF = 7'b1111111;

    // Multiplex the four digits. refresh[17:16] changes every 2^16 clocks,
    // so each digit is lit for ~655 us and the whole display refreshes at
    // ~381 Hz - fast enough that all four digits look continuously on.
    reg [17:0] refresh = 18'd0;
    always @(posedge clk) refresh <= refresh + 18'd1;
    wire [1:0] sel = refresh[17:16];

    reg [6:0] code_seg;
    always @(*) begin
        case (err_code)
            2'd0:    code_seg = SEG_0;
            2'd1:    code_seg = SEG_1;
            2'd2:    code_seg = SEG_2;
            default: code_seg = SEG_3;
        endcase
    end

    // seg and an are registered together so a digit never shows the
    // previous digit's pattern (no ghosting).
    always @(posedge clk) begin
        if (!err_valid) begin
            an  <= 4'b1111;
            seg <= SEG_OFF;
        end else begin
            case (sel)
                2'd0:    begin an <= 4'b0111; seg <= SEG_E;    end  // leftmost: E
                2'd1:    begin an <= 4'b1011; seg <= SEG_r;    end  // r
                2'd2:    begin an <= 4'b1101; seg <= SEG_r;    end  // r
                default: begin an <= 4'b1110; seg <= code_seg; end  // rightmost: code
            endcase
        end
    end

    assign dp = 1'b1;   // decimal point off
endmodule

