// chars.vh — character codes shared by font_rom and display_renderer
// Usage: `include "chars.vh"  (inside the module body)

localparam [4:0] CH_0     = 5'sd0,
                 CH_1     = 5'sd1,
                 CH_2     = 5'sd2,
                 CH_3     = 5'sd3,
                 CH_4     = 5'sd4,
                 CH_5     = 5'sd5,
                 CH_6     = 5'sd6,
                 CH_7     = 5'sd7,
                 CH_8     = 5'sd8,
                 CH_9     = 5'sd9,
                 CH_PLUS  = 5'sd10,
                 CH_MINUS = 5'sd11,
                 CH_MUL   = 5'sd12,
                 CH_DIV   = 5'sd13,
                 CH_EQ    = 5'sd14,
                 CH_SPACE = 5'sd15;
