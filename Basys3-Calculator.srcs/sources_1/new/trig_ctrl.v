`timescale 1ns / 1ps

module trig_ctrl(
    input  wire       clk,
    input  wire       pC,
    input  wire       pU,
    input  wire       pD,
    input  wire       pL,
    input  wire       pR,
    input  wire [3:0] digit,
    input  wire       digit_valid,
    output reg  [9:0] angle = 10'd0,
    output reg  [1:0] function_select = 2'd0,
    output reg  [2:0] digit_count = 3'd0,
    output reg  [3:0] pending_digit = 4'd0,
    output reg        pending_valid = 1'b0,
    output reg        radian_mode = 1'b0
    );

    // Digits are entered one at a time, just like the number-representation
    // mode. U selects sine, R selects cosine, and D selects tangent.
    always @(posedge clk) begin
        // Keep the selected switch digit visible while it is held. This
        // allows the same digit to be confirmed repeatedly, e.g. 1, 11, 111.
        pending_digit <= digit;
        pending_valid <= digit_valid;

        if (pL) begin
            radian_mode <= ~radian_mode;
        end else if (pC && (!digit_valid || digit_count == 3'd3)) begin
            // btnC clears either an incomplete/complete entry with no usable
            // digit selected, or a completed three-digit entry.
            angle <= 10'd0;
            digit_count <= 3'd0;
            pending_valid <= digit_valid;
        end else if (pC && digit_valid) begin
            angle <= (angle * 10'd10) + digit;
            digit_count <= digit_count + 3'd1;
            pending_valid <= digit_valid;
        end else if (pU && digit_count != 3'd0) begin
            function_select <= 2'd0;
        end else if (pR && digit_count != 3'd0) begin
            function_select <= 2'd1;
        end else if (pD && digit_count != 3'd0) begin
            function_select <= 2'd2;
        end
    end
endmodule
