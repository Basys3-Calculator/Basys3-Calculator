// calc_params.vh — FSM states and op codes shared by calc_fsm and calc_top
// Usage: `include "calc_params.vh"  (inside the module body)

// FSM states
localparam [1:0] S_N1 = 2'd0,   // entering number 1 (also shows last answer on top line)
                 S_OP = 2'd1,   // choosing the operator
                 S_N2 = 2'd2;   // entering number 2

// Op codes — same order as CH_PLUS, CH_MINUS, CH_MUL, CH_DIV in chars.vh,
// so the display char is simply CH_PLUS + op
localparam [1:0] OP_ADD = 2'd0,
                 OP_SUB = 2'd1,
                 OP_MUL = 2'd2,
                 OP_DIV = 2'd3;
