
module Seg_ctrl(clk, reset, amt, seg, an, seg_d0, seg_d1); //transfer decimal to 4 digit 7-seg (max value 1999)
    input clk; //100MHzclk
    input reset;
    input [7:0]  amt;
    output reg [6:0] seg;   //for 7-segment on FPGA
    output reg [3:0] an;
    output reg[6:0] seg_d0;     //for vga screen
    output reg[6:0] seg_d1;  //for vga screen

reg [1:0] digit_select; //determine digit
reg [16:0] digit_timer;
wire [3:0] amt_divi_10; //amount divded by 10
wire [7:0] amt_divi_100;
reg [10:0] amt_100_d;
reg [6:0] amt_10_d;
wire [6:0] amt_10_d_pre;
wire [3:0] amt_1_d;
wire [6:0] amt_reduced;


 parameter [6:0] zero=7'b1000000,
                    one=7'b1111001,
                    two=7'b0100100,
                    three=7'b0110000,
                    four=7'b0011001,
                    five=7'b0010010, 
                    six=7'b0000010,
                    seven=7'b1111000,                                  
                    eight=7'b0000000,
                    nine=7'b0011000,
                    all_off = 7'b1111111;


    assign amt_reduced = amt[6:0]; // at most <100
    assign amt_divi_10 = amt / 4'd10;
    assign amt_divi_100 = amt_divi_10 / 4'd10;

    assign amt_10_d_pre = amt - amt_100_d;
    assign amt_1_d = amt_reduced - amt_10_d; //個位= 89-80

    

    always@(*)begin


        if(amt_reduced > 10'd89) amt_10_d =  90;
        else if(amt_reduced > 10'd79)   amt_10_d = 80;
        else if(amt_reduced > 10'd69)   amt_10_d =70;
        else if(amt_reduced > 10'd59) amt_10_d =60;
        else if(amt_reduced > 10'd49) amt_10_d =50;
        else if(amt_reduced > 10'd39) amt_10_d =40;
        else if(amt_reduced > 10'd29) amt_10_d =30;
        else if(amt_reduced > 10'd19) amt_10_d =20;
        else if(amt_reduced > 10'd9) amt_10_d =10;
        else amt_10_d = 0;
    end

    

    always@(posedge clk) begin
    //every 100,000 digit timer count from 0 again 
        if(reset) digit_select<=1'b0;
        else begin
       
        if(digit_timer ==17'd99999)begin
            digit_timer <=17'd0;
            digit_select <= digit_select +1'b1;
        end
        
        else begin
            digit_timer <= digit_timer+1; 
            digit_select<=digit_select;
        end
        end
    end

    always@(*)begin
        case(digit_select)
            2'b00 : an=4'b1110;
            2'b01 : an=4'b1101;
            2'b10 : an=4'b1011;
            2'b11 : an=4'b0111;
        endcase

    end


    always@(*)begin
        case(digit_select)
            2'b00: 
                case(amt_1_d)
                    4'd0: seg = zero;
                    4'd1: seg = one;
                    4'd2: seg = two;
                    4'd3: seg = three;
                    4'd4: seg = four;
                    4'd5: seg = five;
                    4'd6: seg = six;
                    4'd7: seg = seven;
                    4'd8: seg = eight;
                    4'd9: seg = nine;
                    default: seg =zero;
                endcase
                
               
            2'b01:
                case(amt_10_d)
                    7'd0: seg = zero;
                    7'd10: seg = one;
                    7'd20: seg = two;
                    7'd30: seg = three;
                    7'd40: seg = four;
                    7'd50: seg = five;
                    7'd60: seg = six;
                    7'd70: seg = seven;
                    7'd80: seg = eight;
                    7'd90: seg = nine;
                    default: seg = all_off;

                endcase
            2'b10:                 
               
                seg = all_off;
                
            2'b11:
              seg = all_off;
           default: seg = all_off;

        endcase

    end

    always@(*)begin
        case(amt_1_d)
                    4'd0: seg_d0 = zero;
                    4'd1: seg_d0 = one;
                    4'd2: seg_d0 = two;
                    4'd3: seg_d0 = three;
                    4'd4: seg_d0 = four;
                    4'd5: seg_d0 = five;
                    4'd6: seg_d0 = six;
                    4'd7: seg_d0 = seven;
                    4'd8: seg_d0 = eight;
                    4'd9: seg_d0 = nine;
                    default: seg_d0 =zero;
                endcase
    end

    always@(*)begin
         case(amt_10_d)
                    7'd0: seg_d1 = zero;
                    7'd10: seg_d1 = one;
                    7'd20: seg_d1 = two;
                    7'd30: seg_d1 = three;
                    7'd40: seg_d1 = four;
                    7'd50: seg_d1 = five;
                    7'd60: seg_d1 = six;
                    7'd70: seg_d1 = seven;
                    7'd80: seg_d1 = eight;
                    7'd90: seg_d1 = nine;
                    default: seg_d1 = all_off;

                endcase
    end

endmodule