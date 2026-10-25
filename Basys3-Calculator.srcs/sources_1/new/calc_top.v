`timescale 1ns / 1ps
// calc_top.v — addition mode: N1 -> btnC -> btnU (+) -> btnC -> N2 -> btnC
//
// OLED layout (16x16 cells, 6 cols x 4 rows):
//   row 0 : expression so far   "5"  ->  "5+"  ->  "5+3=8"
//   row 3 : current input       live digit, or the selected op

module calc_top (
    input  wire        clk,
    input  wire        btnC,
    input  wire        btnU,
    input  wire [15:0] sw,
    output wire [7:0]  JB
);
    `include "chars.vh"
    `include "calc_params.vh"

    // ---------------- clocks ----------------
    wire clk6p25m;
    slow_clock u_clk6p25m (
        .clk        (clk),
        .SLOW_CLOCK (clk6p25m)
    );

    // ---------------- buttons -> 1-cycle pulses ----------------
    wire pC, pU;
    debounce u_dbC (.clk(clk), .btn(btnC), .pulse(pC));
    debounce u_dbU (.clk(clk), .btn(btnU), .pulse(pU));

    // ---------------- switches -> digit ----------------
    wire [3:0] digit;
    wire       digit_valid;
    sw_encoder u_sw (
        .sw          (sw[9:0]),
        .digit       (digit),
        .digit_valid (digit_valid)
    );

    // ---------------- FSM ----------------
    wire [1:0] state;
    wire [3:0] n1, n2;
    wire [1:0] op;
    wire       op_set;
    wire [6:0] result;
    wire       show_result;

    calc_fsm u_fsm (
        .clk         (clk),
        .pC          (pC),
        .pU          (pU),
        .digit       (digit),
        .digit_valid (digit_valid),
        .state       (state),
        .n1          (n1),
        .op          (op),
        .op_set      (op_set),
        .n2          (n2),
        .result      (result),
        .show_result (show_result)
    );

    // ---------------- values -> char codes ----------------
    wire [3:0] op_char  = CH_PLUS + op;     // OP_ADD->'+', OP_SUB->'-', ...
    wire [3:0] res_tens = result / 10;
    wire [3:0] res_ones = result % 10;

    // ---------------- pixel -> character cell ----------------
    wire [12:0] pixel_index;
    wire [6:0]  x = pixel_index % 96;
    wire [5:0]  y = pixel_index / 96;

    wire [2:0] char_col = x[6:4];
    wire [1:0] char_row = y[5:4];
    wire [2:0] gx       = x[3:1];
    wire [2:0] gy       = y[3:1];

    // ---------------- character map ----------------
    reg [3:0] char_code;
    always @(*) begin
        char_code = CH_SPACE;

        // ----- top line: expression / answer -----
        if (char_row == 2'd0) begin
            case (state)
                S_N1: begin
                    if (show_result) begin
                        case (char_col)
                            3'd0: char_code = n1;
                            3'd1: char_code = op_char;
                            3'd2: char_code = n2;
                            3'd3: char_code = CH_EQ;
                            3'd4: char_code = (res_tens != 0) ? res_tens : res_ones;
                            3'd5: char_code = (res_tens != 0) ? res_ones : CH_SPACE;
                            default: char_code = CH_SPACE;
                        endcase
                    end
                end
                S_OP: begin
                    if (char_col == 3'd0) char_code = n1;
                end
                S_N2: begin
                    if      (char_col == 3'd0) char_code = n1;
                    else if (char_col == 3'd1) char_code = op_char;
                end
                default: char_code = CH_SPACE;
            endcase
        end

        // ----- bottom line: current input -----
        else if (char_row == 2'd3 && char_col == 3'd0) begin
            case (state)
                S_N1, S_N2: if (digit_valid) char_code = digit;
                S_OP:       if (op_set)      char_code = op_char;
                default:    char_code = CH_SPACE;
            endcase
        end
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
        .reset       (1'b0),
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
