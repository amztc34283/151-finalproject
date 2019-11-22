`timescale 1ns/10ps

module bios_testbench();
	reg clk, rst;
	parameter CPU_CLOCK_PERIOD = 20;
	parameter CPU_CLOCK_FREQ = 50_000_000;
	initial clk = 0;
    always #(CPU_CLOCK_PERIOD/2) clk <= ~clk;
	Riscv151 # (
		.CPU_CLOCK_FREQ(CPU_CLOCK_PERIOD)
	) CPU(
		.clk(clk),
		.rst(rst),
		.FPGA_SERIAL_RX(),
		.FPGA_SERIAL_TX()
	);
	
	initial begin
		$readmemh("../../software/bios151v3/bios151v3.hex",
			CPU.bios_mem.mem);

        `ifndef IVERILOG
            $vcdpluson;
        `endif
        `ifdef IVERILOG
            $dumpfile("bios_testbench.fst");
            $dumpvars(0, bios_testbench);
        `endif

		rst = 1;
		repeat (30) @(posedge clk);
		rst = 0;

		

		`ifndef IVERILOG
			$vcdplusoff;
		`endif
		$finish();
	end

endmodule
	
	
	
