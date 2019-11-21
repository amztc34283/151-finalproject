# This file is for step 9 imem testing.
# This file will be loaded to BIOS_MEM.
# First, execute customized bios program which loads instruction and data to imem and dmem.
# Second, change the PC to start instruction in imem.
li x10, 1073741884 #0100...100000
li x12, 536870912
li x2, 1 # counter
li x3, 9 # number of imem instruction (2-1)
loop: beq x2, x3, finish
lw x1, 0(x10)
sw x1, 0(x12)
addi x10, x10, 4
addi x12, x12, 4
addi x2, x2, 1
j loop
finish: lui x11, 65536 # load upper immediate to x11 so that PC will be 0001...0000
jalr x0, x11, 0
# Instruction and data to be loaded start below
li x20, 1
addi x1, x0, 10
li x20, 2
li x5, 268435456
sw x20, 0(x5)
lw x1, 0(x5)
li x20, 3
