`timescale 1ns/1ns

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
    integer shift_amount;

    initial begin
        `ifndef IVERILOG
            $vcdpluson;
        `endif
        `ifdef IVERILOG
            $dumpfile("nco_scaler_summer_tb.fst");
            $dumpvars(0,nco_scaler_summer_tb);
        `endif
        $readmemb("../src/audio/sine.bin", DUT.sine_lut);
        $readmemb("../src/audio/square.bin", DUT.square_lut);
        $readmemb("../src/audio/triangle.bin", DUT.triangle_lut);
        $readmemb("../src/audio/sawtooth.bin", DUT.sawtooth_lut);

        // This signal is at 880 Hz and sampled at 30kHz.
        // $readmemb("../src/audio/golden_without_interpolation.bin", golden_lut);
        $readmemb("../src/audio/golden_with_interpolation.bin", golden_lut);

        sine_shift = 0;
        square_shift = 0;
        triangle_shift = 0;
        sawtooth_shift = 0;

        shift_amount = (2**24)*880/30000;

        // NOTE: GO CHECK nco_scaler_summer.v IF FAILS
        // MOST LIKELY, SOMETHING HAS TO BE COMMENTED OUT

        for (i = 0; i < 2**24; i=i+shift_amount) begin
            #1;
            accumulated_value = i;
            if (sum_out != golden_lut[i]) begin
                $display("Golden does not match with nco output.");
                $finish();
            end
        end

        $display("All Test Passed.");
        `ifndef IVERILOG
            $vcdplusoff;
        `endif
        $finish();
    end

endmodule
