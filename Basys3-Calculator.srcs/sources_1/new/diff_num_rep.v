`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.10.2026 20:41:12
// Design Name: 
// Module Name: diff_num_rep
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module diff_num_rep (
    input  wire        clk,
    input  wire        pC,
    input  wire        pU,
    input  wire        pD,
    input  wire        pL,
    input  wire        pR,
    input  wire [3:0]  digit,
    input  wire        digit_valid,
    output reg  [11:0] value       = 12'd0,
    output reg  [2:0]  digit_count = 3'd0,
    output reg  [1:0]  view        = 2'd0
    );

    // The representation mode is kept separately from the entered value.
    // view: 0 = decimal, 1 = binary, 2 = octal, 3 = hexadecimal.
    // digit_count is needed so that leading zeroes entered by the user can
    // still be shown while the number is being entered.
    always @(posedge clk) begin
        if (pC) begin
            // btnC confirms another digit during entry. Once a representation
            // is being viewed, btnC starts a new number instead.
            if (view != 2'd0 || digit_count == 3'd3) begin
                value       <= 12'd0;
                digit_count <= 3'd0;
                view        <= 2'd0;
            end else if (digit_valid) begin
                // Append the new decimal digit: 12 followed by 3 becomes 123.
                value       <= (value * 12'd10) + digit;
                digit_count <= digit_count + 3'd1;
                view        <= 2'd0;
            end
        // A conversion button only has an effect after at least one digit.
        end else if (pU && digit_count != 3'd0) begin
            view <= 2'd1;
        end else if (pR && digit_count != 3'd0) begin
            view <= 2'd2;
        end else if (pD && digit_count != 3'd0) begin
            view <= 2'd3;
        end else if (pL && digit_count != 3'd0) begin
            view <= 2'd0;
        end
    end
endmodule
