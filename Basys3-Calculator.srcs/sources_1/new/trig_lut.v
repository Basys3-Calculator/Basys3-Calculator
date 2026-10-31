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
        // Convert the interpolated six-decimal values to the 10000 scale
        // used by the display and tangent quotient, rounding symmetrically.
        if (sin_i >= 0) sin_i = (sin_i + 50) / 100;
        else             sin_i = -((-sin_i + 50) / 100);
        if (cos_i >= 0) cos_i = (cos_i + 50) / 100;
        else             cos_i = -((-cos_i + 50) / 100);
        tangent_i = 0;
        numerator_abs = 0;
        denominator_abs = 0;
        undefined = 1'b0;

        case (function_select)
            2'd0: value = sin_i;
            2'd1: value = cos_i;
            2'd2: begin
                if (cos_i == 0) begin
                    undefined = 1'b1;
                    tangent_i = 0;
                end else begin
                    // Round the scaled quotient to the nearest 1/10000.
                    numerator_abs = (sin_i < 0) ? -sin_i : sin_i;
                    denominator_abs = (cos_i < 0) ? -cos_i : cos_i;
                    tangent_i = (numerator_abs * 10000 + denominator_abs / 2)
                                / denominator_abs;
                    if ((sin_i < 0) ^ (cos_i < 0))
                        tangent_i = -tangent_i;
                end
                value = tangent_i;
            end
            default: value = sin_i;
        endcase
    end
endmodule



