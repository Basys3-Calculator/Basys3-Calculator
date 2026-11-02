// Polynomial root finder states and result types.
localparam [2:0] P_S_MODE = 3'd0,
                 P_S_A    = 3'd1,
                 P_S_B    = 3'd2,
                 P_S_C    = 3'd3,
                 P_S_CALC = 3'd4,
                 P_S_RES  = 3'd5;

localparam [2:0] P_RT_NONE = 3'd0,
                 P_RT_ALL  = 3'd1,
                 P_RT_ONE  = 3'd2,
                 P_RT_DBL  = 3'd3,
                 P_RT_TWO  = 3'd4,
                 P_RT_CPX  = 3'd5;
