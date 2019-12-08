// Async Block
module nco_scaler_summer (
    input [23:0] accumulated_value,
    input [4:0] sine_shift,
    input [4:0] square_shift,
    input [4:0] triangle_shift,
    input [4:0] sawtooth_shift,
    output [19:0] sum_out
    // output [19:0] sine_out,
    // output [19:0] square_out,
    // output [19:0] triangle_out,
    // output [19:0] sawtooth_out
);

    // Although accumulated_value is 24 bits, we will be using MSB 8 bits for LUT reading.

    // Fixed point number
    reg [19:0] sine_lut [255:0];
    reg [19:0] square_lut [255:0];
    reg [19:0] triangle_lut [255:0];
    reg [19:0] sawtooth_lut [255:0];

    `define STRINGIFY_SINELUT(x) `"x/src/audio/sine.bin`"
    `define STRINGIFY_SQUARELUT(x) `"x/src/audio/square.bin`"
    `define STRINGIFY_TRIANGLELUT(x) `"x/src/audio/triangle.bin`"
    `define STRINGIFY_SAWTOOTHLUT(x) `"x/src/audio/sawtooth.bin`"

    `ifdef SYNTHESIS
        initial begin
            $readmemb(`STRINGIFY_SINELUT(`ABS_TOP), sine_lut);
            $readmemb(`STRINGIFY_SQUARELUT(`ABS_TOP), square_lut);
            $readmemb(`STRINGIFY_TRIANGLELUT(`ABS_TOP), triangle_lut);
            $readmemb(`STRINGIFY_SAWTOOTHLUT(`ABS_TOP), sawtooth_lut);
        end
    `endif

    wire [19:0] sine_out;
    wire [19:0] square_out;
    wire [19:0] triangle_out;
    wire [19:0] sawtooth_out;

    assign sine_out = $signed(sine_lut[accumulated_value[23:16]]) >>> sine_shift;
    assign square_out = $signed(square_lut[accumulated_value[23:16]]) >>> square_shift;
    assign triangle_out = $signed(triangle_lut[accumulated_value[23:16]]) >>> triangle_shift;
    assign sawtooth_out = $signed(sawtooth_lut[accumulated_value[23:16]]) >>> sawtooth_shift;

    assign sum_out = sine_out + square_out + triangle_out + sawtooth_out;
    // Comment out below and comment above when testing nco_scaler_summer_tb.
    // assign sum_out = sine_out;

endmodule
