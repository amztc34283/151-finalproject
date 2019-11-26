- Run reg_file Test:
	- iverilog -o regfile ./hardware/src/riscv_core/reg_file.v ./hardware/sim/reg_file_testbench.v
	- ./regfile
- Run ld_sel Test:
	- iverilog -o ld_sel ./hardware/src/riscv_core/ld_sel.v ./hardware/sim/ld_sel_testbench.v
	- ./ld_sel  

- Install RISC-V GNU Tool Chain
	- https://github.com/riscv/riscv-gnu-toolchain

  
TODO: 
- Use defined opcodes in /riscv_core/Opcodes.vh
