.section    .start
.global     _start

_start:

# Follow a convention
# x1 = result register 1
# x2 = result register 2
# x10 = argument 1 register
# x11 = argument 2 register
# x20 = flag register

# Test BEQ, Branch Taken
li x2, 100					#1
beq x0, x0, branch1 		#2 FIRST NOP
li x2, 123
branch1: li x1, 500			#3
li x20, 2					#4



addi x0, x0, -32			#5
addi x0, x0, -32			#6
addi x0, x0, -32			#7

# Test BEQ, Branch Not Taken
li x10, -1					#8
li x2, 100					#9
li x1, 300					#10
beq x0, x10, branch2		#11 SECOND NOP
li x2, 111					#12
addi x0, x0, 1000			#13
addi x0, x0, 1000			#14
j done2						#15 THIRD NOP
branch2: li x1, 501

done2: li x20, 3			#16

Done: li x10, 0x80000010	#17/18 (li := lui + addi)
lw x2, 0(x10)				#19, read cycle counter
lw x3, 4(x10)				#20, read instruction counter
nop
nop
nop
li x20, 4					#22, Set stop flag
sw x0, 8(x10)				#23, reset the counters
lw x2, 0(x10)				#24, read cycle counter, expected = 0
lw x3, 4(x10)				#25, read instruction counter, expected = 1
li x20, 5

sw x0, 8(x10)				# reset the counters
j pos2
pos2: j pos3
pos3: j pos4
pos4: j pos5
pos5: j pos6
pos6: j pos7
pos7: j pos8
pos8: j pos9
pos9: j pos10
pos10:

nop

lw x2, 0(x10)				# read cycle counter
lw x3, 4(x10)				# read instruction counter
li x20, 6					# Set stop flag, 9 jumps, expected diff of 8

li x10, 0x80000020 # User I/O Empty
lw x1, 0(x10)
li x20, 7

# The following nops is for the situation that the method
# wait_for_reg_to_equal bypass lw and li below before
# setting clean_buttons in testbench.
add x0, x0, x0     # Put it in idle state
add x0, x0, x0     # Put it in idle state
add x0, x0, x0     # Put it in idle state

lw x1, 0(x10) # fifo should not be empty
li x20, 8

lw x1, 4(x10) # buttons should be 111
li x20, 9

lw x1, 8(x10) # switches should be 00
li x20, 10
