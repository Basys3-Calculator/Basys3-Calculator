`timescale 1ns / 1ps
// calc_fsm.v — input sequence: N1 -> btnC -> op -> btnC -> N2 -> btnC (evaluate)
//
// Runs on the 100 MHz clock. pC / pU are 1-cycle pulses from debounce.
// After evaluating it goes straight back to S_N1 with show_result = 1,
// so the answer stays on screen while the next N1 is entered.

module calc_fsm (
    input  wire       clk,
    input  wire       pC,            // confirm
    input  wire       pU,            // + (only op implemented so far)
    input  wire [3:0] digit,
    input  wire       digit_valid,

    output reg  [1:0] state       = 2'd0,
    output reg  [3:0] n1          = 4'd0,
    output reg  [1:0] op          = 2'd0,
    output reg        op_set      = 1'b0,   // an op has been picked in S_OP
    output reg  [3:0] n2          = 4'd0,
    output reg  [6:0] result      = 7'd0,   // 7 bits: room for 9x9 = 81 later
    output reg        show_result = 1'b0
);
    `include "calc_params.vh"

    // ---------------- ALU ----------------
    // Uses the live digit (not n2) so the answer is ready on the confirm cycle.
    reg [6:0] alu_out;
    always @(*) begin
        case (op)
            OP_ADD:  alu_out = n1 + digit;
            default: alu_out = 7'd0;        // SUB / MUL / DIV: not yet
        endcase
    end

    // ---------------- FSM ----------------
    always @(posedge clk) begin
        case (state)
            S_N1: begin
                if (pC && digit_valid) begin
                    n1          <= digit;
                    show_result <= 1'b0;     // clear old answer from top line
                    state       <= S_OP;
                end
            end

            S_OP: begin
                if (pU) begin
                    op     <= OP_ADD;
                    op_set <= 1'b1;
                end
                // later: pD -> OP_SUB, pL -> OP_MUL, pR -> OP_DIV
                if (pC && op_set) begin
                    op_set <= 1'b0;
                    state  <= S_N2;
                end
            end

            S_N2: begin
                if (pC && digit_valid) begin
                    n2          <= digit;
                    result      <= alu_out;
                    show_result <= 1'b1;
                    state       <= S_N1;
                end
            end

            default: state <= S_N1;
        endcase
    end

endmodule
