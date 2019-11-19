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

# Test BNE, Branch Not Taken
li x10, 1
li x11, 1
bne x10, x11, branch3
add x1, x10, x11 # This should not be skipped
j done3
branch3: li x1, 100
done3: li x20, 4

# Test BNE, Branch Taken
li x10, 999
li x11, 1
bne x10, x11, branch4
add x1, x10, x11 # This should be skipped
j done4
done4: li x1, 20
branch4: li x20, 5

# Test BLT Branch Not Taken
li x10, 999
li x11, 1
branch5: add x2, x11, x11 # This should be executed once, should not be infinite loop
li x20, 6 # check x2 value at the moment
blt x10, x11, branch5
add x1, x10, x11 # This should not be skipped
jal x3, done5
done5: addi x2, x3, 0
li x20, 7

# Test BLT Branch Taken
li x10, -10
li x11, 50000
blt x10, x11, branch6 # This should be taken
branch6: li x1, 12345
li x20, 8

# Test BGE Branch Taken
li x10, 101
li x11, 1
li x12, 31
bge x10, x11, done6
add x1, x10, x11 # This should be skipped
done6: sll x1, x10, x12 # x1 = 80000000
li x20, 9

# Test BGE Branch Not Taken ()
li x10, 1
li x11, 2
bge x10, x11, branch7
sb x11, 3(x10)
lb x1, 3(x10)
j done7
branch7: li x1, 200
done7: li x20, 10

# Test BLTU Branch Not Taken ()
li x10, -1
li x11, 1
branch8: add x2, x11, x11 # This should be executed once, should not be infinite loop
li x20, 11 # check x2 value at the moment
#bltu x10, x11, branch8
#add x1, x10, x11 # This should not be skipped
#jal x3, done8
#done8: addi x2, x3, 0
#li x20, 12

# Test BGEU


Done: j Done
