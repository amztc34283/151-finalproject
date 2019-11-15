- Run reg_file Test:
	- iverilog -o regfile ./hardware/src/riscv_core/reg_file.v ./hardware/sim/reg_file_testbench.v
	- ./regfile
- Run ld_sel Test:
	- iverilog -o ld_sel ./hardware/src/riscv_core/ld_sel.v ./hardware/sim/ld_sel_testbench.v
	- ./ld_sel
TODO: 
- Use defined opcodes in /riscv_core/Opcodes.vh
- Check whether I wired the stuff correctly in riscvcore, if this affects blocks work in EXECUTE + MEM/WB stage, feel free to modify IF/D stage so it works-- or setup your testbench such that it tests the stages independetly; whichever is easiest. Cannot get IF/D stage finished tonight. 
