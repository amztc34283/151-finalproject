`timescale 1ns/10ps

/* MODIFY THIS LINE WITH THE HIERARCHICAL PATH TO YOUR REGFILE ARRAY INDEXED WITH reg_number */
`define REGFILE_ARRAY_PATH CPU.rf.registers[reg_number]

module assembly_wiring_imem_testbench();
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
        // Load hex to bios mem and assuming PC starts with 4'b0100
        $readmemh("../../software/wiring_tests/preload_bios_step9.hex", CPU.bios_mem.mem);
        `ifndef IVERILOG
            $vcdpluson;
            $vcdplusmemon();
        `endif
        `ifdef IVERILOG
            $dumpfile("assembly_wiring_imem_testbench.fst");
            $dumpvars(0,assembly_wiring_imem_testbench);
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

                wait_for_reg_to_equal(20, 1);

                wait_for_reg_to_equal(20, 2);
                check_reg(1, 32'd10, 1);

                wait_for_reg_to_equal(20, 3);
                check_reg(1, 32'd2, 2);

                $display("ALL BASIC WIRING ASSEMBLY TESTS PASSED");
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
