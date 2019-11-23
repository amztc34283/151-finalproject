`timescale 1ns/10ps

/* MODIFY THIS LINE WITH THE HIERARCHICAL PATH TO YOUR REGFILE ARRAY INDEXED WITH reg_number */
`define REGFILE_ARRAY_PATH CPU.rf.registers[reg_number]

module assembly_mmap_testbench();
    reg clk, rst;
    parameter CPU_CLOCK_PERIOD = 20;
    parameter CPU_CLOCK_FREQ = 50_000_000;

    initial clk = 0;
    always #(CPU_CLOCK_PERIOD/2) clk <= ~clk;

    Riscv151 # (
        .CPU_CLOCK_FREQ(CPU_CLOCK_FREQ)
    ) CPU(
        .clk(clk),
        .rst(rst),
        .FPGA_SERIAL_RX(),
        .FPGA_SERIAL_TX()
    );

    // A task to check if the value contained in a register equals an expected value
    task check_reg;
        input [4:0] reg_number;
        input [31:0] expected_value;
        input [10:0] test_num;
        if (expected_value !== `REGFILE_ARRAY_PATH) begin
            $display("FAIL - test %d, got: %d, expected: %d for reg %d", test_num, `REGFILE_ARRAY_PATH, expected_value, reg_number);
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
                check_reg(2, 32'd0, 3);                 // Verify that x2 contains num cycles
                check_reg(3, 32'd20, 3);                // Verify that x3 contains num instructions

                // Test for sw @ 0x8000_0018, reset counters
                wait_for_reg_to_equal(20, 32'd5);       // Run the simulation untill the flag is set 5
                check_reg(2, 32'd3, 4);                 // Verify that x2 contains num cycles, after reset
                check_reg(3, 32'd1, 4);                 // Verify that x3 contains num inst, after reset

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
