`timescale 1ns / 1ps
module udiv #(parameter NW=15, parameter DW=7) (
    input wire clk, input wire start, input wire [NW-1:0] dividend,
    input wire [DW-1:0] divisor, output wire [NW-1:0] quotient,
    output reg done=1'b0
);
    reg busy=1'b0; reg [4:0] cnt=0; reg [DW:0] rem=0; reg [NW-1:0] q=0;
    wire [DW:0] trial={rem[DW-1:0],q[NW-1]};
    wire [DW:0] dvs={1'b0,divisor};
    assign quotient=q;
    always @(posedge clk) begin
        done<=1'b0;
        if (!busy) begin
            if (start) begin q<=dividend; rem<=0; cnt<=NW; busy<=1'b1; end
        end else begin
            if (trial>=dvs) begin rem<=trial-dvs; q<={q[NW-2:0],1'b1}; end
            else begin rem<=trial; q<={q[NW-2:0],1'b0}; end
            cnt<=cnt-1'b1;
            if (cnt==1) begin busy<=1'b0; done<=1'b1; end
        end
    end
endmodule
