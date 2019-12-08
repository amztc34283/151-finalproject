`timescale 1ns/10ps

module piano_integration_testbench ();
    parameter SYSTEM_CLK_PERIOD = 8;
    parameter SYSTEM_CLK_FREQ = 125_000_000;
    parameter RESET_PC = 32'h1000_0000;
    parameter BAUD_RATE = 115_200;

    reg sys_clk = 0;
    reg sys_rst = 0;
    always #(SYSTEM_CLK_PERIOD/2) sys_clk <= ~sys_clk;

    // UART Signals between the on-chip and off-chip UART
    wire FPGA_SERIAL_RX, FPGA_SERIAL_TX;

    // Off-chip UART Ready/Valid interface
    reg   [7:0] data_in;
    reg         data_in_valid;
    wire        data_in_ready;
    wire  [7:0] data_out;
    wire        data_out_valid;
    reg         data_out_ready;

    z1top #(
        .SYSTEM_CLOCK_FREQ(SYSTEM_CLK_FREQ),
        .B_SAMPLE_COUNT_MAX(5),
        .B_PULSE_COUNT_MAX(5),
        .RESET_PC(RESET_PC),
        .BAUD_RATE(BAUD_RATE)
    ) top (
        .CLK_125MHZ_FPGA(sys_clk),
        .BUTTONS({3'b0, sys_rst}),
        .SWITCHES(2'b0),
        .LEDS(),
        .FPGA_SERIAL_RX(FPGA_SERIAL_RX),
        .FPGA_SERIAL_TX(FPGA_SERIAL_TX)
    );

    // Instantiate the off-chip UART
    uart # (
        .CLOCK_FREQ(SYSTEM_CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) off_chip_uart (
        .clk(sys_clk),
        .reset(sys_rst),
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
    reg [31:0] cycle = 0;
    reg [7:0] volume = 0;
    reg [31:0] delta = 0;
    initial begin
        $readmemh("../../software/square_piano/square_piano.hex", top.cpu.dmem.mem, 0, 16384-1);
        $readmemh("../../software/square_piano/square_piano.hex", top.cpu.imem.mem, 0, 16384-1);

        `ifndef IVERILOG
            $vcdpluson;
        `endif
        `ifdef IVERILOG
            $dumpfile("piano_integration_testbench.fst");
            $dumpvars(0,piano_integration_testbench);
        `endif

        // Reset all parts
        sys_rst = 1'b1;
        repeat (50) @(posedge sys_clk); #1;
        sys_rst = 1'b0;

        data_in = 8'h59;
        data_in_valid = 1'b0;
        data_out_ready = 1'b0;


        fork
            begin

                // First read the value off switches to observe the volume
                while (top.cpu.ALU_out != 32'h80000028) @(posedge sys_clk);
                $display("Volume := switches & 0x3: %d", top.cpu.mmap_mem.switches);
                volume = top.cpu.mmap_mem.switches;

                // Check that the FIFO is empty
                while (top.cpu.ALU_out != 32'h80000020) @(posedge sys_clk);
                if (top.cpu.mmap_mem.empty != 1'b1) 
                    $display("WRONG: the FIFO should be empty");
                else
                    $display("CORRECT: the FIFO is empty, as expected");

                // Wait until off-chip UART's transmit is ready
                while (!data_in_ready) @(posedge sys_clk); #1;

                // Send a UART packet to the CPU from the off-chip UART
                data_in_valid = 1'b1;
                @(posedge sys_clk); #1;
                data_in_valid = 1'b0;

                // Watch data_in (62/b) be sent over FPGA_SERIAL_RX to the CPU's on-chip UART
                while (top.cpu.mmap_mem.on_chip_uart.data_out !== data_in) @(posedge sys_clk);
                $display("data_out, %h/%c, recieved", top.cpu.mmap_mem.on_chip_uart.data_out , top.cpu.mmap_mem.on_chip_uart.data_out);

                while (top.cpu.mmap_mem.data_out_valid != 1'b1) @(posedge sys_clk);
                $display("data_out_valid is high");

                // Watch the software program execute a lw @ 8000_0000, to check data_out_valid
                while (top.cpu.ALU_out != 32'h8000_0000) @(posedge sys_clk);
                $display("UART CTRL executed by software");

                while (top.cpu.ALU_out != 32'h8000_0004) @(posedge sys_clk);
                $display("UART receive executed by software");

                while (top.cpu.mmap_mem.MMap_dout != data_in) begin @(posedge sys_clk);
                $display("data_out of mmap_mem is %h/%c, cycles:", data_in, data_in, delta);

                // ==========   send_to_pwm(0) START  =========================
                // Wait for the first instance of PWM_DUTY_CYCLE, step 1a
                while (top.cpu.ALU_out != 32'h80000034) @(posedge sys_clk);
                if (top.cpu.mmap_mem.data[11:0] != 12'd0)
                    $display("WRONG: Expected = 0 & 0xfff == 0; actual = %d", top.cpu.mmap_mem.data[11:0]);
                else
                    $display("CORRECT: duty_cycle set to 0 recieved");
                
                // Wait for TX req to be recieved by the CPU, step 1a
                while (top.cpu.ALU_out != 32'h80000038) @(posedge sys_clk);
                $display("Checked software send TX req is recieved @ mmap_mem");
                if (top.cpu.mmap_mem.data[0] != 1'b1)
                    $display("WRONG: Expected TX req set high");
                else
                    $display("CORRECT: TX req set high");

                // Check that the TX ack bit is not set high here
                if (top.cpu.mmap_mem.tx_ack != 1'b0)
                    $display("WRONG: Expected TX ack set low, but is high");
                else
                    $display("CORRECT: TX ack set low");

                // Wait untill TX act is set high
                while (top.cpu.mmap_mem.tx_ack != 1'b1) @(posedge sys_clk);
                $display("Checked tx_ack is set high by PWM controller");

                // Wait untill TX req is set low
                while (top.cpu.mmap_mem.tx_req != 1'b0) @(posedge sys_clk);
                $display("TX req is now de-asserted");

                // Check that the TX ack bit is de-asserted
                // This completes send_to_pwm(0)
                while (top.cpu.mmap_mem.tx_ack != 1'b0) @(posedge sys_clk);
                $display("Checked tx_ack is desasserted");

                // // We now expect COUNTER_RST
                while (top.cpu.ALU_out != 32'h8000_0018) @(posedge sys_clk);
                $display("Cycle Counter Reset");

            end
            begin
                for (cycle = 0; cycle < 1_000_000; cycle = cycle + 1) begin
                    if (done) $finish();
                    @(posedge sys_clk);
                end
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
