module trig_lut(
    input  wire [9:0] angle,
    input  wire [1:0] function_select,
    input  wire       radian_mode,
    output reg signed [31:0] value,
    output reg       undefined
    );

    integer a;
    integer sin_i;
    integer cos_i;
    integer tangent_i;
    integer numerator_abs;
    integer denominator_abs;
    integer phase_x2000;
    integer sin_display_i;
    integer cos_display_i;
    reg signed [63:0] sin_abs64;
    reg signed [63:0] cos_abs64;
    reg signed [63:0] tangent_scaled64;

    // Internal sine values are scaled by 1000000. The table uses
    // half-degree entries so interpolation is accurate to four decimals.
    function signed [31:0] sine_quarter;
        input [7:0] half_degree;
        begin
            case (half_degree)
                8'd0: sine_quarter = 32'sd0;
                8'd1: sine_quarter = 32'sd8727;
                8'd2: sine_quarter = 32'sd17452;
                8'd3: sine_quarter = 32'sd26177;
                8'd4: sine_quarter = 32'sd34899;
                8'd5: sine_quarter = 32'sd43619;
                8'd6: sine_quarter = 32'sd52336;
                8'd7: sine_quarter = 32'sd61049;
                8'd8: sine_quarter = 32'sd69756;
                8'd9: sine_quarter = 32'sd78459;
                8'd10: sine_quarter = 32'sd87156;
                8'd11: sine_quarter = 32'sd95846;
                8'd12: sine_quarter = 32'sd104528;
                8'd13: sine_quarter = 32'sd113203;
                8'd14: sine_quarter = 32'sd121869;
                8'd15: sine_quarter = 32'sd130526;
                8'd16: sine_quarter = 32'sd139173;
                8'd17: sine_quarter = 32'sd147809;
                8'd18: sine_quarter = 32'sd156434;
                8'd19: sine_quarter = 32'sd165048;
                8'd20: sine_quarter = 32'sd173648;
                8'd21: sine_quarter = 32'sd182236;
                8'd22: sine_quarter = 32'sd190809;
                8'd23: sine_quarter = 32'sd199368;
                8'd24: sine_quarter = 32'sd207912;
                8'd25: sine_quarter = 32'sd216440;
                8'd26: sine_quarter = 32'sd224951;
                8'd27: sine_quarter = 32'sd233445;
                8'd28: sine_quarter = 32'sd241922;
                8'd29: sine_quarter = 32'sd250380;
                8'd30: sine_quarter = 32'sd258819;
                8'd31: sine_quarter = 32'sd267238;
                8'd32: sine_quarter = 32'sd275637;
                8'd33: sine_quarter = 32'sd284015;
                8'd34: sine_quarter = 32'sd292372;
                8'd35: sine_quarter = 32'sd300706;
                8'd36: sine_quarter = 32'sd309017;
                8'd37: sine_quarter = 32'sd317305;
                8'd38: sine_quarter = 32'sd325568;
                8'd39: sine_quarter = 32'sd333807;
                8'd40: sine_quarter = 32'sd342020;
                8'd41: sine_quarter = 32'sd350207;
                8'd42: sine_quarter = 32'sd358368;
                8'd43: sine_quarter = 32'sd366501;
                8'd44: sine_quarter = 32'sd374607;
                8'd45: sine_quarter = 32'sd382683;
                8'd46: sine_quarter = 32'sd390731;
                8'd47: sine_quarter = 32'sd398749;
                8'd48: sine_quarter = 32'sd406737;
                8'd49: sine_quarter = 32'sd414693;
                8'd50: sine_quarter = 32'sd422618;
                8'd51: sine_quarter = 32'sd430511;
                8'd52: sine_quarter = 32'sd438371;
                8'd53: sine_quarter = 32'sd446198;
                8'd54: sine_quarter = 32'sd453990;
                8'd55: sine_quarter = 32'sd461749;
                8'd56: sine_quarter = 32'sd469472;
                8'd57: sine_quarter = 32'sd477159;
                8'd58: sine_quarter = 32'sd484810;
                8'd59: sine_quarter = 32'sd492424;
                8'd60: sine_quarter = 32'sd500000;
                8'd61: sine_quarter = 32'sd507538;
                8'd62: sine_quarter = 32'sd515038;
                8'd63: sine_quarter = 32'sd522499;
                8'd64: sine_quarter = 32'sd529919;
                8'd65: sine_quarter = 32'sd537300;
                8'd66: sine_quarter = 32'sd544639;
                8'd67: sine_quarter = 32'sd551937;
                8'd68: sine_quarter = 32'sd559193;
                8'd69: sine_quarter = 32'sd566406;
                8'd70: sine_quarter = 32'sd573576;
                8'd71: sine_quarter = 32'sd580703;
                8'd72: sine_quarter = 32'sd587785;
                8'd73: sine_quarter = 32'sd594823;
                8'd74: sine_quarter = 32'sd601815;
                8'd75: sine_quarter = 32'sd608761;
                8'd76: sine_quarter = 32'sd615661;
                8'd77: sine_quarter = 32'sd622515;
                8'd78: sine_quarter = 32'sd629320;
                8'd79: sine_quarter = 32'sd636078;
                8'd80: sine_quarter = 32'sd642788;
                8'd81: sine_quarter = 32'sd649448;
                8'd82: sine_quarter = 32'sd656059;
                8'd83: sine_quarter = 32'sd662620;
                8'd84: sine_quarter = 32'sd669131;
                8'd85: sine_quarter = 32'sd675590;
                8'd86: sine_quarter = 32'sd681998;
                8'd87: sine_quarter = 32'sd688355;
                8'd88: sine_quarter = 32'sd694658;
                8'd89: sine_quarter = 32'sd700909;
                8'd90: sine_quarter = 32'sd707107;
                8'd91: sine_quarter = 32'sd713250;
                8'd92: sine_quarter = 32'sd719340;
                8'd93: sine_quarter = 32'sd725374;
                8'd94: sine_quarter = 32'sd731354;
                8'd95: sine_quarter = 32'sd737277;
                8'd96: sine_quarter = 32'sd743145;
                8'd97: sine_quarter = 32'sd748956;
                8'd98: sine_quarter = 32'sd754710;
                8'd99: sine_quarter = 32'sd760406;
                8'd100: sine_quarter = 32'sd766044;
                8'd101: sine_quarter = 32'sd771625;
                8'd102: sine_quarter = 32'sd777146;
                8'd103: sine_quarter = 32'sd782608;
                8'd104: sine_quarter = 32'sd788011;
                8'd105: sine_quarter = 32'sd793353;
                8'd106: sine_quarter = 32'sd798636;
                8'd107: sine_quarter = 32'sd803857;
                8'd108: sine_quarter = 32'sd809017;
                8'd109: sine_quarter = 32'sd814116;
                8'd110: sine_quarter = 32'sd819152;
                8'd111: sine_quarter = 32'sd824126;
                8'd112: sine_quarter = 32'sd829038;
                8'd113: sine_quarter = 32'sd833886;
                8'd114: sine_quarter = 32'sd838671;
                8'd115: sine_quarter = 32'sd843391;
                8'd116: sine_quarter = 32'sd848048;
                8'd117: sine_quarter = 32'sd852640;
                8'd118: sine_quarter = 32'sd857167;
                8'd119: sine_quarter = 32'sd861629;
                8'd120: sine_quarter = 32'sd866025;
                8'd121: sine_quarter = 32'sd870356;
                8'd122: sine_quarter = 32'sd874620;
                8'd123: sine_quarter = 32'sd878817;
                8'd124: sine_quarter = 32'sd882948;
                8'd125: sine_quarter = 32'sd887011;
                8'd126: sine_quarter = 32'sd891007;
                8'd127: sine_quarter = 32'sd894934;
                8'd128: sine_quarter = 32'sd898794;
                8'd129: sine_quarter = 32'sd902585;
                8'd130: sine_quarter = 32'sd906308;
                8'd131: sine_quarter = 32'sd909961;
                8'd132: sine_quarter = 32'sd913545;
                8'd133: sine_quarter = 32'sd917060;
                8'd134: sine_quarter = 32'sd920505;
                8'd135: sine_quarter = 32'sd923880;
                8'd136: sine_quarter = 32'sd927184;
                8'd137: sine_quarter = 32'sd930418;
                8'd138: sine_quarter = 32'sd933580;
                8'd139: sine_quarter = 32'sd936672;
                8'd140: sine_quarter = 32'sd939693;
                8'd141: sine_quarter = 32'sd942641;
                8'd142: sine_quarter = 32'sd945519;
                8'd143: sine_quarter = 32'sd948324;
                8'd144: sine_quarter = 32'sd951057;
                8'd145: sine_quarter = 32'sd953717;
                8'd146: sine_quarter = 32'sd956305;
                8'd147: sine_quarter = 32'sd958820;
                8'd148: sine_quarter = 32'sd961262;
                8'd149: sine_quarter = 32'sd963630;
                8'd150: sine_quarter = 32'sd965926;
                8'd151: sine_quarter = 32'sd968148;
                8'd152: sine_quarter = 32'sd970296;
                8'd153: sine_quarter = 32'sd972370;
                8'd154: sine_quarter = 32'sd974370;
                8'd155: sine_quarter = 32'sd976296;
                8'd156: sine_quarter = 32'sd978148;
                8'd157: sine_quarter = 32'sd979925;
                8'd158: sine_quarter = 32'sd981627;
                8'd159: sine_quarter = 32'sd983255;
                8'd160: sine_quarter = 32'sd984808;
                8'd161: sine_quarter = 32'sd986286;
                8'd162: sine_quarter = 32'sd987688;
                8'd163: sine_quarter = 32'sd989016;
                8'd164: sine_quarter = 32'sd990268;
                8'd165: sine_quarter = 32'sd991445;
                8'd166: sine_quarter = 32'sd992546;
                8'd167: sine_quarter = 32'sd993572;
                8'd168: sine_quarter = 32'sd994522;
                8'd169: sine_quarter = 32'sd995396;
                8'd170: sine_quarter = 32'sd996195;
                8'd171: sine_quarter = 32'sd996917;
                8'd172: sine_quarter = 32'sd997564;
                8'd173: sine_quarter = 32'sd998135;
                8'd174: sine_quarter = 32'sd998630;
                8'd175: sine_quarter = 32'sd999048;
                8'd176: sine_quarter = 32'sd999391;
                8'd177: sine_quarter = 32'sd999657;
                8'd178: sine_quarter = 32'sd999848;
                8'd179: sine_quarter = 32'sd999962;
                8'd180: sine_quarter = 32'sd1000000;
                default: sine_quarter = 32'sd0;
            endcase
        end
    endfunction

    // Interpolate between adjacent half-degree entries at six-decimal
    // internal precision, then round to four decimal places.
    function signed [31:0] sine_fixed_degree;
        input integer degree_x2000;
        integer d;
        integer f;
        integer s0;
        integer s1;
        begin
            d = degree_x2000 % 720000;
            if (d < 0) d = d + 720000;
            f = d % 1000;
            d = d / 1000;
            s0 = sine_degree(d);
            s1 = sine_degree(d + 1);
            sine_fixed_degree = s0 + ((s1 - s0) * f) / 1000;
        end
    endfunction

    // The input and lookup period are expressed in half-degree units.
    function signed [31:0] sine_degree;
        input integer half_degree;
        integer d;
        integer q;
        begin
            d = half_degree % 720;
            if (d < 0) d = d + 720;
            if (d <= 180) begin
                q = d;
                sine_degree = sine_quarter(q[7:0]);
            end else if (d <= 360) begin
                q = 360-d;
                sine_degree = sine_quarter(q[7:0]);
            end else if (d <= 540) begin
                q = d-360;
                sine_degree = -sine_quarter(q[7:0]);
            end else begin
                q = 720-d;
                sine_degree = -sine_quarter(q[7:0]);
            end
        end
    endfunction

    // Integer-degree tangent values are kept directly at 1e-4 precision.
    // This avoids magnifying 1e6-scale sine/cosine quantization near 90 degrees.
    function signed [31:0] tangent_degree_mag;
        input integer degree;
        begin
            case (degree)
                0: tangent_degree_mag = 32'sd0;
                1: tangent_degree_mag = 32'sd175;
                2: tangent_degree_mag = 32'sd349;
                3: tangent_degree_mag = 32'sd524;
                4: tangent_degree_mag = 32'sd699;
                5: tangent_degree_mag = 32'sd875;
                6: tangent_degree_mag = 32'sd1051;
                7: tangent_degree_mag = 32'sd1228;
                8: tangent_degree_mag = 32'sd1405;
                9: tangent_degree_mag = 32'sd1584;
                10: tangent_degree_mag = 32'sd1763;
                11: tangent_degree_mag = 32'sd1944;
                12: tangent_degree_mag = 32'sd2126;
                13: tangent_degree_mag = 32'sd2309;
                14: tangent_degree_mag = 32'sd2493;
                15: tangent_degree_mag = 32'sd2679;
                16: tangent_degree_mag = 32'sd2867;
                17: tangent_degree_mag = 32'sd3057;
                18: tangent_degree_mag = 32'sd3249;
                19: tangent_degree_mag = 32'sd3443;
                20: tangent_degree_mag = 32'sd3640;
                21: tangent_degree_mag = 32'sd3839;
                22: tangent_degree_mag = 32'sd4040;
                23: tangent_degree_mag = 32'sd4245;
                24: tangent_degree_mag = 32'sd4452;
                25: tangent_degree_mag = 32'sd4663;
                26: tangent_degree_mag = 32'sd4877;
                27: tangent_degree_mag = 32'sd5095;
                28: tangent_degree_mag = 32'sd5317;
                29: tangent_degree_mag = 32'sd5543;
                30: tangent_degree_mag = 32'sd5774;
                31: tangent_degree_mag = 32'sd6009;
                32: tangent_degree_mag = 32'sd6249;
                33: tangent_degree_mag = 32'sd6494;
                34: tangent_degree_mag = 32'sd6745;
                35: tangent_degree_mag = 32'sd7002;
                36: tangent_degree_mag = 32'sd7265;
                37: tangent_degree_mag = 32'sd7536;
                38: tangent_degree_mag = 32'sd7813;
                39: tangent_degree_mag = 32'sd8098;
                40: tangent_degree_mag = 32'sd8391;
                41: tangent_degree_mag = 32'sd8693;
                42: tangent_degree_mag = 32'sd9004;
                43: tangent_degree_mag = 32'sd9325;
                44: tangent_degree_mag = 32'sd9657;
                45: tangent_degree_mag = 32'sd10000;
                46: tangent_degree_mag = 32'sd10355;
                47: tangent_degree_mag = 32'sd10724;
                48: tangent_degree_mag = 32'sd11106;
                49: tangent_degree_mag = 32'sd11504;
                50: tangent_degree_mag = 32'sd11918;
                51: tangent_degree_mag = 32'sd12349;
                52: tangent_degree_mag = 32'sd12799;
                53: tangent_degree_mag = 32'sd13270;
                54: tangent_degree_mag = 32'sd13764;
                55: tangent_degree_mag = 32'sd14281;
                56: tangent_degree_mag = 32'sd14826;
                57: tangent_degree_mag = 32'sd15399;
                58: tangent_degree_mag = 32'sd16003;
                59: tangent_degree_mag = 32'sd16643;
                60: tangent_degree_mag = 32'sd17321;
                61: tangent_degree_mag = 32'sd18040;
                62: tangent_degree_mag = 32'sd18807;
                63: tangent_degree_mag = 32'sd19626;
                64: tangent_degree_mag = 32'sd20503;
                65: tangent_degree_mag = 32'sd21445;
                66: tangent_degree_mag = 32'sd22460;
                67: tangent_degree_mag = 32'sd23559;
                68: tangent_degree_mag = 32'sd24751;
                69: tangent_degree_mag = 32'sd26051;
                70: tangent_degree_mag = 32'sd27475;
                71: tangent_degree_mag = 32'sd29042;
                72: tangent_degree_mag = 32'sd30777;
                73: tangent_degree_mag = 32'sd32709;
                74: tangent_degree_mag = 32'sd34874;
                75: tangent_degree_mag = 32'sd37321;
                76: tangent_degree_mag = 32'sd40108;
                77: tangent_degree_mag = 32'sd43315;
                78: tangent_degree_mag = 32'sd47046;
                79: tangent_degree_mag = 32'sd51446;
                80: tangent_degree_mag = 32'sd56713;
                81: tangent_degree_mag = 32'sd63138;
                82: tangent_degree_mag = 32'sd71154;
                83: tangent_degree_mag = 32'sd81443;
                84: tangent_degree_mag = 32'sd95144;
                85: tangent_degree_mag = 32'sd114301;
                86: tangent_degree_mag = 32'sd143007;
                87: tangent_degree_mag = 32'sd190811;
                88: tangent_degree_mag = 32'sd286363;
                89: tangent_degree_mag = 32'sd572900;
                default: tangent_degree_mag = 32'sd0;
            endcase
        end
    endfunction


    always @(*) begin
        a = angle;
        if (radian_mode)
            // 360000/pi = 114591.5590 half-degree-thousandths per radian.
            // Split the constant to retain the fractional part without
            // overflowing a 32-bit integer for the maximum input of 999.
            phase_x2000 = a * 114591 + ((a * 559 + 500) / 1000);
        else
            phase_x2000 = a * 2000;
        sin_i = sine_fixed_degree(phase_x2000);
        cos_i = sine_fixed_degree(phase_x2000 + 180000);
        // Round sine/cosine only for their displayed values. Tangent must use
        // the original 1e6-scale values before rounding, otherwise values near
        // 90 degrees lose substantial accuracy.
        if (sin_i >= 0) sin_display_i = (sin_i + 50) / 100;
        else             sin_display_i = -((-sin_i + 50) / 100);
        if (cos_i >= 0) cos_display_i = (cos_i + 50) / 100;
        else             cos_display_i = -((-cos_i + 50) / 100);
        tangent_i = 0;
        numerator_abs = 0;
        denominator_abs = 0;
        sin_abs64 = sin_i;
        cos_abs64 = cos_i;
        if (sin_abs64 < 0) sin_abs64 = -sin_abs64;
        if (cos_abs64 < 0) cos_abs64 = -cos_abs64;
        tangent_scaled64 = 64'sd0;
        undefined = 1'b0;

        case (function_select)
            2'd0: value = sin_display_i;
            2'd1: value = cos_display_i;
            2'd2: begin
                // The rounded cosine check intentionally remains the guard for
                // undefined results shown on the OLED.
                if (cos_display_i == 0) begin
                    undefined = 1'b1;
                    tangent_i = 0;
                end else if (!radian_mode) begin
                    // For whole-degree input, use the direct 1e-4 table.
                    // tan(theta + 180) = tan(theta), and
                    // tan(180-theta) = -tan(theta).
                    if ((a % 180) < 90)
                        tangent_i = tangent_degree_mag(a % 180);
                    else
                        tangent_i = -tangent_degree_mag(180 - (a % 180));
                end else begin
                    // Round the ratio of the 1e6-scale values to 1/10000.
                    // The 64-bit product is required because 1e6*10000 does
                    // not fit in a signed 32-bit intermediate.
                    tangent_scaled64 = (sin_abs64 * 64'sd10000 +
                                        cos_abs64 / 2) / cos_abs64;
                    tangent_i = tangent_scaled64;
                end
                if (radian_mode && ((sin_i < 0) ^ (cos_i < 0)))
                    tangent_i = -tangent_i;
                else if (!radian_mode && ((a % 360) >= 180 && (a % 180) < 90))
                    tangent_i = -tangent_i;
                value = tangent_i;
            end
            default: value = sin_display_i;
        endcase
    end
endmodule



