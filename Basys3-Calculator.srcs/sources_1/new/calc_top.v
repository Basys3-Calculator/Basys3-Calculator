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
    output wire [7:0]  JC
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
    wire [3:0] digit;
    wire       digit_valid;
    sw_encoder u_sw (
        .sw          (sw[9:0]),
        .digit       (digit),
        .digit_valid (digit_valid)
    );

    // ---------------- FSMs ----------------
    wire [1:0] state;
    wire [3:0] n1, n2;
    wire [1:0] op;
    wire       op_set;
    wire [6:0] result;
    wire       show_result;

    // The two mode switches must be different for exactly one mode to run.
    // If both are off, show the mode-selection screen. If both are on, show
    // the mode-conflict screen. Neither invalid combination updates an FSM.
    wire        diff_active  = sw[12] && !sw[11];
    wire        calc_active  = sw[11] && !sw[12];
    wire        mode_select  = !sw[11] && !sw[12];
    wire        mode_conflict = sw[11] && sw[12];

    // Gate every event by the active mode. This preserves each module's state
    // while preventing input in one mode from updating the other mode.
    wire pC_calc = pC && calc_active;
    wire pU_calc = pU && calc_active;
    wire pD_calc = pD && calc_active;
    wire pL_calc = pL && calc_active;
    wire pR_calc = pR && calc_active;
    wire pC_diff = pC && diff_active;
    wire pU_diff = pU && diff_active;
    wire pD_diff = pD && diff_active;
    wire pL_diff = pL && diff_active;
    wire pR_diff = pR && diff_active;
    wire [11:0] diff_value;
    wire [2:0]  diff_digit_count;
    wire [1:0]  diff_view;

    calc_fsm u_fsm (
        .clk         (clk),
        .pC          (pC_calc),
        .pU          (pU_calc),
        .pD          (pD_calc),
        .pL          (pL_calc),
        .pR          (pR_calc),
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

    diff_num_rep u_diff (
        .clk         (clk),
        .pC          (pC_diff),
        .pU          (pU_diff),
        .pD          (pD_diff),
        .pL          (pL_diff),
        .pR          (pR_diff),
        .digit       (digit),
        .digit_valid (digit_valid),
        .value       (diff_value),
        .digit_count (diff_digit_count),
        .view        (diff_view)
    );

    // ---------------- values -> character codes ----------------
    // The existing calculator uses only codes 0-15. The representation mode
    // also uses letter, colon, and menu-label codes, so the final char_code is
    // six bits.
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
    // Menu text uses 6x8 cells: 16 columns fit across 96 pixels.
    wire [3:0] compact_col = x / 6;
    wire [2:0] compact_row = y / 8;
    wire [2:0] compact_gx  = x % 6;
    wire [2:0] compact_gy  = y % 8;

    // ---------------- character map ----------------
    reg [5:0] char_code;
    reg [3:0] normal_char_code;
    reg [5:0] diff_char_code;
    reg [5:0] menu_char_code;
    reg [3:0] dec_hundreds, dec_tens, dec_ones;
    reg [3:0] oct_thousands, oct_hundreds, oct_tens, oct_ones;
    reg [3:0] hex_hundreds, hex_tens, hex_ones;
    reg [3:0] bin_len;

    always @(*) begin
        char_code = CH_SPACE;
        normal_char_code = CH_SPACE;
        diff_char_code = CH_SPACE;
        menu_char_code = CH_SPACE;

        // Break the stored decimal value into display digits. These arithmetic
        // expressions are combinational and are only used for OLED rendering.
        dec_hundreds = diff_value / 100;
        dec_tens     = (diff_value / 10) % 10;
        dec_ones     = diff_value % 10;
        // 999 decimal is 1751 octal, so four octal digits are sufficient.
        oct_thousands = diff_value / 512;
        oct_hundreds  = (diff_value / 64) % 8;
        oct_tens      = (diff_value / 8) % 8;
        oct_ones      = diff_value % 8;
        // 999 decimal is 3E7 hexadecimal, so three hexadecimal digits fit.
        hex_hundreds  = diff_value / 256;
        hex_tens      = (diff_value / 16) % 16;
        hex_ones      = diff_value % 16;

        // Normal calculator renderer: 16x16 cells, six columns wide.
        // It preserves the original calculator's large-character layout.
        if (char_row == 2'd0) begin
            case (state)
                S_N1: begin
                    if (show_result) begin
                        case (char_col)
                            3'd0: normal_char_code = n1;
                            3'd1: normal_char_code = op_char;
                            3'd2: normal_char_code = n2;
                            3'd3: normal_char_code = CH_EQ;
                            3'd4: normal_char_code = (res_tens != 0) ? res_tens : res_ones;
                            3'd5: normal_char_code = (res_tens != 0) ? res_ones : CH_SPACE;
                            default: normal_char_code = CH_SPACE;
                        endcase
                    end
                end
                S_OP: begin
                    if (char_col == 3'd0) normal_char_code = n1;
                end
                S_N2: begin
                    if      (char_col == 3'd0) normal_char_code = n1;
                    else if (char_col == 3'd1) normal_char_code = op_char;
                end
                default: normal_char_code = CH_SPACE;
            endcase
        end else if (char_row == 2'd3 && char_col == 3'd0) begin
            case (state)
                S_N1, S_N2: if (digit_valid) normal_char_code = digit;
                S_OP:       if (op_set)      normal_char_code = op_char;
                default:    normal_char_code = CH_SPACE;
            endcase
        end

        // Find the significant binary length so leading zeroes are omitted.
        // Values 0 and 1 both need one displayed binary digit.
        if      (diff_value >= 12'd512) bin_len = 4'd10;
        else if (diff_value >= 12'd256) bin_len = 4'd9;
        else if (diff_value >= 12'd128) bin_len = 4'd8;
        else if (diff_value >= 12'd64)  bin_len = 4'd7;
        else if (diff_value >= 12'd32)  bin_len = 4'd6;
        else if (diff_value >= 12'd16)  bin_len = 4'd5;
        else if (diff_value >= 12'd8)   bin_len = 4'd4;
        else if (diff_value >= 12'd4)   bin_len = 4'd3;
        else if (diff_value >= 12'd2)   bin_len = 4'd2;
        else                            bin_len = 4'd1;

        // Representation mode uses the same 16x16 cells as the calculator:
        // six columns per row. Binary wraps to the next row when necessary.
        if (char_row == 2'd0) begin
            case (char_col)
                3'd0: diff_char_code = (diff_view == 2'd1) ? CH_B :
                                       (diff_view == 2'd2) ? CH_O :
                                       (diff_view == 2'd3) ? CH_H : CH_D;
                3'd1: diff_char_code = (diff_view == 2'd1) ? CH_I :
                                       (diff_view == 2'd2) ? CH_C :
                                       (diff_view == 2'd3) ? CH_E : CH_E;
                3'd2: diff_char_code = (diff_view == 2'd1) ? CH_N :
                                       (diff_view == 2'd2) ? CH_T :
                                       (diff_view == 2'd3) ? CH_X : CH_C;
                3'd3: diff_char_code = CH_COLON;
                default: diff_char_code = CH_SPACE;
            endcase
        end else if (char_row == 2'd1) begin
            case (diff_view)
                2'd1: begin
                    // First six significant binary digits.
                    if (char_col < bin_len)
                        diff_char_code = diff_value[bin_len - 1 - char_col] ? CH_1 : CH_0;
                end
                2'd2: begin
                    if (diff_value >= 12'd512) begin
                        case (char_col)
                            3'd0: diff_char_code = oct_thousands;
                            3'd1: diff_char_code = oct_hundreds;
                            3'd2: diff_char_code = oct_tens;
                            3'd3: diff_char_code = oct_ones;
                            default: diff_char_code = CH_SPACE;
                        endcase
                    end else if (diff_value >= 12'd64) begin
                        case (char_col)
                            3'd0: diff_char_code = oct_hundreds;
                            3'd1: diff_char_code = oct_tens;
                            3'd2: diff_char_code = oct_ones;
                            default: diff_char_code = CH_SPACE;
                        endcase
                    end else if (diff_value >= 12'd8) begin
                        case (char_col)
                            3'd0: diff_char_code = oct_tens;
                            3'd1: diff_char_code = oct_ones;
                            default: diff_char_code = CH_SPACE;
                        endcase
                    end else if (char_col == 3'd0) begin
                        diff_char_code = oct_ones;
                    end
                end
                2'd3: begin
                    if (diff_value >= 12'd256) begin
                        case (char_col)
                            3'd0: diff_char_code = (hex_hundreds < 10) ? hex_hundreds : CH_A + hex_hundreds - 10;
                            3'd1: diff_char_code = (hex_tens < 10) ? hex_tens : CH_A + hex_tens - 10;
                            3'd2: diff_char_code = (hex_ones < 10) ? hex_ones : CH_A + hex_ones - 10;
                            default: diff_char_code = CH_SPACE;
                        endcase
                    end else if (diff_value >= 12'd16) begin
                        case (char_col)
                            3'd0: diff_char_code = (hex_tens < 10) ? hex_tens : CH_A + hex_tens - 10;
                            3'd1: diff_char_code = (hex_ones < 10) ? hex_ones : CH_A + hex_ones - 10;
                            default: diff_char_code = CH_SPACE;
                        endcase
                    end else if (char_col == 3'd0) begin
                        diff_char_code = (hex_ones < 10) ? hex_ones : CH_A + hex_ones - 10;
                    end
                end
                default: begin
                    if (diff_digit_count == 3'd1) begin
                        if (char_col == 3'd0) diff_char_code = dec_ones;
                    end else if (diff_digit_count == 3'd2) begin
                        if      (char_col == 3'd0) diff_char_code = dec_tens;
                        else if (char_col == 3'd1) diff_char_code = dec_ones;
                    end else if (diff_digit_count == 3'd3) begin
                        if      (char_col == 3'd0) diff_char_code = dec_hundreds;
                        else if (char_col == 3'd1) diff_char_code = dec_tens;
                        else if (char_col == 3'd2) diff_char_code = dec_ones;
                    end
                end
            endcase
        end else if (char_row == 2'd2) begin
            // Remaining binary digits wrap to row 2. For example, 999 becomes
            // "111110" on row 1 followed by "0111" on row 2.
            if (diff_view == 2'd1 && (char_col + 3'd6) < bin_len)
                diff_char_code = diff_value[bin_len - 1 - (char_col + 3'd6)] ? CH_1 : CH_0;
        end else if (char_row == 2'd3) begin
            // Show exactly one currently selected switch digit near the bottom
            // while entering decimal input. btnC confirms and appends it above.
            if (char_col == 3'd0 && diff_view == 2'd0 && digit_valid)
                diff_char_code = digit;
        end

        // Invalid mode-selection screens use 6x8 text so the full messages
        // fit across the 96-pixel OLED width (up to 16 characters per row).
        // The strings are placed on menu rows 0, 2, and 4.
        if (mode_select) begin
            case (compact_row)
                3'd0: begin
                    case (compact_col)
                        4'd0: menu_char_code = CH_S;
                        4'd1: menu_char_code = CH_E;
                        4'd2: menu_char_code = CH_L;
                        4'd3: menu_char_code = CH_E;
                        4'd4: menu_char_code = CH_C;
                        4'd5: menu_char_code = CH_T;
                        4'd7: menu_char_code = CH_M;
                        4'd8: menu_char_code = CH_O;
                        4'd9: menu_char_code = CH_D;
                        4'd10: menu_char_code = CH_E;
                        default: menu_char_code = CH_SPACE;
                    endcase
                end
                3'd2: begin
                    case (compact_col)
                        4'd0: menu_char_code = CH_1;
                        4'd1: menu_char_code = CH_1;
                        4'd2: menu_char_code = CH_COLON;
                        4'd4: menu_char_code = CH_O;
                        4'd5: menu_char_code = CH_P;
                        4'd6: menu_char_code = CH_E;
                        4'd7: menu_char_code = CH_R;
                        4'd8: menu_char_code = CH_A;
                        4'd9: menu_char_code = CH_T;
                        4'd10: menu_char_code = CH_I;
                        4'd11: menu_char_code = CH_O;
                        4'd12: menu_char_code = CH_N;
                        4'd13: menu_char_code = CH_S;
                        default: menu_char_code = CH_SPACE;
                    endcase
                end
                3'd4: begin
                    case (compact_col)
                        4'd0: menu_char_code = CH_1;
                        4'd1: menu_char_code = CH_2;
                        4'd2: menu_char_code = CH_COLON;
                        4'd4: menu_char_code = CH_N;
                        4'd5: menu_char_code = CH_U;
                        4'd6: menu_char_code = CH_M;
                        4'd7: menu_char_code = CH_B;
                        4'd8: menu_char_code = CH_E;
                        4'd9: menu_char_code = CH_R;
                        4'd11: menu_char_code = CH_R;
                        4'd12: menu_char_code = CH_E;
                        4'd13: menu_char_code = CH_P;
                        default: menu_char_code = CH_SPACE;
                    endcase
                end
                default: menu_char_code = CH_SPACE;
            endcase
        end else if (mode_conflict) begin
            case (compact_row)
                3'd0: begin
                    case (compact_col)
                        4'd0: menu_char_code = CH_M;
                        4'd1: menu_char_code = CH_O;
                        4'd2: menu_char_code = CH_D;
                        4'd3: menu_char_code = CH_E;
                        4'd5: menu_char_code = CH_C;
                        4'd6: menu_char_code = CH_O;
                        4'd7: menu_char_code = CH_N;
                        4'd8: menu_char_code = CH_F;
                        4'd9: menu_char_code = CH_L;
                        4'd10: menu_char_code = CH_I;
                        4'd11: menu_char_code = CH_C;
                        4'd12: menu_char_code = CH_T;
                        default: menu_char_code = CH_SPACE;
                    endcase
                end
                3'd2: begin
                    case (compact_col)
                        4'd0: menu_char_code = CH_T;
                        4'd1: menu_char_code = CH_U;
                        4'd2: menu_char_code = CH_R;
                        4'd3: menu_char_code = CH_N;
                        4'd5: menu_char_code = CH_O;
                        4'd6: menu_char_code = CH_N;
                        4'd7: menu_char_code = CH_E;
                        4'd8: menu_char_code = CH_SPACE;
                        4'd9: menu_char_code = CH_O;
                        4'd10: menu_char_code = CH_F;
                        4'd11: menu_char_code = CH_F;
                        default: menu_char_code = CH_SPACE;
                    endcase
                end
                default: menu_char_code = CH_SPACE;
            endcase
        end

        if (mode_select || mode_conflict)
            char_code = menu_char_code;
        else if (diff_active)
            char_code = diff_char_code;
        else if (calc_active)
            char_code = normal_char_code;
        else
            char_code = CH_SPACE;
    end

    // ---------------- font lookup ----------------
    // Both modes now use the normal 16x16 sampling coordinates.
    wire [7:0] font_row;
    font_rom u_font (
        .char_code (char_code),
        .row       (mode_select || mode_conflict ? compact_gy : gy),
        .bits      (font_row)
    );

    wire [15:0] oled_data = (mode_select || mode_conflict) ?
                            (font_row[7 - compact_gx] ? 16'hFFFF : 16'h0000) :
                            (font_row[7 - gx] ? 16'hFFFF : 16'h0000);

    // ---------------- OLED ----------------
    Oled_Display u_oled (
        .clk         (clk6p25m),
        .reset       (1'b0),
        .pixel_index (pixel_index),
        .pixel_data  (oled_data),
        .cs          (JC[0]),
        .sdin        (JC[1]),
        .sclk        (JC[3]),
        .d_cn        (JC[4]),
        .resn        (JC[5]),
        .vccen       (JC[6]),
        .pmoden      (JC[7])
    );
    assign JC[2] = 1'b0;

endmodule
