//
//

`define E 32'd659 //E_freq
`define F 32'd698 //F_freq
`define F_G 32'd740 //F~G_freq
`define G 32'd783 //G_freq
`define G_A 32'd831 //G~A_freq
`define A 32'd880 //A_freq
`define B 32'd987 //B_freq
`define C_up 32'd1046 //C'_freq
`define D_up 32'd1174 //D'_freq
`define E_up 32'd1319 //E_freq
`define F_up 32'd1397 //F_freq
`define G_up 32'd1568 //G_freq
`define No_sing 32'd20000 //slience (over freq.)

module Music (
	input [7:0] ibeatNum,	
	output reg [31:0] tone
);

always @(*) begin
	case (ibeatNum)		// 1/4 beat
		8'd0 : tone = `No_sing;	//3
		
		8'd1 : tone = `A;
		8'd2 : tone = `A;
		8'd3 : tone = `A;
		8'd4 : tone = `A;	//1
		8'd5 : tone = `C_up;
		8'd6 : tone = `C_up;
		8'd7 : tone = `C_up;
		8'd8 : tone = `C_up;	//2
		8'd9 : tone = `B;
		8'd10 : tone = `B;
		8'd11 : tone = `B;
		8'd12 : tone = `B;	//6-
		8'd13 : tone = `C_up;
		8'd14 : tone = `C_up;
		8'd15 : tone = `C_up;
		8'd16 : tone = `C_up;
		8'd17 : tone = `D_up;
		8'd18 : tone = `D_up;
		8'd19 : tone = `D_up;
		8'd20 : tone = `D_up;
		8'd21 : tone = `C_up;
		8'd22 : tone = `C_up;
		8'd23 : tone = `G;
		8'd24 : tone = `G;
		8'd25 : tone = `G;
		8'd26 : tone = `G;
		8'd27 : tone = `G;
		8'd28 : tone = `G;
		8'd29 : tone = `G;
		8'd30 : tone = `G;
		8'd31 : tone = `F;
		8'd32 : tone = `F;
		
		8'd33 : tone = `F;
		8'd34 : tone = `F;
		8'd35 : tone = `F;
		8'd36 : tone = `F;
		8'd37 : tone = `A;
		8'd38 : tone = `A;
		8'd39 : tone = `A;
		8'd40 : tone = `A;
		8'd41 : tone = `G;
		8'd42 : tone = `G;
		8'd43 : tone = `G;
		8'd44 : tone = `G;
		8'd45 : tone = `F;
		8'd46 : tone = `F;
		8'd47 : tone = `F;
		8'd48 : tone = `F;
		8'd49 : tone = `E;
		8'd50 : tone = `E;
		8'd51 : tone = `E;
		8'd52 : tone = `E;
		8'd53 : tone = `F;
		8'd54 : tone = `F;
		8'd55 : tone = `G;
		8'd56 : tone = `G;
		8'd57 : tone = `G;
		8'd58 : tone = `G;
		8'd59 : tone = `G;
		8'd60 : tone = `G;
		8'd61 : tone = `G;
		8'd62 : tone = `G;
		8'd63 : tone = `G;
		8'd64 : tone = `G;
		
		8'd65 : tone = `A;
		8'd66 : tone = `A;
		8'd67 : tone = `A;
		8'd68 : tone = `A;
		8'd69 : tone = `C_up;
		8'd70 : tone = `C_up;
		8'd71 : tone = `C_up;
		8'd72 : tone = `C_up;
		8'd73 : tone = `B;
		8'd74 : tone = `B;
		8'd75 : tone = `B;
		8'd76 : tone = `B;
		8'd77 : tone = `A;
		8'd78 : tone = `A;
		8'd79 : tone = `A;		
		8'd80 : tone = `A;
		8'd81 : tone = `G;
		8'd82 : tone = `G;
		8'd83 : tone = `G;
		8'd84 : tone = `G;
		8'd85 : tone = `D_up;
		8'd86 : tone = `D_up;
		8'd87 : tone = `C_up;
		8'd88 : tone = `C_up;
		8'd89 : tone = `C_up;
		8'd90 : tone = `C_up;
		8'd91 : tone = `C_up;
		8'd92 : tone = `C_up;
		8'd93 : tone = `C_up;
		8'd94 : tone = `C_up;
		8'd95 : tone = `C_up;
		8'd96 : tone = `C_up;
		
		8'd97 : tone = `D_up;
		8'd98 : tone = `D_up;
		8'd99 : tone = `D_up;
		8'd100 : tone = `D_up;
		8'd101 : tone = `C_up;
		8'd102 : tone = `C_up;
		8'd103 : tone = `C_up;
		8'd104 : tone = `C_up;
		8'd105 : tone = `B;
		8'd106 : tone = `B;
		8'd107 : tone = `B;
		8'd108 : tone = `B;
		8'd109 : tone = `A;
		8'd110 : tone = `A;
		8'd111 : tone = `A;
		8'd112 : tone = `A;
		8'd113 : tone = `B;
		8'd114 : tone = `B;
		8'd115 : tone = `B;
		8'd116 : tone = `B;
		8'd117 : tone = `C_up;
		8'd118 : tone = `C_up;
		8'd119 : tone = `D_up;
		8'd120 : tone = `D_up;
		8'd121 : tone = `D_up;
		8'd122 : tone = `D_up;
		8'd123 : tone = `D_up;
		8'd124 : tone = `D_up;
		8'd125 : tone = `D_up;
		8'd126 : tone = `D_up;
		8'd127 : tone = `D_up;
		8'd128 : tone = `D_up;	
		
		
		8'd129 : tone = `E_up;
		8'd130 : tone = `No_sing;
		8'd131 : tone = `E_up;
		8'd132 : tone = `No_sing;	//1
		8'd133 : tone = `E_up;
		8'd134 : tone = `No_sing;
		8'd135 : tone = `E_up;
		8'd136 : tone = `No_sing;	//2
		8'd137 : tone = `No_sing;
		8'd138 : tone = `G;
		8'd139 : tone = `G;
		8'd140 : tone = `C_up;	//6
		8'd141 : tone = `C_up;
		8'd142 : tone = `E_up;
		8'd143 : tone = `No_sing;
		8'd144 : tone = `F_up;
		8'd145 : tone = `F_up;
		8'd146 : tone = `F_up;
		8'd147 : tone = `F_up;
		8'd148 : tone = `F_up;
		8'd149 : tone = `E_up;
		8'd150 : tone = `D_up;
		8'd151 : tone = `D_up;
		8'd152 : tone = `D_up;
		8'd153 : tone = `D_up;
		8'd154 : tone = `D_up;
		8'd155 : tone = `D_up;
		8'd156 : tone = `D_up;
		8'd157 : tone = `D_up;
		8'd158 : tone = `D_up;
		
		8'd159 : tone = `D_up;
		8'd160 : tone = `No_sing;
		8'd161 : tone = `D_up;
		8'd162 : tone = `No_sing;
		8'd163 : tone = `D_up;
		8'd164 : tone = `No_sing;
		8'd165 : tone = `D_up;
		8'd166 : tone = `No_sing;
		8'd167 : tone = `No_sing;
		8'd168 : tone = `G;
		8'd169 : tone = `G;
		8'd170 : tone = `B;
		8'd171 : tone = `B;
		8'd172 : tone = `D_up;
		8'd173 : tone = `D_up;
		8'd174 : tone = `F_up;
		8'd175 : tone = `F_up;		
		8'd176 : tone = `F_up;
		8'd177 : tone = `F_up;
		8'd178 : tone = `E_up;
		8'd179 : tone = `E_up;
		8'd180 : tone = `E_up;
		8'd181 : tone = `E_up;
		8'd182 : tone = `E_up;
		8'd183 : tone = `E_up;
		8'd184 : tone = `E_up;
		8'd185 : tone = `E_up;
		8'd186 : tone = `E_up;
		8'd187 : tone = `E_up;
		8'd188 : tone = `E_up;
		8'd189 : tone = `E_up;
		
		8'd190 : tone = `E_up;
		8'd191 : tone = `No_sing;		
		8'd192 : tone = `E_up;
		8'd193 : tone = `No_sing;
		8'd194 : tone = `E_up;
		8'd195 : tone = `No_sing;
		8'd196 : tone = `E_up;
		8'd197 : tone = `No_sing;
		8'd198 : tone = `No_sing;
		8'd199 : tone = `E_up;
		8'd200 : tone = `E_up;
		8'd201 : tone = `F_up;
		8'd202 : tone = `F_up;
		8'd203 : tone = `G_up;
		8'd204 : tone = `No_sing;
		8'd205 : tone = `G_up;
		8'd206 : tone = `G_up;
		8'd207 : tone = `F_up;
		8'd208 : tone = `F_up;
		8'd209 : tone = `No_sing;
		8'd210 : tone = `F_up;
		8'd211 : tone = `F_up;
		8'd212 : tone = `F_up;
		8'd213 : tone = `E_up;
		8'd214 : tone = `E_up;
		8'd215 : tone = `E_up;
		8'd216 : tone = `E_up;
		8'd217 : tone = `F_up;
		8'd218 : tone = `F_up;
		
		8'd219 : tone = `E_up;
		8'd220 : tone = `E_up;
		8'd221 : tone = `E_up;
		8'd222 : tone = `E_up;
		8'd223 : tone = `E_up;
		8'd224 : tone = `E_up;
		8'd225 : tone = `E_up;
		8'd226 : tone = `E_up;
		8'd227 : tone = `D_up;
		8'd228 : tone = `D_up;
		8'd229 : tone = `D_up;
		8'd230 : tone = `D_up;
		8'd231 : tone = `D_up;
		8'd232 : tone = `D_up;
		8'd233 : tone = `D_up;
		8'd234 : tone = `D_up;
		8'd235 : tone = `C_up;
		8'd236 : tone = `C_up;
		8'd237 : tone = `C_up;
		8'd238 : tone = `C_up;
		8'd239 : tone = `B;
		8'd240 : tone = `B;
		8'd241 : tone = `B;
		8'd242 : tone = `B;
		8'd243 : tone = `C_up;
		8'd244 : tone = `C_up;
		8'd245 : tone = `C_up;
		8'd246 : tone = `C_up;
		8'd247 : tone = `D_up;
		8'd248 : tone = `D_up;
		8'd249 : tone = `D_up;
		8'd250 : tone = `D_up;
		8'd251 : tone = `C_up;
		8'd252 : tone = `C_up;
		8'd253 : tone = `C_up;
		8'd254 : tone = `C_up;
		8'd255 : tone = `No_sing;
		
		default : tone = `No_sing;
	endcase
end

endmodule