module buffer#(
    parameter real CPU_CLOCK_FREQ = 50_000_000)
(
    input clk,
    input valid,
    input rst,
    input [11:0] from_truncator,
    input tx_ack,
    output reg tx_req,
    output reg [11:0] to_cdc,
    output reg ready
);
    localparam real SAMPLE_FREQ = 30_000;
    // localparam integer SAMPLE_CLOCK_COUNT = $ceil( (1/SAMPLE_FREQ) / (1/CPU_CLOCK_FREQ) )  ;
    localparam integer SAMPLE_CLOCK_COUNT = CPU_CLOCK_FREQ/SAMPLE_FREQ;
    localparam SAMPLE_COUNTER_WIDTH = $clog2(SAMPLE_CLOCK_COUNT);

    // counter_state is zero when it is not counting
    reg counter_state = 0;

    reg [SAMPLE_COUNTER_WIDTH - 1:0] sample_counter;
    always @(posedge clk) begin
        if (rst) begin // which rst, the note_reset or global_synth_rst
            sample_counter <= 0;
            ready <= 1;
            counter_state <= 0;
        end else begin
            if (counter_state && sample_counter == SAMPLE_CLOCK_COUNT) begin
                sample_counter <= 0;
                ready <= 1;
                counter_state <= 0;
            end else if (!counter_state && valid) begin
                sample_counter <= sample_counter + 1;
                ready <= 0;
                counter_state <= 1;
            end else if (counter_state) begin
                sample_counter <= sample_counter + 1;
            end
        end
    end

    reg waiting_ack = 0;

    always @(posedge clk) begin
        if (rst) begin
            to_cdc <= 0;
            tx_req <= 0;
            waiting_ack <= 0;
        end else begin
            // possible bug on valid signal
            // HANDSHAKE LOGIC
            if (valid && !counter_state && !waiting_ack) begin
                // to_cdc has to hold as long as tx_req is high
                to_cdc <= from_truncator;
                tx_req <= 1;
                waiting_ack <= 1;
            end else if (waiting_ack && tx_ack) begin
                tx_req <= 0;
                waiting_ack <= 0;
            end
        end

        // Req High
        // Ack High
        // Req Low
        // Ack Low
    end

endmodule
