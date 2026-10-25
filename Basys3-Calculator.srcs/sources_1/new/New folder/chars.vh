// chars.vh — character codes shared by font_rom and display_renderer
// Usage: `include "chars.vh"  (inside the module body)

localparam [3:0] CH_0     = 4'd0,
                 CH_1     = 4'd1,
                 CH_2     = 4'd2,
                 CH_3     = 4'd3,
                 CH_4     = 4'd4,
                 CH_5     = 4'd5,
                 CH_6     = 4'd6,
                 CH_7     = 4'd7,
                 CH_8     = 4'd8,
                 CH_9     = 4'd9,
                 CH_PLUS  = 4'd10,
                 CH_MINUS = 4'd11,
                 CH_MUL   = 4'd12,
                 CH_DIV   = 4'd13,
                 CH_EQ    = 4'd14,
                 CH_SPACE = 4'd15;
