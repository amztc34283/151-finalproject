`timescale 1ns/10ps

/* MODIFY THIS LINE WITH THE HIERARCHICAL PATH TO YOUR REGFILE ARRAY INDEXED WITH reg_number */
`define REGFILE_ARRAY_PATH CPU.rf.registers[reg_number]

module assembly_mmap_testbench();
    reg clk, rst;
    parameter CPU_CLOCK_PERIOD = 20;
    parameter CPU_CLOCK_FREQ = 50_000_000;

    initial clk = 0;
    always #(CPU_CLOCK_PERIOD/2) clk <= ~clk;

    reg [2:0] clean_buttons;
    reg [1:0] switches;
    wire [5:0] leds;

    Riscv151 # (
        .CPU_CLOCK_FREQ(CPU_CLOCK_FREQ)
    ) CPU(
        .clk(clk),
        .rst(rst),
        .FPGA_SERIAL_RX(),
        .FPGA_SERIAL_TX(),
        .clean_buttons(clean_buttons),
        .switches(switches),
        .leds(leds)
    );

    // A task to check if the value contained in a register equals an expected value
    task check_reg;
        input [4:0] reg_number;
        input [31:0] expected_value;
        input [10:0] test_num;
        if (expected_value !== `REGFILE_ARRAY_PATH) begin
            $display("FAIL - test %d, got: %d/%h, expected: %d/%h for reg %d", test_num, `REGFILE_ARRAY_PATH, `REGFILE_ARRAY_PATH, expected_value, expected_value, reg_number);
            // $finish();
        end
        else begin
            $display("PASS - test %d, got: %d for reg %d", test_num, expected_value, reg_number);
        end
    endtask

    // A task that runs the simulation until a register contains some value
    task wait_for_reg_to_equal;
        input [4:0] reg_number;
        input [31:0] expected_value;
        while (`REGFILE_ARRAY_PATH !== expected_value) @(posedge clk);
    endtask

    reg done = 0;
    initial begin
        $readmemh("../../software/assembly_mmap/mmap.hex", CPU.bios_mem.mem);

        `ifndef IVERILOG
            $vcdpluson;
            $vcdplusmemon();
        `endif
        `ifdef IVERILOG
            $dumpfile("assembly_mmap_testbench.fst");
            $dumpvars(0,assembly_mmap_testbench);
        `endif

        rst = 0;

        // Reset the CPU
        rst = 1;
        repeat (1) @(posedge clk);             // Hold reset for 30 cycles
        #1;
        rst = 0;

        switches = 2'b00;
        clean_buttons = 3'b000;

        fork
            begin
                // Your processor should begin executing the code in /software/assembly_tests/start.s

                // Test beq, branch taken
                wait_for_reg_to_equal(20, 32'd2);       // Run the simulation until the flag is set to 1
                check_reg(1, 32'd500, 1);               // Verify that x1 contains 500
                check_reg(2, 32'd100, 1);               // Verify that x2 contains 100

                // Test beq, branch not taken
                wait_for_reg_to_equal(20, 32'd3);       // Run the simulation until the flag is set to 3
                check_reg(2, 32'd111, 2);               // Verify that x2 contains 111
                check_reg(1, 32'd300, 2);               // Verify that x1 contains 300

                // Test for lw @ 0x8000_0010 and lw @ 0x8000_0014, read cycle and instruction counter
                wait_for_reg_to_equal(20, 32'd4);       // Run the simulation untill the flag is set to 4
                check_reg(2, 32'd23, 3);                // Verify that x2 contains num cycles
                check_reg(3, 32'd21, 3);                // Verify that x3 contains num instructions

                // Test for sw @ 0x8000_0018, reset counters
                wait_for_reg_to_equal(20, 32'd5);       // Run the simulation untill the flag is set 5
                check_reg(2, 32'd0, 4);                 // Verify that x2 contains num cycles, after reset
                check_reg(3, 32'd1, 4);                 // Verify that x3 contains num inst, after reset

                // Test for lw @ 0x8000_0010 and lw @ 0x8000_0014, read cycle and instruction counter
                wait_for_reg_to_equal(20, 32'd6);       // Run the simulation untill the flag is set to 4
                check_reg(2, 32'd19, 5);                // Verify that x2 contains num cycles
                check_reg(3, 32'd11, 5);                // Verify that x3 contains num instructions

                // Test for User I/O - FIFO Empty
                wait_for_reg_to_equal(20, 32'd7);
                check_reg(1, 32'd1, 6);

                // Test for User I/O - Button is high; check FIFO empty
                clean_buttons = 3'b111;
                wait_for_reg_to_equal(20, 32'd8);
                check_reg(1, 32'd0, 7);

                // Test for User I/O - Read Buttons
                wait_for_reg_to_equal(20, 32'd9);
                check_reg(1, 32'h00000007, 8);

                // Test for User I/O - Read Switches
                wait_for_reg_to_equal(20, 32'd10);
                check_reg(1, 32'h00000000, 9);

                // Test for User I/O - Read high switches
                switches = 2'b11;
                wait_for_reg_to_equal(20, 32'd11);
                check_reg(1, 32'h00000003, 10);

                // Test for LEDS
                wait_for_reg_to_equal(20, 32'd12);
                if (leds != 6'b010001) begin
                    $display("Failed to write to LEDs.");
                end

                $display("ALL BASIC MEMORY MAP ASSEMBLY TESTS PASSED");
                done = 1;
            end
            begin
                repeat (1000) @(posedge clk);
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
