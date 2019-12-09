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
    wire note_finished;

    //Running 125MHz
    always #(`CLK_PERIOD/2) clk <= ~clk;

    phase_accum DUT(.clk(clk),
                    .fcw(fcw),
                    .ready(ready),
                    .note_start(note_start),
                    .note_release(note_release),
                    .note_reset(note_reset),
                    .accumulated_value(accumulated_value),
                    .valid(valid),
                    .note_finished(note_finished));

    integer i;

    initial begin
        `ifndef IVERILOG
            $vcdpluson;
        `endif
        `ifdef IVERILOG
            $dumpfile("phase_accum_tb.fst");
            $dumpvars(0,phase_accum_tb);
        `endif

        note_reset = 1;
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
        ready = 0;
        note_release = 1;
        repeat (1) @(posedge clk); #1;
        if (valid != 0) begin
            $display("Test Three - valid should be low when note is released.");
            $finish();
        end

        // Workflow
        note_reset = 1;
        repeat (1) @(posedge clk); #1;
        ready = 1;
        note_start = 1;
        note_release = 0;
        note_reset = 0;
        fcw = 24'h123456;
        repeat (1) @(posedge clk); #1;
        if (valid != 1 || accumulated_value != 24'd0) begin
            $display("Test Four - valid bit should be high.");
            $finish();
        end
        note_start = 0;
        ready = 1;
        note_release = 0;
        note_reset = 0;
        repeat (1) @(posedge clk); #1;
        if (valid != 1 || accumulated_value != 24'h123456) begin
            $display("Valid: %h, Value: %h", valid, accumulated_value);
            $display("Test Four - valid bit should be low and value should be 24'h123456");
            $finish();
        end
        note_release = 1;
        note_start = 0;
        note_reset = 0;
        ready = 1;
        repeat (1) @(posedge clk); #1;
        if (valid != 0 || note_finished != 1) begin
            $display("Valid: %h, Value: %h", valid, accumulated_value);
            $display("Test Four - finish bit should be high");
            $finish();
        end
        note_reset = 1;
        note_start = 0;
        note_release = 0;
        ready = 0;
        repeat (1) @(posedge clk); #1;
        if (valid != 0 || accumulated_value != 24'h123456) begin
            $display("Valid: %h, Value: %h", valid, accumulated_value);
            $display("Test Four - valid bit should be high.");
            $finish();
        end
        note_reset = 0;
        note_start = 1;
        note_release = 0;
        ready = 1;
        repeat (1) @(posedge clk); #1;
        if (valid != 1 || accumulated_value != 24'd0) begin
            $display("Test Four - valid bit should be high.");
            $finish();
        end
        note_start = 0;
        ready = 1;
        note_release = 0;
        note_reset = 0;
        repeat (1) @(posedge clk); #1;
        if (valid != 1 || accumulated_value != 24'h123456) begin
            $display("Valid: %h, Value: %h", valid, accumulated_value);
            $display("Test Four - valid bit should be low and value should be 24'h123456");
            $finish();
        end

        $display("All Test Passed.");
        `ifndef IVERILOG
            $vcdplusoff;
        `endif
        $finish();
    end

endmodule
