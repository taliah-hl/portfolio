`timescale 1ns / 1ps

module debounce( clk, in, out);
    
    input in, clk;
    output out;
    
    reg [3:0] q;
    always @ (posedge clk) begin
        q[3:1] <= q[2:0];
        q[0] <= in;
    end
    
    assign out = ((q == 4'b1111) ? 1'b1 : 1'b0);
    
endmodule

module sec_05_pulse(sys_clk, reset, in, out);
//each time press button -> create signal that last for 0.5 second
input sys_clk, in, reset;
output out;
reg signal;
reg [29:0] count, count_next;
parameter s0 = 1'b0;
parameter s1 = 1'b1; //s1 otput 1, s0 output 0;
reg state, state_next;
reg in_del;

always@(posedge sys_clk)begin
   
    in_del <= in;    
    signal <= !in_del && in;
   
end

always@(posedge sys_clk)begin

    if(reset) begin
        count <= 1'b0;
        state <= s0;
    end else begin
        state <= state_next;
        count <= count_next;
    end
end

//state flow
always@(*)begin
    case(state)
    s0: begin
        if(signal) state_next = s1;
        else state_next = s0;
        count_next = 1'd1;
    end
    s1: begin
            if(count != 24_999_999) begin
                state_next = s1;
                count_next = count + 1'b1;
            end else begin //count reach half sec
            state_next = s0;
            count_next = 1'd1;
        end
    end
    default: begin 
        state_next = s0;
        count_next = 1'd1;
    end

    endcase
end

assign out = (state ==s1)? 1:0;

endmodule