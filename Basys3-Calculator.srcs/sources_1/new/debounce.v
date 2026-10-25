`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: debounce
// 1-cycle pulse (100 MHz) per button press; 200 ms lockout after each edge
//////////////////////////////////////////////////////////////////////////////////


module debounce (
    input      clk,          // 100 MHz
    input      btn,
    output reg pulse = 0     // 1-cycle pulse per press
);
    reg [16:0] ms_cnt   = 0;  // counts 0..99_999 = 1 ms
    reg [7:0]  lockout  = 0;  // ms left to ignore the button
    reg        btn_prev = 0;  // last accepted button state

    always @(posedge clk) begin
        pulse <= 0;
        if (ms_cnt == 99_999) begin       // once every 1 ms
            ms_cnt <= 0;
            if (lockout != 0)
                lockout <= lockout - 1;   // still ignoring bounce
            else if (btn != btn_prev) begin
                btn_prev <= btn;          // accept the new state
                lockout  <= 200;          // ignore for 200 ms
                if (btn) pulse <= 1;      // only count presses
            end
        end else
            ms_cnt <= ms_cnt + 1;
    end
endmodule
