`timescale 1ns / 1ps
module poly_display (
    input wire clk, input wire [12:0] pixel_index,
    input wire [2:0] state, input wire quad, input wire mode_set,
    input wire sw_neg, input wire [3:0] digit, input wire digit_valid,
    input wire digit_conflict,
    input wire a_neg, input wire [3:0] a_mag, input wire b_neg, input wire [3:0] b_mag,
    input wire c_neg, input wire [3:0] c_mag, input wire [2:0] rtype,
    input wire r1_neg, input wire [9:0] r1_mag, input wire r2_neg, input wire [9:0] r2_mag,
    output wire [15:0] pixel_data
);
    `include "chars.vh"
    `include "poly_params.vh"
    wire [6:0] x=pixel_index%96; wire [5:0] y=pixel_index/96;
    wire [3:0] col=x[6:3]; wire [2:0] row=y[5:3]; wire [2:0] gx=x[2:0]; wire [2:0] gy=y[2:0];
    reg [3:0] r1_i,r1_t,r1_o,r2_i,r2_t,r2_o;
    always @(posedge clk) begin
        r1_i<=r1_mag/100; r1_t<=(r1_mag%100)/10; r1_o<=r1_mag%10;
        r2_i<=r2_mag/100; r2_t<=(r2_mag%100)/10; r2_o<=r2_mag%10;
    end
    function [5:0] val_char;
        input [3:0] k; input neg; input [3:0] di,dt,do_; begin
            case(k) 0:val_char=neg?CH_MINUS:CH_SPACE; 1:val_char=di; 2:val_char=CH_DOT;
            3:val_char=dt; 4:val_char=do_; default:val_char=CH_SPACE; endcase
        end
    endfunction
    wire [5:0] a_sgn=a_neg?CH_MINUS:CH_SPACE, b_sgn=b_neg?CH_MINUS:CH_PLUS, c_sgn=c_neg?CH_MINUS:CH_PLUS;
    wire show_a=(state>=P_S_B), show_b=(state>=P_S_C), show_c=(state>=P_S_CALC)&&quad;
    wire show_eq_lin=(state>=P_S_C)&&!quad;
    reg [5:0] ch;
    always @(*) begin
        ch=CH_SPACE;
        case(row)
            0: if (state==P_S_MODE && !mode_set) begin
                case(col)
                    0:ch=CH_U; 1:ch=CH_COLON;
                    3:ch=CH_L; 4:ch=CH_I; 5:ch=CH_N; 6:ch=CH_E;
                    7:ch=CH_A; 8:ch=CH_R;
                    default:;
                endcase
            end else if(quad) begin
                case(col) 0:if(show_a)ch=a_sgn;1:if(show_a)ch=a_mag;2:if(show_a)ch=CH_X;3:if(show_a)ch=CH_SQ;
                    4:if(show_b)ch=b_sgn;5:if(show_b)ch=b_mag;6:if(show_b)ch=CH_X;7:if(show_c)ch=c_sgn;
                    8:if(show_c)ch=c_mag;9:if(show_c)ch=CH_EQ;10:if(show_c)ch=CH_0; default:; endcase
            end else begin
                case(col) 0:if(show_a)ch=a_sgn;1:if(show_a)ch=a_mag;2:if(show_a)ch=CH_X;3:if(show_b)ch=b_sgn;
                    4:if(show_b)ch=b_mag;5:if(show_eq_lin)ch=CH_EQ;6:if(show_eq_lin)ch=CH_0; default:; endcase
            end
            1: if (state==P_S_MODE && !mode_set) begin
                case(col)
                    0:ch=CH_D; 1:ch=CH_COLON;
                    3:ch=CH_Q; 4:ch=CH_U; 5:ch=CH_A; 6:ch=CH_D;
                    7:ch=CH_R; 8:ch=CH_A; 9:ch=CH_T; 10:ch=CH_I; 11:ch=CH_C;
                    default:;
                endcase
            end
            2: if(state==P_S_RES) case(rtype)
                P_RT_NONE: case(col) 0:ch=CH_N;1:ch=CH_O;3:ch=CH_R;4:ch=CH_O;5:ch=CH_O;6:ch=CH_T;default:;endcase
                P_RT_ALL: case(col) 0:ch=CH_A;1:ch=CH_L;2:ch=CH_L;4:ch=CH_X;default:;endcase
                P_RT_ONE: begin if(col==0)ch=CH_X; else if(col==1)ch=CH_EQ; else ch=val_char(col-2,r1_neg,r1_i,r1_t,r1_o); end
                P_RT_CPX: begin if(col==0)ch=CH_X; else if(col==1)ch=CH_EQ; else ch=val_char(col-2,r1_neg,r1_i,r1_t,r1_o); end
                P_RT_DBL: begin case(col) 0:ch=CH_X;1:ch=CH_1;2:ch=CH_EQ;3:ch=CH_X;4:ch=CH_2;5:ch=CH_EQ;default:ch=val_char(col-6,r1_neg,r1_i,r1_t,r1_o);endcase end
                P_RT_TWO: begin if(col==0)ch=CH_X; else if(col==1)ch=CH_1; else if(col==2)ch=CH_EQ; else ch=val_char(col-3,r1_neg,r1_i,r1_t,r1_o); end
                default:;
            endcase
            3: if(state==P_S_RES) case(rtype)
                P_RT_TWO: begin if(col==0)ch=CH_X; else if(col==1)ch=CH_2; else if(col==2)ch=CH_EQ; else ch=val_char(col-3,r2_neg,r2_i,r2_t,r2_o); end
                P_RT_CPX: begin if(col==2)ch=CH_PM; else if(col==7)ch=CH_i; else if(col>=3&&col<=6)ch=val_char(col-2,1'b0,r2_i,r2_t,r2_o); end
                default:;
            endcase
            6: case(state)
                P_S_MODE: if(mode_set) begin
                    if(quad) begin case(col)0:ch=CH_A;1:ch=CH_X;2:ch=CH_SQ;3:ch=CH_PLUS;4:ch=CH_B;5:ch=CH_X;6:ch=CH_PLUS;7:ch=CH_C;8:ch=CH_EQ;9:ch=CH_0;default:;endcase end
                    else begin case(col)0:ch=CH_A;1:ch=CH_X;2:ch=CH_PLUS;3:ch=CH_B;4:ch=CH_EQ;5:ch=CH_0;default:;endcase end
                end
                P_S_A,P_S_B,P_S_C: begin case(col)0:ch=(state==P_S_A)?CH_A:(state==P_S_B)?CH_B:CH_C;1:ch=CH_EQ;2:ch=sw_neg?CH_MINUS:CH_PLUS;3:if(digit_valid)ch=digit;default:;endcase end
                default:;
            endcase
            default:;
        endcase
        if (digit_conflict && (row == 3'd6 || row == 3'd7)) begin
            if (row == 3'd6) begin
                case(col)
                    1:ch=CH_S; 2:ch=CH_E; 3:ch=CH_L; 4:ch=CH_E;
                    5:ch=CH_C; 6:ch=CH_T; 8:ch=CH_O; 9:ch=CH_N;
                    10:ch=CH_E; default:ch=CH_SPACE;
                endcase
            end else begin
                case(col)
                    1:ch=CH_D; 2:ch=CH_I; 3:ch=CH_G; 4:ch=CH_I;
                    5:ch=CH_T; 7:ch=CH_O; 8:ch=CH_N; 9:ch=CH_L;
                    10:ch=CH_Y; default:ch=CH_SPACE;
                endcase
            end
        end
    end
    wire [7:0] bits;
    font_rom u_font(.char_code(ch),.row(gy),.bits(bits));
    assign pixel_data=bits[7-gx] ?
        ((digit_conflict && (row == 3'd6 || row == 3'd7)) ? 16'hFBE0 : 16'hFFFF) :
        16'h0000;
endmodule
