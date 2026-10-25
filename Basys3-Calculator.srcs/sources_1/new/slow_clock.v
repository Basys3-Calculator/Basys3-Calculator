`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: slow_clock
// 6.25 MHz clock from the 100 MHz board clock (toggles every 8 clk edges)
//////////////////////////////////////////////////////////////////////////////////


module slow_clock(
    input clk,
    output reg SLOW_CLOCK = 0
    );
 //6.25MHz, 1/16 clock cycle, 8 positive edges trigger 1 slow clock edge, 7 + 1
reg [2:0] COUNT = 3'b000;

always @ (posedge clk) begin
    COUNT <= (COUNT == 3'b111) ? 0 : COUNT + 1;
    //SLOWCLOCK toggles when counter resets, hence 1 toggle after 8 clk rising edges
    SLOW_CLOCK <= (COUNT == 3'b000) ? ~SLOW_CLOCK : SLOW_CLOCK;
end
endmodule
