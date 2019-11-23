`timescale 1ns/10ps

/* MODIFY THIS LINE WITH THE HIERARCHICAL PATH TO YOUR REGFILE ARRAY INDEXED WITH reg_number */
`define REGFILE_ARRAY_PATH CPU.rf.registers[reg_number]

module assembly_itype_testbench();
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
        $readmemh("../../software/assembly_itype/itype.hex", CPU.bios_mem.mem);

        `ifndef IVERILOG
            $vcdpluson;
        `endif
        `ifdef IVERILOG
            $dumpfile("assembly_itype_testbench.fst");
            $dumpvars(0,assembly_itype_testbench);
        `endif

        rst = 0;

        // Reset the CPU
        rst = 1;
        repeat (30) @(posedge clk);             // Hold reset for 30 cycles
        #1;
        rst = 0;

        fork
            begin
                // Your processor should begin executing the code in /software/assembly_tests/start.s

                // Test ADDI
                wait_for_reg_to_equal(20, 32'd1);       // Run the simulation until the flag is set to 1
                check_reg(1, 32'd300, 1);               // Verify that x1 contains 300

                // Test ANDI
                wait_for_reg_to_equal(20, 32'd2);       // Run the simulation until the flag is set to 3
                check_reg(1, 32'h00000040, 1);

                // Test ORI
                wait_for_reg_to_equal(20, 32'd3);       // Run the simulation until the flag is set to 4
                check_reg(1, 32'h000000EC, 1);

                // Test XORI
                wait_for_reg_to_equal(20, 32'd4);
                check_reg(1, 32'h000000AC, 1);

                // Test SLLI
                wait_for_reg_to_equal(20, 32'd5);
                check_reg(1, 32'h00000000, 1);

                // Test SLTI
                wait_for_reg_to_equal(20, 32'd6);
                check_reg(1, 32'h00000001, 1);

                // Test SLTIU
                wait_for_reg_to_equal(20, 32'd7);
                check_reg(1, 32'h00000000, 1);

                // Test SRLI
                wait_for_reg_to_equal(20, 32'd8);
                check_reg(1, 32'h0000001F, 1);

                // Test SRAI
                wait_for_reg_to_equal(20, 32'd9);
                check_reg(1, 32'h0000001F, 1);

                // Test LUI
                wait_for_reg_to_equal(20, 32'd10);
                check_reg(1, 32'h00001000, 1);

                // Test AUIPC
                wait_for_reg_to_equal(20, 32'd11);
                check_reg(1, 32'h0000005C, 1);

                $display("ALL BASIC I-TYPE ASSEMBLY TESTS PASSED");
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
        `endif
        $finish();
    end
endmodule
