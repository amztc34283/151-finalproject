`timescale 1ns/100ps

//Running 33.333MHz
`define CLK_PERIOD_1 30
//Running 100MHz
`define CLK_PERIOD_2 10

module pwm_controller_tb();

    reg clk1 = 0;
    reg clk2 = 0;
    reg rst = 0;
    reg [11:0] duty_cycle = 0;
    reg req = 0;
    wire ack;
    wire [11:0] pwm_duty_cycle;

    always #(`CLK_PERIOD_1/2) clk1 <= ~clk1;
    always #(`CLK_PERIOD_2/2) clk2 <= ~clk2;

    pwm_controller DUT(
        .clk1(clk1),
        .clk2(clk2),
        .rst(rst),
        .duty_cycle(duty_cycle),
        .req(req),
        .ack(ack),
        .pwm_duty_cycle(pwm_duty_cycle));

    integer i;

    initial begin
        `ifndef IVERILOG
            $vcdpluson;
        `endif
        `ifdef IVERILOG
            $dumpfile("pwm_controller_tb.fst");
            $dumpvars(0,pwm_controller_tb);
        `endif

        rst = 1;
        repeat (1) @(posedge clk1); #1;

        //Setting up stuff for Test Two here
        rst = 0;
        req = 0;
        duty_cycle = 12'hfff;
        repeat (1) @(posedge clk1); #1;
        //Test One - pwm_duty_cycle should be 0 after reset
        if (pwm_duty_cycle != 0 || pwm_duty_cycle === 12'hxxx) begin
            $display("Failed Test One - RESET");
            $finish();
        end

        //Setting up stuff for Test Three here
        rst = 0;
        req = 1;
        duty_cycle = 12'hfff;
        repeat (1) @(posedge clk1); #1;
        //Test Two - pwm_duty_cycle should be 0 when req is 0
        if (pwm_duty_cycle != 0) begin
            $display("Failed Test Two - Req = 0");
            $finish();
        end

        //Only setting req high for one cycle of clk1
        rst = 0;
        req = 0;
        duty_cycle = 12'hfff;
        repeat (1) @(posedge clk1); #1;
        //Test Three - pwm_duty_cycle should be fff when req is 1
        if (pwm_duty_cycle != 12'hfff) begin
            $display("Failed Test Three - Req = 1");
            $finish();
        end
        repeat (1) @(posedge clk1); #1;
        if (ack != 1) begin
            $display("Failed Test Three - Ack = 1");
            $finish();
        end
        repeat (1) @(posedge clk1); #1;
        //This ensures the ack becomes zero when req is 0
        if (ack != 0) begin
            $display("Failed Test Three - Ack should be zero");
            $finish();
        end

        //Test Four - Four-way handshake workflow
        rst = 1;
        repeat (1) @(posedge clk1); #1;
        if (pwm_duty_cycle != 12'h000) begin
            $display("Workflow: Reset Failed.");
        end
        //Step One
        rst = 0;
        req = 1;
        duty_cycle = 12'hfff;
        repeat (1) @(posedge clk1); #1;
        //Step Two
        repeat (2) @(posedge clk2); #1;
        if (DUT.req_clk2_2_out != 1 || pwm_duty_cycle != 12'h000) begin
            $display("Workflow: Enable signal should be high");
        end
        //Step Three
        repeat (1) @(posedge clk2); #1;
        if (pwm_duty_cycle != 12'hfff || ack != 0) begin
            $display("Workflow: step three failed.");
        end
        //Step Four
        repeat (1) @(posedge clk1); #1;
        if (ack != 1) begin
            $display("Workflow: step four failed.");
        end
        //Step Five - Data transfer finish; deassert TX req
        req = 0;
        repeat (1) @(posedge clk1); #1;
        //Step Six - TX acknowledge deasserted
        repeat (1) @(posedge clk1); #1;
        if (ack != 1) begin
            $display("Workflow: step six failed.");
        end
        repeat (1) @(posedge clk1); #1;
        if (ack != 0 || pwm_duty_cycle != 12'hfff) begin
            $display("Workflow: step six failed.");
        end
        //Step Seven - TX is ready to transfer new data

        $display("All Test Passed.");
        `ifndef IVERILOG
            $vcdplusoff;
        `endif
        $finish();
    end

endmodule
