`include "chars.vh"

module trig_text(
    input  wire [9:0] angle,
    input  wire signed [31:0] value,
    input  wire [1:0] function_select,
    input  wire       radian_mode,
    input  wire       undefined,
    input  wire [3:0] pending_digit,
    input  wire       pending_valid,
    input  wire       digit_conflict,
    input  wire [3:0] row,
    input  wire [3:0] col,
    output reg  [5:0] char_code
    );

    reg [31:0] magnitude;
    reg [31:0] integer_part;
    reg [3:0] hundreds, tens, ones;
    reg [3:0] frac_thousands, frac_hundreds, frac_tens, frac_ones;

    always @(*) begin
        magnitude = value[31] ? (~value + 32'd1) : value;
        integer_part = magnitude / 10000;
        hundreds = (integer_part / 100) % 10;
        tens = (integer_part / 10) % 10;
        ones = integer_part % 10;
        frac_thousands = (magnitude / 1000) % 10;
        frac_hundreds = (magnitude / 100) % 10;
        frac_tens = (magnitude / 10) % 10;
        frac_ones = magnitude % 10;
        char_code = CH_SPACE;

        // Centered warning in the bottom two rows of the trig screen.
        if (digit_conflict) begin
            if (row == 4'd6) begin
                case (col)
                    4'd1: char_code = CH_S;
                    4'd2: char_code = CH_E;
                    4'd3: char_code = CH_L;
                    4'd4: char_code = CH_E;
                    4'd5: char_code = CH_C;
                    4'd6: char_code = CH_T;
                    4'd8: char_code = CH_O;
                    4'd9: char_code = CH_N;
                    4'd10: char_code = CH_E;
                    default: char_code = CH_SPACE;
                endcase
            end else if (row == 4'd7) begin
                case (col)
                    4'd1: char_code = CH_D;
                    4'd2: char_code = CH_I;
                    4'd3: char_code = CH_G;
                    4'd4: char_code = CH_I;
                    4'd5: char_code = CH_T;
                    4'd7: char_code = CH_O;
                    4'd8: char_code = CH_N;
                    4'd9: char_code = CH_L;
                    4'd10: char_code = CH_Y;
                    default: char_code = CH_SPACE;
                endcase
            end
        end

        // Row 1: SIN(123), COS(123), or TAN(123), without leading zeroes.
        if (row == 4'd1) begin
            case (function_select)
                2'd0: begin char_code = (col == 0) ? CH_S :
                                      (col == 1) ? CH_I :
                                      (col == 2) ? CH_N : CH_SPACE; end
                2'd1: begin char_code = (col == 0) ? CH_C :
                                      (col == 1) ? CH_O :
                                      (col == 2) ? CH_S : CH_SPACE; end
                default: begin char_code = (col == 0) ? CH_T :
                                          (col == 1) ? CH_A :
                                          (col == 2) ? CH_N : CH_SPACE; end
            endcase
            if (col == 3) char_code = CH_LPAREN;
            else if (angle >= 100 && col == 4) char_code = angle / 100;
            else if (angle >= 100 && col == 5) char_code = (angle / 10) % 10;
            else if (angle >= 100 && col == 6) char_code = angle % 10;
            else if (angle >= 100 && !radian_mode && col == 7) char_code = CH_DEGREE;
            else if (angle >= 100 && !radian_mode && col == 8) char_code = CH_RPAREN;
            else if (angle >= 100 && radian_mode && col == 7) char_code = CH_SPACE;
            else if (angle >= 100 && radian_mode && col == 8) char_code = CH_R;
            else if (angle >= 100 && radian_mode && col == 9) char_code = CH_A;
            else if (angle >= 100 && radian_mode && col == 10) char_code = CH_D;
            else if (angle >= 100 && radian_mode && col == 11) char_code = CH_RPAREN;
            else if (angle >= 10 && col == 4) char_code = (angle / 10) % 10;
            else if (angle >= 10 && col == 5) char_code = angle % 10;
            else if (angle >= 10 && !radian_mode && col == 6) char_code = CH_DEGREE;
            else if (angle >= 10 && !radian_mode && col == 7) char_code = CH_RPAREN;
            else if (angle >= 10 && radian_mode && col == 6) char_code = CH_SPACE;
            else if (angle >= 10 && radian_mode && col == 7) char_code = CH_R;
            else if (angle >= 10 && radian_mode && col == 8) char_code = CH_A;
            else if (angle >= 10 && radian_mode && col == 9) char_code = CH_D;
            else if (angle >= 10 && radian_mode && col == 10) char_code = CH_RPAREN;
            else if (angle < 10 && col == 4) char_code = angle;
            else if (angle < 10 && !radian_mode && col == 5) char_code = CH_DEGREE;
            else if (angle < 10 && !radian_mode && col == 6) char_code = CH_RPAREN;
            else if (angle < 10 && radian_mode && col == 5) char_code = CH_SPACE;
            else if (angle < 10 && radian_mode && col == 6) char_code = CH_R;
            else if (angle < 10 && radian_mode && col == 7) char_code = CH_A;
            else if (angle < 10 && radian_mode && col == 8) char_code = CH_D;
            else if (angle < 10 && radian_mode && col == 9) char_code = CH_RPAREN;
        end

        // Row 3: = -12.3456, or = UNDEFINED for tangent asymptotes.
        if (row == 4'd3) begin
            if (undefined) begin
                case (col)
                    4'd0: char_code = CH_EQ;
                    4'd2: char_code = CH_U;
                    4'd3: char_code = CH_N;
                    4'd4: char_code = CH_D;
                    4'd5: char_code = CH_E;
                    4'd6: char_code = CH_F;
                    4'd7: char_code = CH_I;
                    4'd8: char_code = CH_N;
                    4'd9: char_code = CH_E;
                    4'd10: char_code = CH_D;
                    default: char_code = CH_SPACE;
                endcase
            end else begin
                char_code = CH_SPACE;
                if (col == 0)
                    char_code = CH_EQ;
                else if (!value[31] && hundreds != 0) begin
                    case (col)
                        4'd1: char_code = hundreds;
                        4'd2: char_code = tens;
                        4'd3: char_code = ones;
                        4'd4: char_code = CH_DOT;
                        4'd5: char_code = frac_thousands;
                        4'd6: char_code = frac_hundreds;
                        4'd7: char_code = frac_tens;
                        4'd8: char_code = frac_ones;
                        default: char_code = CH_SPACE;
                    endcase
                end else if (!value[31] && tens != 0) begin
                    case (col)
                        4'd1: char_code = tens;
                        4'd2: char_code = ones;
                        4'd3: char_code = CH_DOT;
                        4'd4: char_code = frac_thousands;
                        4'd5: char_code = frac_hundreds;
                        4'd6: char_code = frac_tens;
                        4'd7: char_code = frac_ones;
                        default: char_code = CH_SPACE;
                    endcase
                end else if (!value[31]) begin
                    case (col)
                        4'd1: char_code = ones;
                        4'd2: char_code = CH_DOT;
                        4'd3: char_code = frac_thousands;
                        4'd4: char_code = frac_hundreds;
                        4'd5: char_code = frac_tens;
                        4'd6: char_code = frac_ones;
                        default: char_code = CH_SPACE;
                    endcase
                end else begin
                    // Negative answers reserve the first position for '-'.
                    if (hundreds != 0) begin
                        case (col)
                            4'd1: char_code = CH_MINUS;
                            4'd2: char_code = hundreds;
                            4'd3: char_code = tens;
                            4'd4: char_code = ones;
                            4'd5: char_code = CH_DOT;
                            4'd6: char_code = frac_thousands;
                            4'd7: char_code = frac_hundreds;
                            4'd8: char_code = frac_tens;
                            4'd9: char_code = frac_ones;
                            default: char_code = CH_SPACE;
                        endcase
                    end else if (tens != 0) begin
                        case (col)
                            4'd1: char_code = CH_MINUS;
                            4'd2: char_code = tens;
                            4'd3: char_code = ones;
                            4'd4: char_code = CH_DOT;
                            4'd5: char_code = frac_thousands;
                            4'd6: char_code = frac_hundreds;
                            4'd7: char_code = frac_tens;
                            4'd8: char_code = frac_ones;
                            default: char_code = CH_SPACE;
                        endcase
                    end else begin
                        case (col)
                            4'd1: char_code = CH_MINUS;
                            4'd2: char_code = ones;
                            4'd3: char_code = CH_DOT;
                            4'd4: char_code = frac_thousands;
                            4'd5: char_code = frac_hundreds;
                            4'd6: char_code = frac_tens;
                            4'd7: char_code = frac_ones;
                            default: char_code = CH_SPACE;
                        endcase
                    end
                end
            end
        end

        // The currently selected, not-yet-confirmed digit appears at the
        // bottom-left. Once btnC confirms it, it disappears from here and is
        // incorporated into the expression above.
        if (row == 4'd7 && col == 4'd0 && pending_valid)
            char_code = pending_digit;
    end
endmodule
