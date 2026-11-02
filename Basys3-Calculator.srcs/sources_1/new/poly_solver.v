`timescale 1ns / 1ps
module poly_solver (
    input wire clk, input wire start, input wire quad,
    input wire a_neg, input wire [3:0] a_mag,
    input wire b_neg, input wire [3:0] b_mag,
    input wire c_neg, input wire [3:0] c_mag,
    output reg done=1'b0, output reg [2:0] rtype=3'd0,
    output reg r1_neg=1'b0, output reg [9:0] r1_mag=0,
    output reg r2_neg=1'b0, output reg [9:0] r2_mag=0
);
    `include "poly_params.vh"
    wire signed [4:0] a_s = a_neg ? -$signed({1'b0,a_mag}) : $signed({1'b0,a_mag});
    wire signed [4:0] b_s = b_neg ? -$signed({1'b0,b_mag}) : $signed({1'b0,b_mag});
    wire signed [4:0] c_s = c_neg ? -$signed({1'b0,c_mag}) : $signed({1'b0,c_mag});
    wire signed [11:0] disc = b_s*b_s - 4*a_s*c_s;
    wire [11:0] disc_abs = disc[11] ? -disc : disc;
    wire [21:0] rad = disc_abs * 10000;
    wire use_lin=!quad || (a_mag==0);
    wire lA_neg=quad?b_neg:a_neg; wire [3:0] lA_mag=quad?b_mag:a_mag;
    wire lB_neg=quad?c_neg:b_neg; wire [3:0] lB_mag=quad?c_mag:b_mag;
    reg sq_start=0; wire [10:0] sq_root; wire sq_done;
    int_sqrt u_sqrt(.clk(clk),.start(sq_start),.rad(rad),.root(sq_root),.done(sq_done));
    reg dv_start=0; reg [14:0] dv_dividend=0; reg [6:0] dv_divisor=1;
    wire [14:0] dv_q; wire dv_done;
    udiv #(.NW(15),.DW(7)) u_div(.clk(clk),.start(dv_start),.dividend(dv_dividend),.divisor(dv_divisor),.quotient(dv_q),.done(dv_done));
    wire signed [14:0] nb=-(b_s*100);
    wire signed [14:0] s_s=$signed({4'b0,sq_root});
    wire signed [14:0] n_plus=nb+s_s, n_minus=nb-s_s;
    wire [14:0] n_plus_abs=n_plus[14]?-n_plus:n_plus, n_minus_abs=n_minus[14]?-n_minus:n_minus;
    localparam [3:0] IDLE=0,PREP=1,SQRT_W=2,SETUP=3,DIV_A=4,DIV_A_W=5,DIV_B=6,DIV_B_W=7,FIN=8;
    reg [3:0] ps=IDLE; reg [12:0] numA=0,numB=0; reg [5:0] denA=1,denB=1;
    reg negA=0,negB=0,two_div=0;
    always @(posedge clk) begin
        done<=0; sq_start<=0; dv_start<=0;
        case(ps)
            IDLE: if(start) ps<=PREP;
            PREP: begin
                if(use_lin) begin
                    if(lA_mag==0) begin rtype<=(lB_mag==0)?P_RT_ALL:P_RT_NONE; ps<=FIN; end
                    else begin numA<=lB_mag*100; denA<=lA_mag; negA<=(lA_neg==lB_neg)&&(lB_mag!=0); two_div<=0; rtype<=P_RT_ONE; ps<=DIV_A; end
                end else if(disc==0) begin
                    numA<=b_mag*100; denA<={a_mag,1'b0}; negA<=(a_neg==b_neg)&&(b_mag!=0); two_div<=0; rtype<=P_RT_DBL; ps<=DIV_A;
                end else begin sq_start<=1; ps<=SQRT_W; end
            end
            SQRT_W: if(sq_done) ps<=SETUP;
            SETUP: begin
                two_div<=1; denA<={a_mag,1'b0}; denB<={a_mag,1'b0};
                if(!disc[11]) begin numA<=n_plus_abs; negA<=n_plus[14]^a_neg; numB<=n_minus_abs; negB<=n_minus[14]^a_neg; rtype<=P_RT_TWO; end
                else begin numA<=b_mag*100; negA<=(a_neg==b_neg)&&(b_mag!=0); numB<={2'b0,sq_root}; negB<=0; rtype<=P_RT_CPX; end
                ps<=DIV_A;
            end
            DIV_A: begin dv_dividend<={numA,1'b0}+denA; dv_divisor<={denA,1'b0}; dv_start<=1; ps<=DIV_A_W; end
            DIV_A_W: if(dv_done) begin r1_mag<=dv_q[9:0]; r1_neg<=negA&&(dv_q!=0); ps<=two_div?DIV_B:FIN; end
            DIV_B: begin dv_dividend<={numB,1'b0}+denB; dv_divisor<={denB,1'b0}; dv_start<=1; ps<=DIV_B_W; end
            DIV_B_W: if(dv_done) begin r2_mag<=dv_q[9:0]; r2_neg<=negB&&(dv_q!=0); ps<=FIN; end
            FIN: begin done<=1; ps<=IDLE; end
            default: ps<=IDLE;
        endcase
    end
endmodule
