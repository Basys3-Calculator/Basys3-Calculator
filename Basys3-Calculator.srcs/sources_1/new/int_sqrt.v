`timescale 1ns / 1ps
module int_sqrt (
    input wire clk, input wire start, input wire [21:0] rad,
    output reg [10:0] root = 11'd0, output reg done = 1'b0
);
    reg busy=1'b0; reg [3:0] bitn=4'd0; reg [21:0] r=22'd0;
    wire [10:0] trial = root | (11'd1 << bitn);
    wire [21:0] sq = trial * trial;
    always @(posedge clk) begin
        done <= 1'b0;
        if (!busy) begin
            if (start) begin r<=rad; root<=0; bitn<=4'd10; busy<=1'b1; end
        end else begin
            if (sq <= r) root <= trial;
            if (bitn == 0) begin busy<=1'b0; done<=1'b1; end
            else bitn <= bitn - 1'b1;
        end
    end
endmodule
