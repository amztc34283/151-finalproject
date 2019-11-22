module uart_transmitter #(
    parameter CLOCK_FREQ = 125_000_000,
    parameter BAUD_RATE = 115_200)
(
    input clk,
    input reset,

    input [7:0] data_in,
    input data_in_valid,
    output reg data_in_ready,
    output reg serial_out
);

    initial serial_out = 0;
    initial data_in_ready = 1;
    // See diagram in the lab guide
    localparam  SYMBOL_EDGE_TIME    =   CLOCK_FREQ / BAUD_RATE;
    localparam  CLOCK_COUNTER_WIDTH =   $clog2(SYMBOL_EDGE_TIME);

    reg [CLOCK_COUNTER_WIDTH:0] counter = 0;
    reg [31:0] frame_counter = -1; // -1 means not processing data
    reg [9:0] data_in_copy = 0;

    // when data_in_valid is high, get the data
    always @ (posedge clk) begin
        if (frame_counter == -1 && data_in_valid == 1) begin // Ready to work and data is valid
            data_in_copy <= {1'b1, {{data_in}}, 1'b0}; // Copy data over
            frame_counter <= 0;
            counter <= 0;
            data_in_ready <= 0;
        end else if (frame_counter != -1) begin
            if (frame_counter == 10) begin // Finished one frame
                data_in_ready <= 1; // Ready to work
                frame_counter <= -1; // Go back to not processing data state
            end else begin// Finishing one frame
                if (counter == SYMBOL_EDGE_TIME) begin// start this when I have valid data
                    counter <= 0;
                    frame_counter <= frame_counter + 1;
                end else
                    counter <= counter + 1;
            end
        end
    end

    // data_in_ready will be zero in idle (first bit)
    // data_in_ready will be 
    // going by 10 bits

    always @ ( * ) begin
        if (frame_counter != -1)
            serial_out = data_in_copy[frame_counter];
        else
            serial_out = 1;
    end
endmodule
