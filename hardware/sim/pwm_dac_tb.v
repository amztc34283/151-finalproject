`timescale 1ns/100ps

`define CLK_PERIOD 8

module pwm_dac_tb();

    reg clk = 0;
    reg [11:0] duty_cycle = 0;
    wire square_wave_out;

    //Running 125MHz
    always #(`CLK_PERIOD/2) clk <= ~clk;

    pwm_dac DUT(.clk(clk),
                 .duty_cycle(duty_cycle),
                 .square_wave_out(square_wave_out));

    integer i;

    initial begin
        duty_cycle = 0;
        repeat (1) @(posedge clk); #1;
        if (square_wave_out != 0) begin
            $display("Failed Sanity Test Case One");
            $finish();
        end

        duty_cycle = 1;
        repeat (1) @(posedge clk); #1;
        if (square_wave_out != 1) begin
            $display("Failed Sanity Test Case Two - 1");
            $finish();
        end
        i = 0;
        //4096-2 as the first cycle should be on for duty_cycle = 1
        //and there are only 2^12 - 1 cycles per pwm frequency
        while(i != 4094) begin
            repeat (1) @(posedge clk); #1;
            if (square_wave_out != 0) begin
                $display("Failed Sanity Test Case Two - 2");
                $finish();
            end
            i = i + 1;
        end
        repeat (1) @(posedge clk); #1;
        if (square_wave_out != 1) begin
            $display("Failed Sanity Test Case Two - 3");
            $finish();
        end

        i = 0;
        duty_cycle = 0;
        while (i != 10000) begin
            repeat (1) @(posedge clk); #1;
            if (square_wave_out != 0) begin
                $display("Failed Sanity Test Case Three");
                $finish();
            end
            i = i + 1;
        end

        duty_cycle = 10;
        i = 0;
        while(i != 10) begin
            repeat (1) @(posedge clk); #1;
            if (square_wave_out != 1) begin
                $display("Failed Sanity Test Case Four - 1");
                $finish();
            end
            i = i + 1;
        end
        i = 0;
        while(i != 4085) begin
            repeat (1) @(posedge clk); #1;
            if (square_wave_out != 0) begin
                $display("Failed Sanity Test Case Four - 2");
                $finish();
            end
            i = i + 1;
        end
        repeat (1) @(posedge clk); #1;
        if (square_wave_out != 1) begin
            $display("Failed Sanity Test Case Four - 3");
            $finish();
        end

        $display("All Test Passed.");
        $finish();
    end

endmodule
