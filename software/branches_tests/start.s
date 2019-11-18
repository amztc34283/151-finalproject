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
li x2, 100		# Set an initial value of x2
beq x0, x0, branch1	# This branch should succeed and jump to branch1
li x2, 123		# This shouldn't execute, but if it does x2 becomes an undesirable value
branch1: li x1, 500	# x1 now contains 500
li x20, 2		# Set the flag register
			# Now we check that x1 contains 500 and x2 contains 100


addi x0, x0, -32
addi x0, x0, -32
addi x0, x0, -32

# Test BEQ, Branch Not Taken
li x10, -1				# Set argument s.t. < 0
li x2, 100				# Expected value of x2
li x1, 300				# Expected value of x1
beq x0, x10, branch2	# Branch should not be taken
li x2, 111				# x2 set to 111
addi x0, x0, 1000
addi x0, x0, 1000
j done2
branch2: li x1, 501

done2: li x20, 3

Done: j Done
