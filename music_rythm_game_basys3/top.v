


`timescale 1ns / 1ps



module top(
    input clk_100MHz,       // from Basys 3
    input reset,            
    output hsync,           // to VGA port
    output vsync,           // to VGA port
    output [11:0] rgb,        
    output pmod_1,
	output pmod_2,
	output pmod_4,
    output [6:0] seg,
    output [3:0] an,
    inout wire PS2_DATA,
    inout wire PS2_CLK,
        //show signal on FPGA LED for easy tracking
    output  key1, 
    output  key2, 
    output  key3, 
    output  key4,
     output [3:0] mode,
    output flip_rf30
    );
    
    wire w_reset, w_up, w_down, w_vid_on, w_p_tick;
    wire [9:0] w_x, w_y;
    reg [11:0] rgb_reg;
    wire [11:0] rgb_next;
    wire  [7:0] score;
  

    vga_controller vga(.clk_100MHz(clk_100MHz), .reset(w_reset), .video_on(w_vid_on),
                       .hsync(hsync), .vsync(vsync), .p_tick(w_p_tick), .x(w_x), .y(w_y));

    pixel_gen pg(.sys_clk(clk_100MHz), .reset(w_reset), 
            .video_on(w_vid_on), .x(w_x), .y(w_y), .rgb(rgb_next),
            .score(score), .mode(mode), .flip_30(flip_rf30),
            .seg(seg), .an(an), .PS2_DATA(PS2_DATA), .PS2_CLK(PS2_CLK),
            .key1(key1), .key2(key2), .key3(key3), .key4(key4));
    



    // rgb buffer
    always @(posedge clk_100MHz)
        if(w_p_tick)
            rgb_reg <= rgb_next;
            
    assign rgb = rgb_reg;


    //////   AUDIO   /////
    parameter BEAT_FREQ = 32'd9;	
    parameter DUTY_BEST = 10'd512;	//duty cycle=50%


    wire [31:0] freq;
    wire [7:0] ibeatNum;
    wire beatFreq;

    assign pmod_2 = 1'd1;	//no gain(6dB)
    assign pmod_4 = 1'd1;	//turn-on

    //Generate beat speed
    PWM_gen btSpeedGen ( .clk(clk_100MHz), 
                        .reset(w_reset),
                        .freq(BEAT_FREQ),
                        .duty(DUTY_BEST), 
                        .PWM(beatFreq)
    );
        
    //manipulate beat
    PlayerCtrl playerCtrl_00 ( .clk(beatFreq),
                            .reset(w_reset),
                            .ibeat(ibeatNum)
    );	
        
    //Generate variant freq. of tones
    Music music00 ( .ibeatNum(ibeatNum),
                    .tone(freq)
    );

    // Generate particular freq. signal
    PWM_gen toneGen ( .clk(clk_100MHz), 
                    .reset(w_reset), 
                    .freq(freq),
                    .duty(DUTY_BEST), 
                    .PWM(pmod_1)
    );
    
endmodule
