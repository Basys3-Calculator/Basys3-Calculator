`timescale 1ns / 1ps
module poly_fsm (
    input wire clk, input wire pC, input wire pU, input wire pD,
    input wire pL, input wire pR, input wire [3:0] digit,
    input wire digit_valid, input wire sw_neg, input wire solver_done,
    output reg [2:0] state = 3'd0,
    output reg quad = 1'b0, output reg mode_set = 1'b0,
    output reg a_neg = 1'b0, output reg [3:0] a_mag = 4'd0,
    output reg b_neg = 1'b0, output reg [3:0] b_mag = 4'd0,
    output reg c_neg = 1'b0, output reg [3:0] c_mag = 4'd0,
    output reg solve_start = 1'b0
);
    `include "poly_params.vh"
    wire neg_ok = sw_neg && (digit != 4'd0);
    always @(posedge clk) begin
        solve_start <= 1'b0;
        if (pL) begin state <= P_S_MODE; mode_set <= 1'b0; end
        else case (state)
            P_S_MODE: begin
                if (pU) begin quad <= 1'b0; mode_set <= 1'b1; end
                else if (pD) begin quad <= 1'b1; mode_set <= 1'b1; end
                if (pC && mode_set) state <= P_S_A;
            end
            P_S_A: if (pC && digit_valid) begin a_neg<=neg_ok; a_mag<=digit; state<=P_S_B; end
            P_S_B: if (pC && digit_valid) begin
                b_neg<=neg_ok; b_mag<=digit;
                if (quad) state<=P_S_C;
                else begin solve_start<=1'b1; state<=P_S_CALC; end
            end
            P_S_C: if (pC && digit_valid) begin
                c_neg<=neg_ok; c_mag<=digit; solve_start<=1'b1; state<=P_S_CALC;
            end
            P_S_CALC: if (solver_done) state <= P_S_RES;
            P_S_RES: if (pC) begin state<=P_S_MODE; mode_set<=1'b0; end
            default: state <= P_S_MODE;
        endcase
    end
endmodule
