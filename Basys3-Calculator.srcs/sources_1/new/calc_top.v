`timescale 1ns / 1ps
// calc_top.v - addition mode: N1 -> btnC -> btnU (+) -> btnC -> N2 -> btnC
//
// OLED layout (16x16 cells, 6 cols x 4 rows):
//   row 0 : expression so far   "5"  ->  "5+"  ->  "5+3=8"
//   row 3 : current input       live digit, or the selected op

module calc_top (
    input  wire        clk,
    input  wire        btnC,
    input  wire        btnU,
    input  wire        btnL,
    input  wire        btnR,
    input  wire        btnD,
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
    wire pC, pU, pD, pL, pR;
    debounce u_dbC (.clk(clk), .btn(btnC), .pulse(pC));
    debounce u_dbU (.clk(clk), .btn(btnU), .pulse(pU));
    debounce u_dbD (.clk(clk), .btn(btnD), .pulse(pD));
    debounce u_dbL (.clk(clk), .btn(btnL), .pulse(pL));
    debounce u_dbR (.clk(clk), .btn(btnR), .pulse(pR));

    // ---------------- switches -> digit ----------------
    wire signed [5:0] digit;
    wire       digit_valid;
    sw_encoder u_sw (
        .sw          (sw[9:0]),
        .digit       (digit),
        .digit_valid (digit_valid)
    );

    // ---------------- FSM ----------------
    wire [1:0] state;
    wire signed [4:0] n1;
    wire [1:0] op;
    wire       op_set;
    wire [7*18-1:0] hist_flat;
    wire [2:0]  hist_count;

    calc_fsm u_fsm (
        .clk         (clk),
        .pC          (pC),
        .pU          (pU),
        .pD          (pD),
        .pL          (pL),
        .pR          (pR),
        .digit       (digit),
        .digit_valid (digit_valid),
        .state       (state),
        .n1          (n1),
        .op          (op),
        .op_set      (op_set),
        .hist_flat(hist_flat),
        .hist_count(hist_count)
    );

    // ---------------- pixel -> character cell ----------------
    wire [12:0] pixel_index;
    wire [6:0]  x = pixel_index % 96;
    wire [5:0]  y = pixel_index / 96;
    
    // 96 x 64 resolution makes for 12 x 8 grid of characters
    wire [3:0] char_col = x[6:3];
    wire [2:0] char_row = y[5:3];   
    wire [2:0] gx       = x[2:0];
    wire [2:0] gy       = y[2:0];

    // ---------------- values -> char codes ----------------
    wire [3:0] op_char  = CH_PLUS + op;     // OP_ADD->'+', OP_SUB->'-', ...
    
    wire [17:0] entry   = hist_flat[char_row*18 +: 18];
    wire [3:0]  e_n1    = entry[17:14];
    wire [1:0]  e_op    = entry[13:12];
    wire [3:0]  e_n2    = entry[11:8];
    wire signed [7:0] e_res = entry[7:0];
    wire        e_neg   = e_res[7];
    wire [7:0]  e_abs   = e_neg ? -e_res : e_res;
    wire [3:0]  e_tens  = e_abs / 10;
    wire [3:0]  e_ones  = e_abs % 10;
    wire [3:0]  e_op_char = CH_PLUS + e_op;

    // ---------------- character map ----------------
    reg [3:0] char_code;
    always @(*) begin
        char_code = CH_SPACE;

        // ----- bottom row: current input -----
        if (char_row == 3'd7) begin
            if (char_col == 4'd0) begin
                case (state)
                    S_N1, S_N2: if (digit_valid) char_code = digit;
                    S_OP:       if (op_set)      char_code = op_char;
                    default:    char_code = CH_SPACE;
                endcase
            end
        end

        // ----- finished equations -----
        else if (char_row < hist_count) begin
            case (char_col)
                4'd0: char_code = e_n1;
                4'd1: char_code = e_op_char;
                4'd2: char_code = e_n2;
                4'd3: char_code = CH_EQ;
                4'd4: char_code = !e_neg ? ((e_tens != 0) ? e_tens : e_ones) : CH_MINUS;
                4'd5: char_code = !e_neg ? ((e_tens != 0) ? e_ones : CH_SPACE)
                                         : ((e_tens != 0) ? e_tens : e_ones);
                4'd6: char_code = !e_neg ? CH_SPACE
                                         : ((e_tens != 0) ? e_ones : CH_SPACE);
                default: char_code = CH_SPACE;
            endcase
        end

        // ----- equation currently being typed (next free row) -----
        else if (char_row == hist_count && state != S_N1) begin
            if      (char_col == 4'd0)                    char_code = n1;
            else if (char_col == 4'd1 && state == S_N2)   char_code = op_char;
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