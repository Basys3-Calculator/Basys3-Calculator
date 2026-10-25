`timescale 1ns / 1ps
// sw_encoder.v — sw[9:0] one-hot -> digit 0-9
// digit_valid = 1 only when exactly one of sw0-sw9 is on.

module sw_encoder (
    input  wire [9:0] sw,
    output reg  [3:0] digit,
    output reg        digit_valid
);
    always @(*) begin
        digit_valid = 1'b1;
        case (sw)
            10'b0000000001: digit = 4'd0;
            10'b0000000010: digit = 4'd1;
            10'b0000000100: digit = 4'd2;
            10'b0000001000: digit = 4'd3;
            10'b0000010000: digit = 4'd4;
            10'b0000100000: digit = 4'd5;
            10'b0001000000: digit = 4'd6;
            10'b0010000000: digit = 4'd7;
            10'b0100000000: digit = 4'd8;
            10'b1000000000: digit = 4'd9;
            default: begin
                digit       = 4'd0;
                digit_valid = 1'b0;
            end
        endcase
    end
endmodule
