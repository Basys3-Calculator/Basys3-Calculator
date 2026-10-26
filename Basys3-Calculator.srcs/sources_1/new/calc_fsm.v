`timescale 1ns / 1ps
// calc_fsm.v - input sequence: N1 -> btnC -> op -> btnC -> N2 -> btnC (evaluate)
//
// Every finished equation is pushed into a 7-entry history buffer.
// Entry layout (18 bits): {n1[3:0], op[1:0], n2[3:0], result[7:0]}
// hist_flat[i*18 +: 18] is entry i (0 = oldest). hist_count = entries stored (0..7).
// When the buffer is full and a new equation is started, the oldest entry is dropped.

module calc_fsm (
    input  wire       clk,
    input  wire       pC,            // confirm
    input  wire       pU,
    input  wire       pD,
    input  wire       pL,
    input  wire       pR,
    input  wire signed [5:0] digit,
    input  wire       digit_valid,

    output reg  [1:0] state       = 2'd0,
    output reg signed [4:0] n1    = 5'sd0,
    output reg  [1:0] op          = 2'd0,
    output reg        op_set      = 1'b0,
    output reg [7*18-1:0] hist_flat  = 0,
    output reg [2:0]      hist_count = 3'd0
);
    `include "calc_params.vh"

    integer i;

    // ---------------- ALU ----------------
    reg signed [7:0] alu_out;
    always @(*) begin
        case (op)
            OP_ADD:  alu_out = n1 + digit;
            OP_SUB:  alu_out = n1 - digit;
            OP_MUL:  alu_out = n1 * digit;
            OP_DIV:  alu_out = (digit != 0) ? (n1 / digit) : 8'sd0;
            default: alu_out = 8'sd0;
        endcase
    end

    // ---------------- FSM ----------------
    always @(posedge clk) begin
        case (state)
            S_N1: begin
                if (pC && digit_valid) begin
                    n1    <= digit;
                    state <= S_OP;
                    // history full -> scroll up, freeing the last row (row 6)
                    if (hist_count == 3'd7) begin
                        for (i = 0; i < 6; i = i + 1)
                            hist_flat[i*18 +: 18] <= hist_flat[(i+1)*18 +: 18];
                        hist_count <= 3'd6;
                    end
                end
            end

            S_OP: begin
                if      (pU) begin op <= OP_ADD; op_set <= 1'b1; end
                else if (pD) begin op <= OP_SUB; op_set <= 1'b1; end
                else if (pL) begin op <= OP_MUL; op_set <= 1'b1; end
                else if (pR) begin op <= OP_DIV; op_set <= 1'b1; end

                if (pC && op_set) begin
                    op_set <= 1'b0;
                    state  <= S_N2;
                end
            end

            S_N2: begin
                if (pC && digit_valid) begin
                    // store finished equation in the next free row, then move down
                    hist_flat[hist_count*18 +: 18] <= {n1[3:0], op, digit[3:0], alu_out};
                    hist_count <= hist_count + 3'd1;
                    state      <= S_N1;
                end
            end

            default: state <= S_N1;
        endcase
    end
endmodule
