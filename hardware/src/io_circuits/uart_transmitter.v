module uart_transmitter #(
    parameter CLOCK_FREQ = 125_000_000,
    parameter BAUD_RATE = 115_200)
(
    input clk,
    input reset,

    input [7:0] data_in,
    input data_in_valid,
    output data_in_ready,

    output serial_out
);
    // See diagram in the lab guide
    localparam  SYMBOL_EDGE_TIME    =   CLOCK_FREQ / BAUD_RATE;
    localparam  CLOCK_COUNTER_WIDTH =   $clog2(SYMBOL_EDGE_TIME);

    reg [8:0] tx_shift;
    reg [3:0] bit_counter;
    reg [CLOCK_COUNTER_WIDTH-1:0] clock_counter;

    initial bit_counter = 0;
    initial clock_counter = 0;

    always @(posedge clk) begin
        // Iniate transmit means:
        // We're not ready for new data
        // We grab the data_in from data_in
        // We send the first start bit
        if (reset) begin
            clock_counter <= 0;
            bit_counter <= 0;
            tx_shift <= 1;
        end else begin
            if (data_in_valid & data_in_ready) begin
                clock_counter <= 0;
                bit_counter <= 9;
                tx_shift <= {{{data_in}}, 1'b0};
            end else if (!data_in_ready) begin
                // Reset the symbol edge clock counter at each symbol edge time
                // Otherwise increment the clock counter
                if (clock_counter == SYMBOL_EDGE_TIME - 1) begin
                    clock_counter <= 0;
                    bit_counter <= bit_counter - 1;
                    tx_shift <= tx_shift >> 1;
                end else begin
                    clock_counter <= clock_counter + 1;
                end
            end
        end
    end

    assign data_in_ready = bit_counter == 0; 
    assign serial_out = data_in_ready ? 1 : tx_shift[0];
endmodule
