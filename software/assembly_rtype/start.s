.section    .start
.global     _start

_start:

# Follow a convention
# x1 = result register 1
# x2 = result register 2
# x10 = argument 1 register
# x11 = argument 2 register
# x20 = flag register

# Test ADD
li x10, 100		# Load argument 1 (rs1)
li x11, 200
add x1, x10, x11	# Execute the instruction being tested
li x20, 1		# Set the flag register to stop execution and inspect the result register
			# Now we check that x1 contains 300

# Test AND
and x1, x10, x11
li x20, 2

# Test OR
or x1, x10, x11  #000000EC
li x20, 3

# Test XOR
xor x1, x10, x11  #000000AC
li x20, 4

# Test SLL
li x12, 31
sll x1, x10, x12  #00000000
li x20, 5

# Test SLT
li x13, 200
slt x1, x10, x13  #00000001
li x20, 6

# Test SLTU
li x10, 1000
li x14, 5
sltu x1, x10, x14  #00000000
li x20, 7

# Test SRL
srl x1, x10, x14  #0000001F
li x20, 8

# Test SRA
sra x1, x10, x14  #0000001F
li x20, 9

Done: j Done
