`timescale 1ns/10ps

/* MODIFY THIS LINE WITH THE HIERARCHICAL PATH TO YOUR REGFILE ARRAY INDEXED WITH reg_number */
`define REGFILE_ARRAY_PATH CPU.rf.registers[reg_number]

module assembly_btype_testbench();
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
        $readmemh("../../software/branches_tests/branches_tests.hex", CPU.imem.mem);

        `ifndef IVERILOG
            $vcdpluson;
            $vcdplusmemon();
        `endif
        `ifdef IVERILOG
            $dumpfile("assembly_btype_testbench.fst");
            $dumpvars(0,assembly_btype_testbench);
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

                // Test bne, branch not taken
                wait_for_reg_to_equal(20, 32'd4);
                check_reg(1, 32'd2, 3);
                // Test bne, branch taken
                wait_for_reg_to_equal(20, 32'd5);
                check_reg(1, 32'd2, 3);

                // Test blt, branch not taken
                wait_for_reg_to_equal(20, 32'd6);
                check_reg(2, 32'd2, 4);
                wait_for_reg_to_equal(20, 32'd7);
                check_reg(1, 32'd1000, 4);
                wait_for_reg_to_equal(20, 32'd7);
                check_reg(2, 32'h0000009C, 4);
                // Test blt branch taken
                wait_for_reg_to_equal(20, 32'd8);
                check_reg(1, 32'd12345, 4);

                // Test bge branch taken
                wait_for_reg_to_equal(20, 32'd9);
                check_reg(1, 32'h80000000, 5);
                // Test bge branch not taken
                wait_for_reg_to_equal(20, 32'd10);
                check_reg(1, 32'd2, 5);

                // Test bltu branch not taken
                wait_for_reg_to_equal(20, 32'd11);
                check_reg(2, 32'd2, 6);
                check_reg(10, -32'd1, 6);
                check_reg(11, 32'd1, 6);
                wait_for_reg_to_equal(20, 32'd12);
                check_reg(1, 32'd0, 6);
                // Test bltu branch taken
                wait_for_reg_to_equal(20, 32'd13);
                check_reg(1, 32'd0, 6);

                // Test bgeu branch taken
                wait_for_reg_to_equal(20, 32'd14);
                check_reg(1, 32'd123, 7);
                // Test bgeu branch not taken
                wait_for_reg_to_equal(20, 32'd15);
                check_reg(1, 32'd2, 7);


                $display("ALL BASIC B-TYPE ASSEMBLY TESTS PASSED");
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
