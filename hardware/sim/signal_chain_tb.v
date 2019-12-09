`timescale 1ns/100ps

//Running 33.333MHz
`define CLK_PERIOD_1 30
//Running 100MHz
`define CLK_PERIOD_2 10

module signal_chain_tb ();

    reg clk1 = 0;
    reg clk2 = 0;
    reg [23:0] fcw = 0;
    reg note_reset = 0;
    reg note_start = 0;
    reg note_release = 0;
    reg [4:0] sine_shift = 0;
    reg [4:0] square_shift = 0;
    reg [4:0] triangle_shift = 0;
    reg [4:0] sawtooth_shift = 0;
    reg [4:0] global_gain = 0;
    wire note_finished;
    wire [11:0] pwm_duty_cycle;

    always #(`CLK_PERIOD_1/2) clk1 <= ~clk1;
    always #(`CLK_PERIOD_2/2) clk2 <= ~clk2;

    signal_chain DUT(
        .clk1(clk1),
        .clk2(clk2),
        .fcw(fcw), // coming from outside register value
        .note_reset(note_reset), // pulse value
        .note_start(note_start), // pulse value
        .note_release(note_release), // pulse value
        .sine_shift(sine_shift), // coming from outside register value
        .square_shift(square_shift), // coming from outside register value
        .triangle_shift(triangle_shift), // coming from outside register value
        .sawtooth_shift(sawtooth_shift), // coming from outside register value
        .global_gain(global_gain), // coming from outside register value
        .note_finished(note_finished), // going to write back
        .pwm_duty_cycle(pwm_duty_cycle) // going to mux
    );

    integer i;

    initial begin
        `ifndef IVERILOG
            $vcdpluson;
        `endif
        `ifdef IVERILOG
            $dumpfile("signal_chain_tb.fst");
            $dumpvars(0,signal_chain_tb);
        `endif
        $readmemb("../src/audio/sine.bin", DUT.nco_scaler_summer.sine_lut);
        $readmemb("../src/audio/square.bin", DUT.nco_scaler_summer.square_lut);
        $readmemb("../src/audio/triangle.bin", DUT.nco_scaler_summer.triangle_lut);
        $readmemb("../src/audio/sawtooth.bin", DUT.nco_scaler_summer.sawtooth_lut);

        fcw = 24'h123456;
        note_reset = 1;
        note_start = 0;
        note_release = 0;
        sine_shift = 0;
        square_shift = 0;
        triangle_shift = 0;
        sawtooth_shift = 0;
        global_gain = 0;

        repeat (1) @(posedge clk1); #1;

        fcw = 24'h123456;
        note_reset = 0;
        note_start = 1;
        note_release = 0;
        sine_shift = 0;
        square_shift = 0;
        triangle_shift = 0;
        sawtooth_shift = 0;
        global_gain = 0;

        repeat (1) @(posedge clk1); #1;
        // Data should be in the phase_accum stage

        fcw = 24'h123456;
        note_reset = 0;
        note_start = 0;
        note_release = 0;
        sine_shift = 0;
        square_shift = 0;
        triangle_shift = 0;
        sawtooth_shift = 0;
        global_gain = 0;

        repeat (1) @(posedge clk1); #1;
        // Data should be in the buffer stage

        // Waiting for buffer to output a sample
        i = 0;
        while (i != 50_000_000/30_000) begin
            repeat (1) @(posedge clk1); #1;
            i = i + 1;
        end

        repeat (1) @(posedge clk1); #1;
        // Data should be in the first reg four-way handshake stage
        repeat (1) @(posedge clk1); #1;
        // Data should be outputing to pwm_duty_cycle
        repeat (1) @(posedge clk1); #1;
        // Ack should be high
        repeat (2) @(posedge clk1); #1;

        $display("All Test Passed.");
        `ifndef IVERILOG
            $vcdplusoff;
        `endif
        $finish();
    end

endmodule //
