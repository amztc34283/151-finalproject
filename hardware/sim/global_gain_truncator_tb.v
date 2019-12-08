`timescale 1ns/1ns

`define CLK_PERIOD 8

module global_gain_truncator_tb ();
    reg [4:0] global_gain;
    reg [19:0] summer_value;
    wire [11:0] truncated_value;

    global_gain_truncator DUT(
        .global_gain(global_gain),
        .summer_value(summer_value),
        .truncated_value(truncated_value)
    );

    initial begin
        global_gain = 5'b00000;
        summer_value = 20'h00000;
        #1;
        if (truncated_value != 12'd2048) begin
            $display("Sanity Check: The value should be 2048.");
            $finish();
        end

        global_gain = 5'b00000;
        summer_value = 20'h80000;
        #1;
        if (truncated_value != 12'd0) begin
            $display("Sanity Check: The value should be 0.");
            $finish();
        end

        global_gain = 5'b00000;
        summer_value = 20'h7ff00;
        #1;
        if (truncated_value != 12'd4095) begin
            $display("Sanity Check: The value should be 4095.");
            $finish();
        end

        global_gain = 5'b00000;
        summer_value = 20'hfff00;
        #1;
        if (truncated_value != 12'd2047) begin
            $display("Sanity Check: The value should be 2047.");
            $finish();
        end

        global_gain = 5'b00000;
        summer_value = 20'h00100;
        #1;
        if (truncated_value != 12'd2049) begin
            $display("Sanity Check: The value should be 2049.");
            $finish();
        end

        global_gain = 5'b00001;
        summer_value = 20'hf0000;
        #1;
        if (truncated_value != 12'd1920) begin
            $display("Sanity Check: The value should be 1920.");
            $finish();
        end

        $display("All Test Passed.");
        `ifndef IVERILOG
            $vcdplusoff;
        `endif
        $finish();

    end

endmodule
