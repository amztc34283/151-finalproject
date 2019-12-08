module buffer#(
    parameter real CPU_CLOCK_FREQ = 125_000_000) 
(
    input clk,
    input valid,
    input rst,
    input [11:0] from_truncator,
    output [11:0] to_cdc,
    output reg ready
);
    localparam real SAMPLE_FREQ = 30_000;
    localparam integer SAMPLE_CLOCK_COUNT = $ceil( (1/SAMPLE_FREQ) / (1/CPU_CLOCK_FREQ) )  ;
    localparam SAMPLE_COUNTER_WIDTH = $clog2(SAMPLE_CLOCK_COUNT);

    reg [SAMPLE_COUNTER_WIDTH - 1:0] sample_counter;
    always @(posedge clk) begin
        if (rst)
            sample_counter <= 0;
        else begin
            if (sample_counter == SAMPLE_CLOCK_COUNT) begin
                sample_counter <= 0;
                ready <= 1;
            end else
                sample_counter <= sample_counter + 1;
                ready <= 0;
        end
    end

    assign to_cdc = valid ? from_truncator : 12'd0;
    
endmodule
