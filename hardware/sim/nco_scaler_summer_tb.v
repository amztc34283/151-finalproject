`timescale 1ns/100ps

`define CLK_PERIOD 8

module nco_scaler_summer_tb ();
    reg [23:0] accumulated_value = 0;
    reg [4:0] sine_shift;
    reg [4:0] square_shift;
    reg [4:0] triangle_shift;
    reg [4:0] sawtooth_shift;
    wire [19:0] sum_out;

    reg [19:0] golden_lut [255:0];

    nco_scaler_summer DUT(
        .accumulated_value(accumulated_value),
        .sine_shift(sine_shift),
        .square_shift(square_shift),
        .triangle_shift(triangle_shift),
        .sawtooth_shift(sawtooth_shift),
        .sum_out(sum_out)
    );

    integer i;

    initial begin
        `ifndef IVERILOG
            $vcdpluson;
        `endif
        `ifdef IVERILOG
            $dumpfile("nco_scaler_summer_tb.fst");
            $dumpvars(0,nco_scaler_summer_tb.DUT);
        `endif
        $readmemb("../src/audio/sine.bin", DUT.sine_lut);
        $readmemb("../src/audio/square.bin", DUT.square_lut);
        $readmemb("../src/audio/triangle.bin", DUT.triangle_lut);
        $readmemb("../src/audio/sawtooth.bin", DUT.sawtooth_lut);
        $readmemb("../src/audio/golden.bin", golden_lut);

        sine_shift = 0;
        square_shift = 0;
        triangle_shift = 0;
        sawtooth_shift = 0;

        for (i = 0; i < 256; i=i+1) begin
            #1;
            accumulated_value = {i,16'h00000};
        end

        $display("All Test Passed.");
        `ifndef IVERILOG
            $vcdplusoff;
        `endif
        $finish();
    end

endmodule
