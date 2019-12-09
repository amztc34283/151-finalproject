`timescale 1ns/1ns

`define CLK_PERIOD 8

module buffer_tb ();

    // 125 MHz
    reg clk = 0;
    always #(`CLK_PERIOD/2) clk = ~clk;

    reg valid = 0;
    reg rst = 0;
    reg [11:0] from_truncator = 0;
    reg tx_ack = 0;
    wire tx_req;
    wire [11:0] to_cdc;
    wire ready;

    buffer DUT (
        .clk(clk),
        .valid(valid),
        .rst(rst),
        .from_truncator(from_truncator),
        .tx_ack(tx_ack),
        .tx_req(tx_req),
        .to_cdc(to_cdc),
        .ready(ready)
    );

    integer i;

    initial begin
        `ifndef IVERILOG
            $vcdpluson;
        `endif
        `ifdef IVERILOG
            $dumpfile("buffer_tb.fst");
            $dumpvars(0,buffer_tb);
        `endif

        rst = 1;
        repeat (10) @(posedge clk); #1;

        // Test - new duty cycle comes in; ready is high
        rst = 0;
        valid = 1;
        from_truncator = 12'hABC;
        tx_ack = 0;
        repeat (1) @(posedge clk); #1;
        if (ready || !tx_req || to_cdc != 12'hABC) begin
            $display("Test 1 Failed.");
            $finish();
        end

        i = 0;
        while (i != 50_000_000/30_000) begin
            repeat (1) @(posedge clk); #1;
            if (ready) begin
                $display("Test 1 Failed, %d, with sample clock %d.", i, DUT.sample_counter);
                $finish();
            end
            i = i + 1;
        end

        repeat (1) @(posedge clk); #1;
        if (!ready) begin
            $display("Test 1 Failed, ready should be high.");
        end

        // Test - new duty cycle comes in with ack activated.
        rst = 0;
        valid = 1;
        from_truncator = 12'hABC;
        tx_ack = 0;
        repeat (1) @(posedge clk); #1;
        if (ready || !tx_req || to_cdc != 12'hABC) begin
            $display("Test 2 Failed.");
            $finish();
        end

        tx_ack = 1;
        repeat (1) @(posedge clk); #1;
        if (tx_req) begin
            $display("Test 2 Failed.");
            $finish();
        end

        $display("All Test Passed.");
        `ifndef IVERILOG
            $vcdplusoff;
        `endif
        $finish();
    end
endmodule //
