`timescale 1ns/10ps

module bios_testbench();
    parameter CPU_CLOCK_PERIOD = 20;
    parameter CPU_CLOCK_FREQ = 50_000_000;
    parameter BAUD_RATE = 12_500_000;
    // parameter BAUD_RATE = 115_200;
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
        $readmemh("../../software/bios151v3/bios151v3.hex", CPU.bios_mem.mem);

        `ifndef IVERILOG
            $vcdpluson;
            $vcdplusmemon();
        `endif
        `ifdef IVERILOG
            $dumpfile("bios_testbench.fst");
            $dumpvars(0,bios_testbench);
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
                while (!data_out_valid) @(posedge clk);
                $display("Got %h/%c", data_out, data_out);

                // Clear the off-chip UART's receiver for another UART packet
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                while (!data_out_valid) @(posedge clk);
                $display("Got %h/%c", data_out, data_out);

                // Clear the off-chip UART's receiver for another UART packet
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                while (!data_out_valid) @(posedge clk);
                $display("Got %h/%c", data_out, data_out);

                // Clear the off-chip UART's receiver for another UART packet
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                while (!data_out_valid) @(posedge clk);
                $display("Got %h/%c", data_out, data_out);

                // Clear the off-chip UART's receiver for another UART packet
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                while (!data_out_valid) @(posedge clk);
                $display("Got %h/%c", data_out, data_out);

                // Clear the off-chip UART's receiver for another UART packet
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                while (!data_out_valid) @(posedge clk);
                $display("Got %h/%c", data_out, data_out);

                // Clear the off-chip UART's receiver for another UART packet
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                while (!data_out_valid) @(posedge clk);
                $display("Got %h/%c", data_out, data_out);

                // Clear the off-chip UART's receiver for another UART packet
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                // ====================================================================

                // Wait until off-chip UART's transmit is ready
                data_in = 8'h41;
                while (!data_in_ready) @(posedge clk); #1;

                // Send a UART packet to the CPU from the off-chip UART
                data_in_valid = 1'b1;
                @(posedge clk); #1;
                data_in_valid = 1'b0;
                $display("off-chip UART about to transmit: %h to the on-chip UART", data_in, data_in, data_in);
                while (CPU.on_chip_uart.data_out !== data_in) @(posedge clk);
                $display("data_out, %h, recieved", CPU.on_chip_uart.data_out , CPU.on_chip_uart.data_out);

                // Check the value we recieve back is correct
                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%d, expected %h/%d", data_out, data_out, data_in, data_in);
                if (data_in != data_out) begin 
                    $display("Incorrect value");
                    $finish();
                end
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                // =========================================================================================================
                // Wait until off-chip UART's transmit is ready
                data_in = 8'h42;
                while (!data_in_ready) @(posedge clk); #1;

                // Send a UART packet to the CPU from the off-chip UART
                data_in_valid = 1'b1;
                @(posedge clk); #1;
                data_in_valid = 1'b0;
                $display("off-chip UART about to transmit: %h to the on-chip UART", data_in, data_in, data_in);
                while (!CPU.data_out_valid != 1) @(posedge clk);
                $display("Data Out Valid Set High");
                while (CPU.on_chip_uart.data_out !== data_in) @(posedge clk);
                $display("data_out, %h, recieved", CPU.on_chip_uart.data_out , CPU.on_chip_uart.data_out);

                // Check the value we recieve back is correct
                while (!data_out_valid) @(posedge clk); #2;
                $display("Got %h/%d, expected %h/%d", data_out, data_out, data_in, data_in);
                if (data_in != data_out) begin 
                    $display("Incorrect value");
                    $finish();
                end
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                // =========================================================================================================
                // Wait until off-chip UART's transmit is ready
                data_in = 8'h43;
                while (!data_in_ready) @(posedge clk); #1;

                // Send a UART packet to the CPU from the off-chip UART
                data_in_valid = 1'b1;
                @(posedge clk); #1;
                data_in_valid = 1'b0;
                $display("off-chip UART about to transmit: %h to the on-chip UART", data_in, data_in, data_in);
                while (!CPU.data_out_valid != 1) @(posedge clk);
                $display("Data Out Valid Set High");
                while (CPU.on_chip_uart.data_out !== data_in) @(posedge clk);
                $display("data_out, %h, recieved", CPU.on_chip_uart.data_out , CPU.on_chip_uart.data_out);

                // Check the value we recieve back is correct
                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%d, expected %h/%d", data_out, data_out, data_in, data_in);
                if (data_in != data_out) begin 
                    $display("Incorrect value");
                    $finish();
                end
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                // =========================================================================================================
                // Wait until off-chip UART's transmit is ready
                data_in = 8'h44;
                while (!data_in_ready) @(posedge clk); #1;

                // Send a UART packet to the CPU from the off-chip UART
                data_in_valid = 1'b1;
                @(posedge clk); #1;
                data_in_valid = 1'b0;
                $display("off-chip UART about to transmit: %h to the on-chip UART", data_in, data_in, data_in);
                while (!CPU.data_out_valid != 1) @(posedge clk);
                $display("Data Out Valid Set High");
                while (CPU.on_chip_uart.data_out !== data_in) @(posedge clk);
                $display("data_out, %h, recieved", CPU.on_chip_uart.data_out , CPU.on_chip_uart.data_out);

                // Check the value we recieve back is correct
                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%d, expected %h/%d", data_out, data_out, data_in, data_in);
                if (data_in != data_out) begin 
                    $display("Incorrect value");
                    $finish();
                end
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                // =========================================================================================================
                // Wait until off-chip UART's transmit is ready
                data_in = 8'h0D;
                while (!data_in_ready) @(posedge clk); #1;

                // Send a UART packet to the CPU from the off-chip UART
                data_in_valid = 1'b1;
                @(posedge clk); #1;
                data_in_valid = 1'b0;
                $display("off-chip UART about to transmit: %h to the on-chip UART", data_in, data_in, data_in);
                while (!CPU.data_out_valid != 1) @(posedge clk);
                $display("Data Out Valid Set High");
                while (CPU.on_chip_uart.data_out !== data_in) @(posedge clk);
                $display("data_out, %h, recieved", CPU.on_chip_uart.data_out , CPU.on_chip_uart.data_out);

                // Check the value we recieve back is correct
                while (!data_out_valid) @(posedge clk);
                $display("Got %h/%d, expected %h/%d", data_out, data_out, data_in, data_in);
                if (data_in != data_out) begin 
                    $display("Incorrect value");
                    // $finish();
                end
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                // Read extra /n , expected == 0x0a
                // Clear the off-chip UART's receiver for another UART packet
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;
                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%d", data_out, data_out, data_out, data_out);

                $display("Check read token echo back");
                // 1
                // =========================================================================================================


                // Clear the off-chip UART's receiver for another UART packet
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                // Wait for the off-chip UART to receive the 2nd transmitted data
                // y = x + 500
                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%d", data_out, data_out, data_out, data_out);

                // 2
                // =========================================================================================================

                // Clear the off-chip UART's receiver for another UART packet
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                // Wait for the off-chip UART to receive the 3rd transmitted data
                // y = x + 500
                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%d", data_out, data_out, data_out, data_out);

                // 3
                // =========================================================================================================

                // Clear the off-chip UART's receiver for another UART packet
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                // Wait for the off-chip UART to receive the 2nd transmitted data
                // y = x + 500
                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%d", data_out, data_out, data_out, data_out);

                // 4
                // =========================================================================================================


                // Clear the off-chip UART's receiver for another UART packet
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;            
                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%d", data_out, data_out, data_out, data_out);

                // $finish();
                // 5
                // =========================================================================================================
                // Check hello world messege
                $display("Check hello world message"); 


                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%d/%c", data_out, data_out, data_out, data_out);
                // H



                // 6
                // =========================================================================================================

                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%d/%c", data_out, data_out, data_out, data_out);
                // E

                // 7
                // =========================================================================================================


                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                while (!data_out_valid) @(posedge clk);  
                $display("Got %h/%d/%c", data_out, data_out, data_out, data_out);
                // L


                // 8
                // =========================================================================================================

                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;


                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%d/%c", data_out, data_out, data_out, data_out);
                // L


                // 8
                // =========================================================================================================


                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%d/%c", data_out, data_out, data_out, data_out);
                // O


                // 8
                // =========================================================================================================

                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%d/%c", data_out, data_out, data_out, data_out);
                // ' '


                // 8
                // =========================================================================================================

                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                while (!data_out_valid) @(posedge clk); 

                $display("Got %h/%d/%c", data_out, data_out, data_out, data_out);
                // W


                // 8
                // =========================================================================================================


                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;


                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%d/%c", data_out, data_out, data_out, data_out);
                // O


                // 8
                // =========================================================================================================

                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%d/%c", data_out, data_out, data_out, data_out);
                // R


                // 8
                // =========================================================================================================

                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%d/%c", data_out, data_out, data_out, data_out);
                // L


                // 8
                // =========================================================================================================

                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%d/%c", data_out, data_out, data_out, data_out);
                // D


                // 8
                // =========================================================================================================
 
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%d/%c", data_out, data_out, data_out, data_out);
                // !


                // 8
                // =========================================================================================================

                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%d/%c", data_out, data_out, data_out, data_out);
                // !


                // 8
                // =========================================================================================================

                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                // Wait for the off-chip UART to receive the 2nd transmitted data
                // y = x + 500
                while (!data_out_valid) @(posedge clk); 
                $display("Got %h/%d/%c", data_out, data_out, data_out, data_out);

                // Clear the off-chip UART's receiver for another UART packet
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;

                // // Wait for the off-chip UART to receive the 2nd transmitted data
                // // y = x + 500
                // while (!data_out_valid) @(posedge clk); 
                // $display("Got %h/%d/%c", data_out, data_out, data_out, data_out);

                // // Clear the off-chip UART's receiver for another UART packet
                // data_out_ready = 1'b1;
                // @(posedge clk); #1;
                // data_out_ready = 1'b0;

                // // Wait for the off-chip UART to receive the 2nd transmitted data
                // // y = x + 500
                // while (!data_out_valid) @(posedge clk); 
                // $display("Got %h/%d/%c", data_out, data_out, data_out, data_out);

                // // Clear the off-chip UART's receiver for another UART packet
                // data_out_ready = 1'b1;
                // @(posedge clk); #1;
                // data_out_ready = 1'b0;

                // // Wait for the off-chip UART to receive the 2nd transmitted data
                // // y = x + 500
                // while (!data_out_valid) @(posedge clk); 
                // $display("Got %h/%d/%c", data_out, data_out, data_out, data_out);

                // // Clear the off-chip UART's receiver for another UART packet
                // data_out_ready = 1'b1;
                // @(posedge clk); #1;
                // data_out_ready = 1'b0;



                // // Wait for the off-chip UART to receive the 2nd transmitted data
                // // y = x + 500
                // while (!data_out_valid) @(posedge clk); 
                // $display("Got %h/%d", data_out, data_out, data_out, data_out);

                // // Clear the off-chip UART's receiver for another UART packet
                // data_out_ready = 1'b1;
                // @(posedge clk); #1;
                // data_out_ready = 1'b0;




                // // Wait for the off-chip UART to receive the 2nd transmitted data
                // // y = x + 500
                // while (!data_out_valid) @(posedge clk); 
                // $display("Got %h/%d", data_out, data_out, data_out, data_out);

                // // Clear the off-chip UART's receiver for another UART packet
                // data_out_ready = 1'b1;
                // @(posedge clk); #1;
                // data_out_ready = 1'b0;


                // // Wait for the off-chip UART to receive the 2nd transmitted data
                // // y = x + 500
                // while (!data_out_valid) @(posedge clk); 
                // $display("Got %h/%d", data_out, data_out, data_out, data_out);

                // // Clear the off-chip UART's receiver for another UART packet
                // data_out_ready = 1'b1;
                // @(posedge clk);
                // data_out_ready = 1'b1;
                // @(posedge clk); #1;
                // data_out_ready = 1'b0;

                // // Wait for the off-chip UART to receive the 2nd transmitted data
                // // y = x + 500
                // while (!data_out_valid) @(posedge clk); 
                // $display("Got %h/%d", data_out, data_out, data_out, data_out);

                // // Clear the off-chip UART's receiver for another UART packet
                // data_out_ready = 1'b1;
                // @(posedge clk); #1;
                // data_out_ready = 1'b0;

                // // Wait for the off-chip UART to receive the 2nd transmitted data
                // // y = x + 500
                // // Clear the off-chip UART's receiver for another UART packet
                // while (!data_out_valid) @(posedge clk); 
                // $display("Got %h/%d", data_out, data_out, data_out, data_out);

                // // Clear the off-chip UART's receiver for another UART packet
                // data_out_ready = 1'b1;
                // @(posedge clk); #1;
                // data_out_ready = 1'b0;

                // // Wait for the off-chip UART to receive the 2nd transmitted data
                // // y = x + 500
                // while (!data_out_valid) @(posedge clk); 
                // $display("Got %h/%d", data_out, data_out, data_out, data_out);

                // // Clear the off-chip UART's receiver for another UART packet
                // data_out_ready = 1'b1;
                // @(posedge clk); #1;
                // data_out_ready = 1'b0;

                // // Wait for the off-chip UART to receive the 2nd transmitted data
                // // y = x + 500
                // while (!data_out_valid) @(posedge clk); 
                // $display("Got %h/%d", data_out, data_out, data_out, data_out);

                // // Clear the off-chip UART's receiver for another UART packet
                // data_out_ready = 1'b1;
                // @(posedge clk); #1;
                // data_out_ready = 1'b0;



                // // Wait for the off-chip UART to receive the 2nd transmitted data
                // // y = x + 500
                // while (!data_out_valid) @(posedge clk); 
                // $display("Got %h/%d", data_out, data_out, data_out, data_out);

                // // Clear the off-chip UART's receiver for another UART packet
                // data_out_ready = 1'b1;
                // @(posedge clk); #1;
                // data_out_ready = 1'b0;




                // // Wait for the off-chip UART to receive the 2nd transmitted data
                // // y = x + 500
                // while (!data_out_valid) @(posedge clk); 
                // $display("Got %h/%d", data_out, data_out, data_out, data_out);

                // // Clear the off-chip UART's receiver for another UART packet
                // data_out_ready = 1'b1;
                // @(posedge clk); #1;
                // Clear the off-chip UART's receiver for another UART packet
                // data_out_ready = 1'b0;


                // // Wait for the off-chip UART to receive the 2nd transmitted data
                // // y = x + 500
                // while (!data_out_valid) @(posedge clk); 
                // $display("Got %h/%d", data_out, data_out, data_out, data_out);

                // // Clear the off-chip UART's receiver for another UART packet
                // data_out_ready = 1'b1;
                // @(posedge clk); #1;
                // data_out_ready = 1'b0;


                // Clear the off-chip UART's receiver for another UART packet
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
