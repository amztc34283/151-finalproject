`timescale 1ns/10ps

module c_example_testbench();
    parameter CPU_CLOCK_PERIOD = 20;
    parameter CPU_CLOCK_FREQ = 50_000_000;
    parameter BAUD_RATE = 12_500_000;
    parameter RESET_PC = 32'h4000_0000;

    reg clk, rst;
    wire FPGA_SERIAL_RX, FPGA_SERIAL_TX;

    reg   [7:0] data_in;
    reg         data_in_valid;
    wire        data_in_ready;
    wire  [7:0] data_out;
    wire        data_out_valid;
    reg         data_out_ready;

    initial clk = 0;
    always #(CPU_CLOCK_PERIOD/2) clk <= ~clk;

    // Instantiate your Riscv CPU here and connect the FPGA_SERIAL_TX wires
    // to the off-chip UART we use for testing. The CPU has a UART (on-chip UART) inside it.
    Riscv151 # (
        .CPU_CLOCK_FREQ(CPU_CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
        // .RESET_PC(RESET_PC)
    ) CPU (
        .clk(clk),
        .rst(rst),
        .FPGA_SERIAL_RX(FPGA_SERIAL_RX),
        .FPGA_SERIAL_TX(FPGA_SERIAL_TX)
    );

    // Instantiate the off-chip UART
    uart # (
        .CLOCK_FREQ(CPU_CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) off_chip_uart (
        .clk(clk),
        .reset(rst),
        .data_in(data_in),
        .data_in_valid(data_in_valid),
        .data_in_ready(data_in_ready),
        .data_out(data_out),
        .data_out_valid(data_out_valid),
        .data_out_ready(data_out_ready),
        .serial_in(FPGA_SERIAL_TX),
        .serial_out(FPGA_SERIAL_RX)
    );

    reg done = 0;
    initial begin
        $readmemh("../../software/c_example/c_example.hex", CPU.bios_mem.mem);
        $readmemh("../../software/c_example/c_example.hex", CPU.dmem.mem);

        `ifndef IVERILOG
            $vcdpluson;
            $vcdplusmemon();
        `endif
        `ifdef IVERILOG
            $dumpfile("c_example_testbench.fst");
            $dumpvars(0,c_example_testbench);
        `endif

        // Reset all parts
        rst = 1'b0;
        data_in_valid = 1'b0;
        data_out_ready = 1'b0;

        repeat (20) @(posedge clk); #1;

        rst = 1'b1;
        repeat (30) @(posedge clk); #1;
        rst = 1'b0;

        fork
            begin
                // Wait for the off-chip UART to receive the first transmitted data
                // x = 100
                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%b/%d/%c", data_out, data_out, data_out, data_out);

                // Clear the off-chip UART's receiver for another UART packet
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                // Wait for the off-chip UART to receive the 2nd transmitted data
                // y = x + 500
                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%b/%d/%c", data_out, data_out, data_out, data_out);

                // Clear the off-chip UART's receiver for another UART packet
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                // Wait for the off-chip UART to receive the 3rd transmitted data
                // y = x + 500
                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%b/%d/%c", data_out, data_out, data_out, data_out);

                // Clear the off-chip UART's receiver for another UART packet
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                // Wait for the off-chip UART to receive the 2nd transmitted data
                // y = x + 500
                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%b/%d/%c", data_out, data_out, data_out, data_out);

                // Clear the off-chip UART's receiver for another UART packet
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                // Wait for the off-chip UART to receive the 2nd transmitted data
                // y = x + 500
                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%b/%d/%c", data_out, data_out, data_out, data_out);

                // Clear the off-chip UART's receiver for another UART packet
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                // Wait for the off-chip UART to receive the 2nd transmitted data
                // y = x + 500
                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%b/%d/%c", data_out, data_out, data_out, data_out);

                // Clear the off-chip UART's receiver for another UART packet
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;



                // Wait for the off-chip UART to receive the 2nd transmitted data
                // y = x + 500
                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%b/%d/%c", data_out, data_out, data_out, data_out);

                // Clear the off-chip UART's receiver for another UART packet
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;


                // Wait for the off-chip UART to receive the 2nd transmitted data
                // y = x + 500
                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%b/%d/%c", data_out, data_out, data_out, data_out);

                // Clear the off-chip UART's receiver for another UART packet
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;


                // Wait for the off-chip UART to receive the 2nd transmitted data
                // y = x + 500
                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%b/%d/%c", data_out, data_out, data_out, data_out);

                // Clear the off-chip UART's receiver for another UART packet
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                // Wait for the off-chip UART to receive the 2nd transmitted data
                // y = x + 500
                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%b/%d/%c", data_out, data_out, data_out, data_out);

                // Clear the off-chip UART's receiver for another UART packet
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                // Wait for the off-chip UART to receive the 2nd transmitted data
                // y = x + 500
                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%b/%d/%c", data_out, data_out, data_out, data_out);

                // Clear the off-chip UART's receiver for another UART packet
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                // Wait for the off-chip UART to receive the 2nd transmitted data
                // y = x + 500
                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%b/%d/%c", data_out, data_out, data_out, data_out);

                // Clear the off-chip UART's receiver for another UART packet
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                // Wait for the off-chip UART to receive the 2nd transmitted data
                // y = x + 500
                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%b/%d/%c", data_out, data_out, data_out, data_out);

                // Clear the off-chip UART's receiver for another UART packet
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;



                // Wait for the off-chip UART to receive the 2nd transmitted data
                // y = x + 500
                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%b/%d/%c", data_out, data_out, data_out, data_out);

                // Clear the off-chip UART's receiver for another UART packet
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;




                // Wait for the off-chip UART to receive the 2nd transmitted data
                // y = x + 500
                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%b/%d/%c", data_out, data_out, data_out, data_out);

                // Clear the off-chip UART's receiver for another UART packet
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;


                // Wait for the off-chip UART to receive the 2nd transmitted data
                // y = x + 500
                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%b/%d/%c", data_out, data_out, data_out, data_out);

                // Clear the off-chip UART's receiver for another UART packet
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;


                done = 1;
            end
            begin
                repeat (150000) @(posedge clk);
                if (!done) begin
                    $display("Failed: timing out");
                    $finish();
                end
            end
        join

        `ifndef IVERILOG
            $vcdplusoff;
            $vcdplusmemoff();
        `endif
        $finish();
    end
endmodule
