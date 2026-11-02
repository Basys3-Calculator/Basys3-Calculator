`timescale 1ns / 1ps
// int_sqrt.v - floor(sqrt(rad)), one result bit per clock (QW cycles).
// RW = width of rad, QW = width of root (2*QW must be >= RW).
module int_sqrt #(parameter RW = 22, parameter QW = 11) (
    input wire clk, input wire start, input wire [RW-1:0] rad,
    output reg [QW-1:0] root = 0, output reg done = 1'b0
);
    reg busy=1'b0; reg [4:0] bitn=5'd0; reg [RW-1:0] r=0;
    wire [QW-1:0]   trial = root | ({{(QW-1){1'b0}}, 1'b1} << bitn);
    wire [2*QW-1:0] sq    = trial * trial;
    always @(posedge clk) begin
        done <= 1'b0;
        if (!busy) begin
            if (start) begin r<=rad; root<=0; bitn<=QW-1; busy<=1'b1; end
        end else begin
            if (sq <= r) root <= trial;
            if (bitn == 0) begin busy<=1'b0; done<=1'b1; end
            else bitn <= bitn - 1'b1;
        end
    end
endmodule
