//version describe
// control by keyboard
//capacity of score: 99

module mode_generator(sys_clk, reset, sec_edge_1, mode);
//each second change ouput once
//input: sec_edge_1: high signal once every second 
input sys_clk, reset, sec_edge_1;
output [1:0] mode;

parameter [4:0] init = 5'b10100;
reg [4:0] dff;
wire x1;
always@(posedge sys_clk)begin
    if(reset) begin
        dff <= init;
    end
    else if(sec_edge_1) begin
        dff[0] <= x1;
        dff[4:1] <= dff[3:0];
    end else begin
        dff[4:0] <= dff[4:0];
    end
    
end

assign x1 = dff[4] ^ dff[1];
assign mode[0]= dff[2];
assign mode[1] = dff[4];


endmodule

module pixel_gen(
    input sys_clk,
    input reset,    
    input video_on, //from vga_controller
    input [9:0] x, //from vga_controller
    input [9:0] y, //from vga_controller
    output reg [11:0] rgb,
    output reg [7:0] score,
    output [3:0] mode,
    output reg flip_30,
    output [6:0]seg, 
    output [3:0] an,
    //keyboard
    inout wire PS2_DATA,
    inout wire PS2_CLK,
    output  key1, 
    output  key2, 
    output  key3, 
    output  key4


    );

    ///  keyboard   ////
    //1=16  2=1G 3=26 4=25
    parameter [8:0] KEY_CODE_1 = 9'h16,
                 KEY_CODE_2 = 9'h1e,
                 KEY_CODE_3 = 9'h26,
                 KEY_CODE_4 = 9'h25;

    wire [8:0] last_change;//inputs from keyboardDeode
    wire [511:0] key_down;
    wire key_valid;
    reg key1_pre, key2_pre, key3_pre, key4_pre;

    //reg key1, key2, key3, key4;

    always@(*)begin
        if(key_valid && key_down[last_change] == 1'b1)begin
            if(last_change == KEY_CODE_1)begin
                {key4_pre, key3_pre, key2_pre, key1_pre} = 4'b0001;
            end
            else if(last_change == KEY_CODE_2)begin
                {key4_pre, key3_pre, key2_pre, key1_pre} = 4'b0010;
            end
            else if(last_change == KEY_CODE_3)begin
                {key4_pre, key3_pre, key2_pre, key1_pre} = 4'b0100;
            end
            else if(last_change == KEY_CODE_4)begin
              {key4_pre, key3_pre, key2_pre, key1_pre} = 4'b1000;
            end
            else   {key4_pre, key3_pre, key2_pre, key1_pre} = 4'b0000;
        end else {key4_pre, key3_pre, key2_pre, key1_pre} = 4'b0000;

    end


    KeyboardDecoder KEYD(.key_down(key_down), .last_change(last_change),.key_valid(key_valid),
    .PS2_DATA(PS2_DATA), .PS2_CLK(PS2_CLK),.rst(reset),.clk(sys_clk));

    sec_05_pulse PUL1(.sys_clk(sys_clk), .reset(reset), .in(key1_pre), .out(key1));
    sec_05_pulse PUL2(.sys_clk(sys_clk),  .reset(reset),.in(key2_pre), .out(key2));
    sec_05_pulse PUL3(.sys_clk(sys_clk), .reset(reset), .in(key3_pre), .out(key3));
    sec_05_pulse PUL4(.sys_clk(sys_clk), .reset(reset), .in(key4_pre), .out(key4));


    parameter X_MAX = 639;
    parameter Y_MAX = 479;
    
    // create 60Hz refresh tick
    wire refresh_tick;
    assign refresh_tick = ((y == 481) && (x == 0)) ? 1 : 0; // start of vsync(vertical retrace)
    
    reg [8:0]refresh_count;
    reg [5:0] refresh_count2;
    reg [7:0] refresh_count3;
    reg flip_60, flip_60_del; //flip every 1 sec
    reg  flip_30_del;  //flip every 30/60 sec, base on refresh tick
    reg flip_15, flip_15_del; //flip every 15/60 sec 

    wire sec_edge_1; //happen every 1 sec, base on refresh tick
    reg sec_1_del, sec_1_posedge;
    wire sec_edge_half; //happen every 0.5 sec, base on refresh tick
    wire sec_edge_1_8, sec_edge_1_16; //happen every 0.125s/ 0.0625 sec
    wire odd, even; //happen for 1 sys_clk cyc alternatively each second

    wire [1:0] random_mode; //generate random no.0-3 each sec
    //control which column of box should start to fall now


    //// control of divided clock based on refresh tick ////
   always@(posedge sys_clk)begin
    if(reset) begin
        refresh_count <= 9'd0;
        flip_30 <= 1'b0;
    end else if(refresh_tick) begin
        if(refresh_count == 9'd119) begin

            refresh_count <= 9'd0;
            flip_30 <= !flip_30;
        
        end else begin
            refresh_count <= refresh_count+1'b1;
            flip_30 <= flip_30;
              
            end
    end else begin
        refresh_count <= refresh_count;
        flip_30 <= flip_30;

    end
   end

   always@(posedge sys_clk)begin
    if(reset) begin
        refresh_count2 <= 6'd0;
        flip_15 <= 1'b0;
    end else if(refresh_tick) begin

        if(refresh_count2 == 6'd14) begin
            refresh_count2 <= 6'd0;
            flip_15 <= !flip_15;
        end else begin
            refresh_count2 <= refresh_count2 +1'b1;
            flip_15 <= flip_15;
        end

    end else begin
        refresh_count2 <= refresh_count2;
        flip_15 <= flip_15;
    end
   end

    always@(posedge sys_clk)begin
    if(reset) begin
        refresh_count3 <= 8'd0;
        flip_60 <= 1'b0;
    end else if(refresh_tick) begin

        if(refresh_count3 == 8'd239) begin
            refresh_count3 <= 8'd0;
            flip_60 <= !flip_60;
        end else begin
            refresh_count3 <= refresh_count3 +1'b1;
            flip_60 <= flip_60;
        end

    end else begin
        refresh_count3 <= refresh_count3;
        flip_60 <= flip_60;
    end

   end

   always@(posedge sys_clk)begin
    flip_30_del <= flip_30;
    flip_15_del <= flip_15;
    flip_60_del <= flip_60;
   end

    assign sec_edge_1 = !flip_30_del && flip_30;    //happen once every sec
    assign sec_edge_half = flip_30_del ^ flip_30;   //happen once every half sec
    assign sec_edge_1_8 = !flip_15_del && flip_15;  //happen once every 1/8 sec
    assign sec_edge_1_16 = flip_15_del ^ flip_15;   //happen once every 1/16 sec
    assign odd = flip_60_del && !flip_60; //1->0    //od evwn happen once every 2 sec alternatively
    assign even = !flip_60_del && flip_60; //0->1

   
    //assign random_mode to mode for LED display
    assign mode[0] = (random_mode==2'd0)? 1:0;
    assign mode[1] = (random_mode==2'd1)? 1:0;
    assign mode[2] = (random_mode==2'd2)? 1:0;
    assign mode[3] = (random_mode==2'd3)? 1:0;

    
        
    ///  colour setting  ////
    wire [11:0]  BOX1_rgb,  BOX2_rgb;
    wire [11:0] bg_rgb;

    parameter col1_rgb = 12'hFCD; //pink
    parameter col2_rgb = 12'hFE7;  //yellow
    parameter col3_rgb = 12'h9FC;  //lake green
    parameter col4_rgb = 12'h8DF;  //lake blue

    parameter FALLING_BOX_rgb = 12'hFD7;
    parameter SCORE_CHAR_rgb =  12'hFD7;
    parameter line_rgb = 12'h9BD;
    assign bg_rgb = 12'h035;
    assign BOX1_rgb = FALLING_BOX_rgb;
    assign BOX2_rgb = FALLING_BOX_rgb;
    parameter [11:0] not_match_rgb = 12'hBCC;
    parameter [11:0]  match_rgb = 12'hFAB;

    ///  BOX attributes declaration   ////
    parameter BOX_VELOCITY = 13;
    parameter BOX_COUNTER_MAX = 7'd31; //32/16sec = 2 sec
    reg [6:0] BOX1_counter ,BOX2_counter, BOX3_counter, BOX4_counter, 
            BOX1_counter_next,BOX2_counter_next, BOX3_counter_next, BOX4_counter_next;

    reg box1_state, box1_state_next, box2_state, box2_state_next;
    parameter s0 = 1'b0;
    parameter s1 = 1'b1;

    wire [6:0] BOX_HEIGHT;
    assign BOX_HEIGHT  = 4'd10;

    wire col1_match, col2_match, col3_match, col4_match;
    reg col1_match_del, col2_match_del, col3_match_del, col4_match_del;
    reg [1:0] box1_col, box2_col, box1_col_next, box2_col_next;

    reg [9:0] x_box1_L, x_box1_R, x_box2_L, x_box2_R;
    
    parameter X_COL1_L = 252;
    parameter X_COL1_R = 317;    
    parameter X_COL2_L = 342;
    parameter X_COL2_R = 407; 
    parameter X_COL3_L = 432;
    parameter X_COL3_R = 497; 
    parameter X_COL4_L = 522;
    parameter X_COL4_R = 587; 

    //// line position
    parameter LINE1_L = 240;
    parameter LINE1_R = 241;
    parameter LINE2_L = 330;
    parameter LINE2_R = 331;
    parameter LINE3_L = 420;
    parameter LINE3_R = 421;
    parameter LINE4_L = 510;
    parameter LINE4_R = 511;
    parameter LINE5_L = 600;
    parameter LINE5_R = 601;
    parameter HZ_LINE_top=423;
    parameter HZ_LINE_bottom=424;

        
        


    ////  player   ///

        assign MATCHED_ENLARGE = 10;
        wire [9:0] X_PLY_COL1_L, X_PLY_COL1_R,X_PLY_COL2_L, X_PLY_COL2_R, X_PLY_COL3_L,X_PLY_COL3_R,X_PLY_COL4_L,X_PLY_COL4_R;

        assign X_PLY_COL1_L = col1_match? X_COL1_L - MATCHED_ENLARGE: X_COL1_L;
        assign X_PLY_COL1_R = col1_match? X_COL1_R + MATCHED_ENLARGE: X_COL1_R;    
        assign X_PLY_COL2_L = col2_match? X_COL2_L - MATCHED_ENLARGE: X_COL2_L;
        assign X_PLY_COL2_R = col2_match? X_COL2_R + MATCHED_ENLARGE: X_COL2_R;
        assign X_PLY_COL3_L = col3_match? X_COL3_L - MATCHED_ENLARGE: X_COL3_L;
        assign X_PLY_COL3_R = col3_match? X_COL3_R + MATCHED_ENLARGE: X_COL3_R;
        assign X_PLY_COL4_L = col4_match? X_COL4_L - MATCHED_ENLARGE : X_COL4_L;
        assign X_PLY_COL4_R = col4_match? X_COL4_R + MATCHED_ENLARGE : X_COL4_R;
        
        //// player's attributes declaration

        
        wire [9:0] Y_PLY_BOTTOM; //box last top=456, last bottom = 466
        assign Y_PLY_BOTTOM = (col1_match || col2_match ||col3_match ||col4_match) ? 434:430;
        wire [9:0] Y_PLY_TOP;
        assign Y_PLY_TOP = (col1_match || col2_match ||col3_match ||col4_match) ? 410:416;

        wire [9:0] y_ply_col1_top, y_ply_col2_top, y_ply_col3_top, y_ply_col4_top;
       

        //keyboard version
        assign y_ply_col1_top = key1? Y_PLY_TOP:Y_PLY_BOTTOM;
        assign y_ply_col2_top = key2? Y_PLY_TOP:Y_PLY_BOTTOM;
        assign y_ply_col3_top = key3? Y_PLY_TOP:Y_PLY_BOTTOM;
        assign y_ply_col4_top = key4? Y_PLY_TOP:Y_PLY_BOTTOM;

         assign col1_match = key1 && 
           ( ((box1_col == 2'd0) && (( BOX1_counter== BOX_COUNTER_MAX-1) ||( BOX1_counter== BOX_COUNTER_MAX)))
            || ((box2_col == 2'd0) && (( BOX2_counter== BOX_COUNTER_MAX-1) ||( BOX2_counter== BOX_COUNTER_MAX))));

        assign col2_match = key2 && 
           ( ((box1_col == 2'd1) && (( BOX1_counter== BOX_COUNTER_MAX-1) ||( BOX1_counter== BOX_COUNTER_MAX)))
            || ((box2_col == 2'd1) && (( BOX2_counter== BOX_COUNTER_MAX-1) ||( BOX2_counter== BOX_COUNTER_MAX))));

        assign col3_match = key3 && 
           ( ((box1_col == 2'd2) && (( BOX1_counter== BOX_COUNTER_MAX-1) ||( BOX1_counter== BOX_COUNTER_MAX)))
            || ((box2_col == 2'd2) && (( BOX2_counter== BOX_COUNTER_MAX-1) ||( BOX2_counter== BOX_COUNTER_MAX))));

        assign col4_match = key4 && 
           ( ((box1_col == 2'd3) && (( BOX1_counter== BOX_COUNTER_MAX-1) ||( BOX1_counter== BOX_COUNTER_MAX)))
            || ((box2_col == 2'd3) && (( BOX2_counter== BOX_COUNTER_MAX-1) ||( BOX2_counter== BOX_COUNTER_MAX))));

        ////    Score     ////
        reg [7:0]score_next;
        parameter D1_X = 20; //(D1_X, D1_Y) =top left corner of  D1
        parameter D1_Y = 160;
        parameter [2:0]SCORE_CHAR_WIDTH = 3'd6;
        wire score_add_one; //score add 1 unit
        wire [6:0] seg_d0, seg_d1;


        always@(posedge sys_clk)begin
            if(reset) score <=8'b0;
            else score <=score_next;

            col1_match_del <= col1_match;
            col2_match_del <= col2_match;
            col3_match_del <= col3_match;
            col4_match_del <= col4_match;
        end

        assign score_add_one = (!col1_match_del && col1_match)
                         || (!col2_match_del && col2_match) 
                         || (!col3_match_del && col3_match)
                         || (!col4_match_del && col4_match);

        always@(*)begin
            if(score_add_one) score_next = score +1;
            else  score_next = score;
            
        end

        Seg_ctrl SEG1(.clk(sys_clk), .amt(score), .seg(seg), .an(an), .seg_d0(seg_d0), .seg_d1(seg_d1));

        wire d1_a_on, d1_b_on, d1_c_on, d1_d_on, d1_e_on, d1_f_on, d1_g_on;
        wire d2_a_on, d2_b_on, d2_c_on, d2_d_on, d2_e_on, d2_f_on, d2_g_on;

        wire [9:0] D1_A_L,D1_A_R,D1_A_TOP,D1_A_BOTTOM,D1_B_L,D1_B_R,D1_B_TOP,D1_B_BOTTOM,D1_C_L,D1_C_R,D1_C_TOP,D1_C_BOTTOM,
            D1_D_L, D1_D_R, D1_D_TOP, D1_D_BOTTOM, D1_E_L, D1_E_R, D1_E_TOP, D1_E_BOTTOM, D1_F_L, D1_F_R, D1_F_TOP, D1_F_BOTTOM,
            D1_G_L, D1_G_R, D1_G_TOP, D1_G_BOTTOM;

        wire [9:0] D2_A_L,D2_A_R,D2_A_TOP,D2_A_BOTTOM,D2_B_L,D2_B_R,D2_B_TOP,D2_B_BOTTOM,D2_C_L,D2_C_R,D2_C_TOP,D2_C_BOTTOM,
            D2_D_L, D2_D_R, D2_D_TOP, D2_D_BOTTOM, D2_E_L,  D2_E_R, D2_E_TOP, D2_E_BOTTOM, D2_F_L, D2_F_R, D2_F_TOP, D2_F_BOTTOM,
            D2_G_L, D2_G_R, D2_G_TOP, D2_G_BOTTOM;
        wire [8:0] D2_X, D2_Y;
            
        assign D2_X = 9'd120; //(D2_X, D2_Y) =top left corner of  D2
        assign D2_Y = D1_Y;

        //D1: digit 1 (more significant bit)
        assign D1_A_L = D1_X;
        assign D1_A_R = D1_X+9'd50;
        assign D1_A_TOP = D1_Y;
        assign D1_A_BOTTOM = D1_Y + SCORE_CHAR_WIDTH;
        assign D1_B_L = D1_X +9'd46;
        assign D1_B_R = D1_X +9'd46+SCORE_CHAR_WIDTH;
        assign D1_B_TOP = D1_Y;
        assign D1_B_BOTTOM = D1_Y +9'd38;
        assign D1_C_L = D1_X +9'd46;
        assign D1_C_R = D1_X +9'd46+SCORE_CHAR_WIDTH;
        assign D1_C_TOP = D1_Y+9'd41;
        assign D1_C_BOTTOM = D1_Y + 9'd80;
        assign D1_D_L = D1_X;
        assign D1_D_R = D1_X+9'd50;
        assign D1_D_TOP = D1_Y + 9'd77;
        assign D1_D_BOTTOM = D1_Y +9'd77 +SCORE_CHAR_WIDTH;
        assign D1_E_L = D1_X;
        assign D1_E_R = D1_X+SCORE_CHAR_WIDTH;
        assign D1_E_TOP = D1_Y +41;
        assign D1_E_BOTTOM = D1_Y + 9'd80;
        assign D1_F_L = D1_X ; 
        assign D1_F_R =  D1_X+SCORE_CHAR_WIDTH;
        assign D1_F_TOP = D1_Y;
        assign D1_F_BOTTOM = D1_Y +9'd38;
        assign D1_G_L = D1_X +9'd6;
        assign D1_G_R = D1_X +9'd44;
        assign D1_G_TOP = D1_Y +9'd38;
        assign D1_G_BOTTOM = D1_Y +9'd38+ SCORE_CHAR_WIDTH;


        //D2: digit 2 (less significant bit)
        assign D2_A_L = D2_X;
        assign D2_A_R = D2_X+9'd50;
        assign D2_A_TOP = D2_Y;
        assign D2_A_BOTTOM = D2_Y + SCORE_CHAR_WIDTH;
        assign D2_B_L = D2_X +9'd46;
        assign D2_B_R = D2_X +9'd46+SCORE_CHAR_WIDTH;
        assign D2_B_TOP = D2_Y;
        assign D2_B_BOTTOM = D2_Y +9'd38;
        assign D2_C_L = D2_X +9'd46;
        assign D2_C_R = D2_X +9'd46+SCORE_CHAR_WIDTH;
        assign D2_C_TOP = D2_Y+9'd41;
        assign D2_C_BOTTOM = D2_Y + 9'd80;
        assign D2_D_L = D2_X;
        assign D2_D_R = D2_X+9'd50;
        assign D2_D_TOP = D2_Y + 9'd77;
        assign D2_D_BOTTOM = D2_Y +9'd77 +SCORE_CHAR_WIDTH;
        assign D2_E_L = D2_X;
        assign D2_E_R = D2_X+SCORE_CHAR_WIDTH;
        assign D2_E_TOP = D2_Y +41;
        assign D2_E_BOTTOM = D2_Y + 9'd80;
        assign D2_F_L = D2_X ; 
        assign D2_F_R =  D2_X+SCORE_CHAR_WIDTH;
        assign D2_F_TOP = D2_Y;
        assign D2_F_BOTTOM = D2_Y +9'd38;
        assign D2_G_L = D2_X +9'd6;
        assign D2_G_R = D2_X +9'd44;
        assign D2_G_TOP = D2_Y +9'd38;
        assign D2_G_BOTTOM = D2_Y +9'd38+ SCORE_CHAR_WIDTH;

        // D1
       assign d1_a_on = !seg_d1[0] && ((D1_A_L <= x) && (x <= D1_A_R) &&     
                        (D1_A_TOP <= y) && (y <= D1_A_BOTTOM) ); 

       assign d1_b_on = !seg_d1[1] && ((D1_B_L <= x) && (x <= D1_B_R) &&     
                        (D1_B_TOP <= y) && (y <= D1_B_BOTTOM));

        assign d1_c_on = !seg_d1[2]&& ((D1_C_L <= x) && (x <= D1_C_R) &&     
                    (D1_C_TOP <= y) && (y <= D1_C_BOTTOM));

        assign d1_d_on =  !seg_d1[3] &&( (D1_D_L <= x) && (x <= D1_D_R) &&     
                    (D1_D_TOP <= y) && (y <= D1_D_BOTTOM));
        assign d1_e_on = !seg_d1[4] && ((D1_E_L <= x) && (x <= D1_E_R) &&     
                    (D1_E_TOP <= y) && (y <= D1_E_BOTTOM));
        assign d1_f_on = !seg_d1[5] && ((D1_F_L <= x) && (x <= D1_F_R) &&     
                    (D1_F_TOP <= y) && (y <= D1_F_BOTTOM));
        assign d1_g_on = !seg_d1[6] &&((D1_G_L <= x) && (x <= D1_G_R) &&     
                    (D1_G_TOP <= y) && (y <= D1_G_BOTTOM));

        // D2
       assign d2_a_on = !seg_d0[0] && ((D2_A_L <= x) && (x <= D2_A_R) &&     
                        (D2_A_TOP <= y) && (y <= D2_A_BOTTOM) ); 

       assign d2_b_on = !seg_d0[1] && ((D2_B_L <= x) && (x <= D2_B_R) &&     
                        (D2_B_TOP <= y) && (y <= D2_B_BOTTOM));

        assign d2_c_on = !seg_d0[2] && ((D2_C_L <= x) && (x <= D2_C_R) &&     
                    (D2_C_TOP <= y) && (y <= D2_C_BOTTOM));

        assign d2_d_on =  !seg_d0[3] && ( (D2_D_L <= x) && (x <= D2_D_R) &&     
                    (D2_D_TOP <= y) && (y <= D2_D_BOTTOM));
        assign d2_e_on = !seg_d0[4] && ( (D2_E_L <= x) && (x <= D2_E_R) &&     
                    (D2_E_TOP <= y) && (y <= D2_E_BOTTOM));
        assign d2_f_on = !seg_d0[5]  && ((D2_F_L <= x) && (x <= D2_F_R) &&     
                    (D2_F_TOP <= y) && (y <= D2_F_BOTTOM));
        assign d2_g_on = !seg_d0[6] && ((D2_G_L <= x) && (x <= D2_G_R) &&     
                    (D2_G_TOP <= y) && (y <= D2_G_BOTTOM));

        
        ////  CHARACTER   //////


        wire SCORE_S_on, SCORE_C_on, SCORE_O_on, SCORE_R_on, SCORE_E_on;


        //SCORE
        parameter SCORE_S_1_L = 15;
        parameter SCORE_S_1_R = 45;
        parameter SCORE_S_1_U = 60;
        parameter SCORE_S_1_D = 70; 
        parameter SCORE_S_2_L = 15;
        parameter SCORE_S_2_R = 25;
        parameter SCORE_S_2_U = 60;
        parameter SCORE_S_2_D = 80; 
        parameter SCORE_S_3_L = 15;
        parameter SCORE_S_3_R = 45;
        parameter SCORE_S_3_U = 80;
        parameter SCORE_S_3_D = 90;
        parameter SCORE_S_4_L = 35;
        parameter SCORE_S_4_R = 45;
        parameter SCORE_S_4_U = 80;
        parameter SCORE_S_4_D = 110;
        parameter SCORE_S_5_L = 15;
        parameter SCORE_S_5_R = 45;
        parameter SCORE_S_5_U = 100;
        parameter SCORE_S_5_D = 110;   
            
        parameter SCORE_C_1_L = 55;
        parameter SCORE_C_1_R = 85;
        parameter SCORE_C_1_U = 60;
        parameter SCORE_C_1_D = 70;
        parameter SCORE_C_2_L = 55;
        parameter SCORE_C_2_R = 65;
        parameter SCORE_C_2_U = 60;
        parameter SCORE_C_2_D = 110;
        parameter SCORE_C_3_L = 55;
        parameter SCORE_C_3_R = 85;
        parameter SCORE_C_3_U = 100;
        parameter SCORE_C_3_D = 110;
        
        parameter SCORE_O_1_L = 95;
        parameter SCORE_O_1_R = 125;
        parameter SCORE_O_1_U = 60;
        parameter SCORE_O_1_D = 70;
        parameter SCORE_O_2_L = 95;
        parameter SCORE_O_2_R = 105;
        parameter SCORE_O_2_U = 60;
        parameter SCORE_O_2_D = 110; 
        parameter SCORE_O_3_L = 95;
        parameter SCORE_O_3_R = 125;
        parameter SCORE_O_3_U = 100;
        parameter SCORE_O_3_D = 110;
        parameter SCORE_O_4_L = 115;
        parameter SCORE_O_4_R = 125;
        parameter SCORE_O_4_U = 60;
        parameter SCORE_O_4_D = 110;
        
        parameter SCORE_R_1_L = 135;
        parameter SCORE_R_1_R = 145;
        parameter SCORE_R_1_U = 60;
        parameter SCORE_R_1_D = 110;
        parameter SCORE_R_2_L = 135;
        parameter SCORE_R_2_R = 165;
        parameter SCORE_R_2_U = 60;
        parameter SCORE_R_2_D = 70;
        parameter SCORE_R_3_L = 135;
        parameter SCORE_R_3_R = 165;
        parameter SCORE_R_3_U = 80;
        parameter SCORE_R_3_D = 90;
        parameter SCORE_R_4_L = 155;
        parameter SCORE_R_4_R = 165;
        parameter SCORE_R_4_U = 60;
        parameter SCORE_R_4_D = 90;
        parameter SCORE_R_5_L = 150;
        parameter SCORE_R_5_R = 160;
        parameter SCORE_R_5_U = 80;
        parameter SCORE_R_5_D = 110;
        
        parameter SCORE_E_1_L = 175;
        parameter SCORE_E_1_R = 185;
        parameter SCORE_E_1_U = 60;
        parameter SCORE_E_1_D = 110;
        parameter SCORE_E_2_L = 175;
        parameter SCORE_E_2_R = 205;
        parameter SCORE_E_2_U = 60;
        parameter SCORE_E_2_D = 70;
        parameter SCORE_E_3_L = 175;
        parameter SCORE_E_3_R = 205;
        parameter SCORE_E_3_U = 80;
        parameter SCORE_E_3_D = 90;
        parameter SCORE_E_4_L = 175;
        parameter SCORE_E_4_R = 205;
        parameter SCORE_E_4_U = 100;
        parameter SCORE_E_4_D = 110;

        
        parameter SCORE__1_L = 215;
        parameter SCORE__1_R = 225;
        parameter SCORE__1_U = 70;
        parameter SCORE__1_D = 80;
        parameter SCORE__2_L = 215;
        parameter SCORE__2_R = 225;
        parameter SCORE__2_U = 90;
        parameter SCORE__2_D = 100;
       

        assign SCORE_S_on = ((x>=SCORE_S_1_L && x<=SCORE_S_1_R && y>=SCORE_S_1_U && y<=SCORE_S_1_D) || (x>=SCORE_S_2_L && x<=SCORE_S_2_R && y>=SCORE_S_2_U && y<=SCORE_S_2_D) || (x>=SCORE_S_3_L && x<=SCORE_S_3_R && y>=SCORE_S_3_U && y<=SCORE_S_3_D) 
                        || (x>=SCORE_S_4_L && x<=SCORE_S_4_R && y>=SCORE_S_4_U && y<=SCORE_S_4_D) || (x>=SCORE_S_5_L && x<=SCORE_S_5_R && y>=SCORE_S_5_U && y<=SCORE_S_5_D)); 
        assign SCORE_C_on = ((x>=SCORE_C_1_L && x<=SCORE_C_1_R && y>=SCORE_C_1_U && y<=SCORE_C_1_D) || (x>=SCORE_C_2_L && x<=SCORE_C_2_R && y>=SCORE_C_2_U && y<=SCORE_C_2_D) || (x>=SCORE_C_3_L && x<=SCORE_C_3_R && y>=SCORE_C_3_U && y<=SCORE_C_3_D))
                                || (x>=SCORE__1_L && x<=SCORE__1_R && y>=SCORE__1_U && y<=SCORE__1_D) || (x>=SCORE__2_L && x<=SCORE__2_R && y>=SCORE__2_U && y<=SCORE__2_D);
        assign SCORE_O_on = ((x>=SCORE_O_1_L && x<=SCORE_O_1_R && y>=SCORE_O_1_U && y<=SCORE_O_1_D) || (x>=SCORE_O_2_L && x<=SCORE_O_2_R && y>=SCORE_O_2_U && y<=SCORE_O_2_D) || (x>=SCORE_O_3_L && x<=SCORE_O_3_R && y>=SCORE_O_3_U && y<=SCORE_O_3_D)
                                || (x>=SCORE_O_4_L && x<=SCORE_O_4_R && y>=SCORE_O_4_U && y<=SCORE_O_4_D));
        assign SCORE_R_on = ((x>=SCORE_R_1_L && x<=SCORE_R_1_R && y>=SCORE_R_1_U && y<=SCORE_R_1_D) || (x>=SCORE_R_2_L && x<=SCORE_R_2_R && y>=SCORE_R_2_U && y<=SCORE_R_2_D) || (x>=SCORE_R_3_L && x<=SCORE_R_3_R && y>=SCORE_R_3_U && y<=SCORE_R_3_D) 
                                || (x>=SCORE_R_4_L && x<=SCORE_R_4_R && y>=SCORE_R_4_U && y<=SCORE_R_4_D) || (x>=SCORE_R_5_L && x<=SCORE_R_5_R && y>=SCORE_R_5_U && y<=SCORE_R_5_D));
        assign SCORE_E_on = ((x>=SCORE_E_1_L && x<=SCORE_E_1_R && y>=SCORE_E_1_U && y<=SCORE_E_1_D) || (x>=SCORE_E_2_L && x<=SCORE_E_2_R && y>=SCORE_E_2_U && y<=SCORE_E_2_D) || (x>=SCORE_E_3_L && x<=SCORE_E_3_R && y>=SCORE_E_3_U && y<=SCORE_E_3_D) 
                                || (x>=SCORE_E_4_L && x<=SCORE_E_4_R && y>=SCORE_E_4_U && y<=SCORE_E_4_D));  
 


        reg [11:0] click_col1_rgb, click_col2_rgb, click_col3_rgb, click_col4_rgb;

        always@(*)begin
            if(col1_match) click_col1_rgb = match_rgb;
            else click_col1_rgb = not_match_rgb;
            if(col2_match) click_col2_rgb = match_rgb;
            else click_col2_rgb = not_match_rgb;
            if(col3_match) click_col3_rgb = match_rgb;
            else click_col3_rgb = not_match_rgb;
            if(col4_match) click_col4_rgb = match_rgb;
            else click_col4_rgb = not_match_rgb;

        end


        wire ply_col1_on, ply_col2_on, ply_col3_on, ply_col4_on;
        
        //pixel for player's click on n-th column
        assign ply_col1_on = (X_PLY_COL1_L <= x) && (x <= X_PLY_COL1_R) &&     
                        (y_ply_col1_top < y) && (y < Y_PLY_BOTTOM) ; 
        
        assign ply_col2_on = (X_PLY_COL2_L <= x) && (x <= X_PLY_COL2_R) &&     
                        (y_ply_col2_top < y) && (y < Y_PLY_BOTTOM);
        assign ply_col3_on = (X_PLY_COL3_L <= x) && (x <= X_PLY_COL3_R) &&     
                        (y_ply_col3_top < y) && (y < Y_PLY_BOTTOM);

        assign ply_col4_on = (X_PLY_COL4_L <= x) && (x <= X_PLY_COL4_R) &&     
                    (y_ply_col4_top < y) && (y < Y_PLY_BOTTOM);       


        ////  Background lines
        wire LINE1_on, LINE2_on, LINE3_on, LINE4_on, LINE5_on, HZ_LINE_on;
        wire LINE_on;

        

        assign LINE_on = ((LINE1_L <= x) && (x <= LINE1_R) )|| ((LINE2_L <= x) && (x <= LINE2_R)) 
                ||((LINE3_L <= x) && (x <= LINE3_R)) || ( (LINE4_L <= x) && (x <= LINE4_R))
                || ((LINE5_L <= x) && (x <= LINE5_R)) || ((HZ_LINE_top <= y) && (y <= HZ_LINE_bottom));

        
        //// falling boxes  ////
        // register to track top boundary and buffer
        wire [9:0] y_BOX1_top, y_BOX1_bottom, y_BOX2_top, y_BOX2_bottom; 
        reg [9:0] y_BOX1, y_BOX1_next; //BOX top position
        reg [9:0] y_BOX2, y_BOX2_next; 
        reg [9:0] y_BOX3, y_BOX3_next; 
        reg [9:0] y_BOX4, y_BOX4_next;

        wire BOX1_on, BOX2_on, BOX3_on, BOX4_on;

        assign y_BOX1_top = y_BOX1;                             // paddle top position
        assign y_BOX1_bottom = y_BOX1_top + BOX_HEIGHT;              // paddle bottom position
        assign BOX1_on = (x_box1_L <= x) && (x <= x_box1_R) &&     // pixel within paddle boundaries
                        (y_BOX1_top < y) && (y < y_BOX1_bottom);


        assign y_BOX2_top = y_BOX2;                             // paddle top position
        assign y_BOX2_bottom = y_BOX2_top + BOX_HEIGHT;              // paddle bottom position
        assign BOX2_on = (x_box2_L <= x) && (x <= x_box2_R) &&     // pixel within paddle boundaries
                        (y_BOX2_top < y) && (y < y_BOX2_bottom);



    ///// random BOX falling   /////
    //Change mode per 1 second

    mode_generator MOGR(.sys_clk(sys_clk), .reset(reset), .sec_edge_1(sec_edge_1), 
        .mode(random_mode));

    always@(*)begin
        case(box1_state)
        s0: begin
            if(odd) begin
                BOX1_counter_next = 1'b1;
                box1_state_next = s1;
                box1_col_next = random_mode;
            end else begin
                BOX1_counter_next = 1'b0;
                box1_state_next = s0;
                box1_col_next = box1_col;
            end
            end
        
        s1: begin
            if(BOX1_counter!=BOX_COUNTER_MAX) begin
                BOX1_counter_next = BOX1_counter + 1'b1;
                box1_state_next = s1;
            end else begin
                BOX1_counter_next = 1'b0;
                box1_state_next = s0;
            end
            box1_col_next = box1_col;
        end
        endcase
    end

    always@(*)begin
        case(box2_state)
        s0: begin
            if(even) begin
                BOX2_counter_next = 1'b1;
                box2_state_next = s1;
                box2_col_next = random_mode;
            end else begin
                BOX2_counter_next = 1'b0;
                box2_state_next = s0;
                box2_col_next = box2_col;
            end
            end
        
        s1: begin
            if(BOX2_counter!=BOX_COUNTER_MAX) begin
                BOX2_counter_next = BOX2_counter + 1'b1;
                box2_state_next = s1;
            end else begin
                BOX2_counter_next = 1'b0;
                box2_state_next = s0;
            end
            box2_col_next = box2_col;
        end
        endcase
    end

    //determine horizontal position of box
    always@(*)begin
        case(box1_col)
        2'd0: begin
            
            x_box1_L = X_COL1_L;
            x_box1_R = X_COL1_R;
        end
        2'd1: begin
            
            x_box1_L = X_COL2_L;
            x_box1_R = X_COL2_R;
        end
        2'd2: begin
            
            x_box1_L = X_COL3_L;
            x_box1_R = X_COL3_R;
        end
        2'd3: begin
            
            x_box1_L = X_COL4_L;
            x_box1_R = X_COL4_R;
        end


        endcase

        case(box2_col)
        2'd0:begin
            
            x_box2_L = X_COL1_L;
            x_box2_R = X_COL1_R;
        end 
        2'd1: begin
            
            x_box2_L = X_COL2_L;
            x_box2_R = X_COL2_R;
        end
        2'd2: begin
            
            x_box2_L = X_COL3_L;
            x_box2_R = X_COL3_R;
        end 
        2'd3: begin
            
            x_box2_L = X_COL4_L;
            x_box2_R = X_COL4_R;
        end 

        endcase
    end
    

    //BOX_counter update rate
    always@(posedge sys_clk)begin

        if(reset) begin
            BOX1_counter <= 1'b0;
            BOX2_counter <= 1'b0;
            box1_col <= 0;
            box2_col <=0;
            box1_state <= s0;
            box2_state <= s0;
        end
        else begin
            
            if(sec_edge_1_16) begin //1/16 sec
                BOX1_counter <= BOX1_counter_next;
                BOX2_counter <= BOX2_counter_next;
                box1_col <= box1_col_next;
                box2_col <= box2_col_next;
                box1_state <= box1_state_next;
                box2_state <= box2_state_next;
            end else begin
                BOX1_counter <= BOX1_counter;
                BOX2_counter <= BOX2_counter;
                box1_col <= box1_col;
                box2_col <= box2_col;
                box1_state <= box1_state;
                box2_state <= box2_state;
            end
        end
    end



    // BOX Falling Control
    // BOX move down 1 block every 1/16 sec

    always@(*)begin

        if(BOX1_counter == 3'd0 || BOX1_counter == BOX_COUNTER_MAX) y_BOX1_next = 10'd480;
        else if(BOX1_counter == 3'd1)y_BOX1_next = 10'd40;
        else y_BOX1_next = y_BOX1 + BOX_VELOCITY;

    end

    always@(*)begin
        if(BOX2_counter == 3'd0|| BOX2_counter == BOX_COUNTER_MAX) y_BOX2_next = 10'd480;
        else if(BOX2_counter == 3'd1)y_BOX2_next = 10'd40;
        else y_BOX2_next = y_BOX2 + BOX_VELOCITY;


    end
   

     always @(posedge sys_clk or posedge reset)
            if(reset) begin
                y_BOX1 <= 1'b0;
                y_BOX2 <= 1'b0;
          
            end
            else begin
            if(sec_edge_1_16)begin //update every 1/16sec
                y_BOX1 <= y_BOX1_next;
                y_BOX2 <= y_BOX2_next;
   
             end else begin
                y_BOX1 <= y_BOX1;
                y_BOX2 <= y_BOX2;

             end
                
            end
    

    ///  determine rgb 
     always @*
        if(~video_on)
            rgb = 12'h000;      // no value, blank
        else begin
           
            if(ply_col1_on)
                rgb = click_col1_rgb;            
            else if(ply_col2_on)
                rgb = click_col2_rgb; 
            else if(ply_col3_on)
                rgb = click_col3_rgb;
            else if(ply_col4_on)
                rgb = click_col4_rgb;
            else if(BOX1_on)
                rgb = BOX1_rgb;    
            else if(BOX2_on)
                rgb = BOX2_rgb; 
            else if(LINE_on)
                rgb = line_rgb;
            else if( ( (d1_a_on||d1_b_on)  || (d1_c_on||d1_d_on) ) || ( (d1_e_on|| d1_f_on) || (d1_g_on|| d2_a_on) )
            || ( (d2_b_on||d2_c_on)  || (d2_d_on||d2_e_on) ) || (d2_f_on||d2_g_on) )
                rgb = SCORE_CHAR_rgb;
            else if(SCORE_S_on || SCORE_C_on|| SCORE_O_on|| SCORE_R_on|| SCORE_E_on)
                rgb = SCORE_CHAR_rgb;
            else   rgb = bg_rgb;       // background

        end


    

endmodule
