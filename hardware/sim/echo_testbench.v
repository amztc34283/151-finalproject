`timescale 1ns/10ps

module echo_testbench();
    parameter CPU_CLOCK_PERIOD = 20;
    parameter CPU_CLOCK_FREQ = 50_000_000;
    parameter BAUD_RATE = 50_000_000;

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
        $readmemh("../../software/echo/echo.hex", CPU.bios_mem.mem);

        `ifndef IVERILOG
            $vcdpluson;
        `endif
        `ifdef IVERILOG
            $dumpfile("echo_testbench.fst");
            $dumpvars(0,echo_testbench);
        `endif

        // Reset all parts
        rst = 1'b0;
        data_in = 8'h7a;
        data_in_valid = 1'b0;
        data_out_ready = 1'b0;

        repeat (20) @(posedge clk); #1;

        rst = 1'b1;
        repeat (30) @(posedge clk); #1;
        rst = 1'b0;

        fork
            begin
                // Wait until off-chip UART's transmit is ready
                while (!data_in_ready) @(posedge clk); #1;
                // Initially data_in_ready (off chip UART transmitter should be high)
                // Since it is not transmitting, the serial_out is high

                // Send a UART packet to the CPU from the off-chip UART
                data_in_valid = 1'b1;
                @(posedge clk); #1;
                data_in_valid = 1'b0;
                $display("off-chip UART about to transmit: %h/%c to the on-chip UART", data_in, data_in);

                // Once the off chip UART transmitter observers data_in_valid high,
                // data_in_ready and data_in_valid are both high,
                // The transmit initiates transfer,
                // setting data_in_ready = 0 and serial_out = 0
                // sending 1 bit every SYMBOL_EDGE_TIME cycles, for a 8 bit word
                // After the 8 bits are sent the transfer closes, 
                // serial_out = data_in_ready = 1

                // Initially the on chip UART reciever is not recieving anything,
                // So serial_in is high and rx_running is low
                // When the off chip UART initiates transfer, 
                // serial_in goes low and rx_running is low, so reciving iniates
                // Over the next 8 SYMBOL_EDGE_TIME number of cycles 
                // the rx_shift register is filled
                // Once the rx_shift register is filled, the reciever sends out
                // the data_out_valid signal

                // When the on chip device observes data_out_valid, it reads the value
                // out of the on chip reciever's data_out and tells the reciever
                // it can begin to recieve a new value by setting data_out_ready high

                // Watch data_in (7A) be sent over FPGA_SERIAL_RX to the CPU's on-chip UART

                // The echo program running on the CPU is polling the memory mapped register (0x80000000)
                // and waiting for data_out_valid of the on-chip UART to become 1. Once it does, the echo program
                // performs a load from memory mapped register (0x80000004) to fetch the data that the on-chip UART
                // received from the off-chip UART. Then, the same data is stored to memory mapped register (0x80000008),
                // which should command the on-chip UART's transmitter to send the same data back to the off-chip UART.

                // Wait for the off-chip UART to receive the echoed data
                while (!data_out_valid) @(posedge clk); #1;
                $display("Got %h", data_out);

                // Clear the off-chip UART's receiver for another UART packet
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;
                done = 1;
            end
            begin
                repeat (50000) @(posedge clk);
                if (!done) begin
                    $display("Failed: timing out");
                    $finish();
                end
            end
        join

        `ifndef IVERILOG
            $vcdplusoff;
        `endif
        $finish();
    end
endmodule
