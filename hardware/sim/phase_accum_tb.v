`timescale 1ns/100ps

`define CLK_PERIOD 8

module phase_accum_tb();

    reg clk = 0;
    reg [23:0] fcw = 0;
    reg ready = 0;
    reg note_start = 0;
    reg note_reset = 0;
    reg note_release = 0;
    wire [23:0] accumulated_value;
    wire valid;

    //Running 125MHz
    always #(`CLK_PERIOD/2) clk <= ~clk;

    phase_accum DUT(.clk(clk),
                    .fcw(fcw),
                    .ready(ready),
                    .note_start(note_start),
                    .note_release(note_release),
                    .note_reset(note_reset),
                    .accumulated_value(accumulated_value),
                    .valid(valid));

    integer i;

    initial begin
        `ifndef IVERILOG
            $vcdpluson;
        `endif
        `ifdef IVERILOG
            $dumpfile("phase_accum_tb.fst");
            $dumpvars(0,phase_accum_tb);
        `endif

        repeat (10) @(posedge clk); #1;

        // Sanity Test Case
        fcw = 24'h123456;
        ready = 1;
        note_start = 1;
        note_reset = 0;
        note_release = 0;
        repeat (1) @(posedge clk); #1;
        if (valid != 1) begin
            $display("Test One - Valid Bit is not set.");
            $finish();
        end
        if (accumulated_value != 0) begin
            $display("Test One - accumulated_value should be zero.");
            $finish();
        end
        repeat (1) @(posedge clk); #1;
        if (valid != 1) begin
            $display("Test One - Valid Bit should still be high when ready is high.");
            $finish();
        end
        if (accumulated_value != 24'h123456) begin
            $display("Test One - accumulated_value should be incremented by one fcw.");
            $finish();
        end

        // Reset Test Case
        note_reset = 1;
        repeat (1) @(posedge clk); #1;
        if (valid != 0) begin
            $display("Test Two - Valid Bit is set.");
            $finish();
        end
        note_start = 1;
        note_reset = 1;
        repeat (1) @(posedge clk); #1;
        if (valid != 0) begin
            $display("Test Two - Valid Bit should remain low.");
            $finish();
        end
        note_start = 1;
        note_reset = 0;
        repeat (1) @(posedge clk); #1;
        if (valid != 1) begin
            $display("Test Two - Valid Bit is not set.");
            $finish();
        end
        if (accumulated_value != 0) begin
            $display("Test Two - accumulated_value should be zero.");
            $finish();
        end
        repeat (1) @(posedge clk); #1;
        if (valid != 1) begin
            $display("Test Two - Valid Bit should still be high when ready is high.");
            $finish();
        end
        if (accumulated_value != 24'h123456) begin
            $display("Test Two - accumulated_value should be incremented by one fcw.");
            $finish();
        end

        // note_finished should be high when note is released.
        // Release Test Case
        note_release = 1;
        repeat (1) @(posedge clk); #1;
        if (valid != 0) begin
            $display("Test Three - valid should be low when note is released.");
            $finish();
        end

        $display("All Test Passed.");
        `ifndef IVERILOG
            $vcdplusoff;
        `endif
        $finish();
    end

endmodule
