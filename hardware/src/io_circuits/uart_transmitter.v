// module uart_transmitter #(
//     parameter CLOCK_FREQ = 125_000_000,
//     parameter BAUD_RATE = 115_200)
// (
//     input clk,
//     input reset,

//     input [7:0] data_in,
//     input data_in_valid,
//     output reg data_in_ready,
//     output reg serial_out
// );

//     initial serial_out = 0;
//     initial data_in_ready = 1;
//     // See diagram in the lab guide
//     localparam  SYMBOL_EDGE_TIME    =   CLOCK_FREQ / BAUD_RATE;
//     localparam  CLOCK_COUNTER_WIDTH =   $clog2(SYMBOL_EDGE_TIME);

//     reg [CLOCK_COUNTER_WIDTH:0] counter = 0;
//     reg [31:0] frame_counter = -1; // -1 means not processing data
//     reg [9:0] data_in_copy = 0;

//     // when data_in_valid is high, get the data
//     always @ (posedge clk) begin
//         if (frame_counter == -1 && data_in_valid == 1) begin // Ready to work and data is valid
//             data_in_copy <= {1'b1, {{data_in}}, 1'b0}; // Copy data over
//             frame_counter <= 0;
//             counter <= 0;
//             data_in_ready <= 0;
//         end else if (frame_counter != -1) begin
//             if (frame_counter == 10) begin // Finished one frame
//                 data_in_ready <= 1; // Ready to work
//                 frame_counter <= -1; // Go back to not processing data state
//             end else begin// Finishing one frame
//                 if (counter == SYMBOL_EDGE_TIME) begin// start this when I have valid data
//                     counter <= 0;
//                     frame_counter <= frame_counter + 1;
//                 end else
//                     counter <= counter + 1;
//             end
//         end
//     end

//     // data_in_ready will be zero in idle (first bit)
//     // data_in_ready will be 
//     // going by 10 bits

//     always @ ( * ) begin
//         if (frame_counter != -1)
//             serial_out = data_in_copy[frame_counter];
//         else
//             serial_out = 1;
//     end
// endmodule
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

    reg [9:0] tx_shift;
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
                bit_counter <= 10;
                tx_shift <= {1'b1, {{data_in}}, 1'b0};
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

    assign data_in_ready = bit_counter == 4'd0; 
    assign serial_out = data_in_ready ? 1'b1 : tx_shift[0];
endmodule
