.section    .start
.global     _start

_start:

# Follow a convention
# x1 = result register 1
# x2 = result register 2
# x3 = pc+4 for jal and jalr
# x10 = argument 1 register
# x11 = argument 2 register
# x20 = flag register

# Test BEQ
li x10, 100		# Load argument 1 (rs1)
li x11, 100
add x1, x10, x11
beq x10, x11, 8
add x1, x0, x0   # This should be skipped
li x20, 1		# Set the flag register to stop execution and inspect the result register
			# Now we check that x1 contains 200

# Test BNE
li x10, 100		# Load argument 1 (rs1)
li x11, 200
add x1, x10, x11
bne x10, x11, 8
add x1, x0, x0   # This should be skipped
li x20, 1		# Set the flag register to stop execution and inspect the result register
			# Now we check that x1 contains 300

Done: j Done
