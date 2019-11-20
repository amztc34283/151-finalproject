module synchronizer #(parameter width = 1) (
    input [width-1:0] async_signal,
    input clk,
    output reg [width-1:0] sync_signal
);
    // Create your 2 flip-flop synchronizer here
    // This module takes in a vector of 1-bit asynchronous (from different clock domain or not clocked) signals
    // and should output a vector of 1-bit synchronous signals that are synchronized to the input clk

    reg [width-1:0] q_1, q_2;
    initial q_1 = 0;
    initial q_2 = 0; 
    always @(posedge clk)
        begin
            q_1 <= async_signal;
            q_2 <= q_1;
        end
        
    always @(*)
        begin
            sync_signal = q_2;
        end

endmodule
