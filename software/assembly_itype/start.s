.section    .start
.global     _start

_start:

# Follow a convention
# x1 = result register 1
# x2 = result register 2
# x10 = argument 1 register
# x11 = argument 2 register
# x20 = flag register

# Test ADDI
li x10, 100		# Load argument 1 (rs1)
addi x1, x10, 200	# Execute the instruction being tested
li x20, 1		# Set the flag register to stop execution and inspect the result register
			# Now we check that x1 contains 300

# Test ANDI
andi x1, x10, 200
li x20, 2

# Test ORI
ori x1, x10, 200  #000000EC
li x20, 3

# Test XORI
xori x1, x10, 200  #000000AC
li x20, 4

# Test SLLI
slli x1, x10, 31  #00000000
li x20, 5

# Test SLTI
slti x1, x10, 200  #00000001
li x20, 6

# Test SLTIU
li x10, 1000
sltiu x1, x10, 5  #00000000
li x20, 7

# Test SRLI
li x10, 1000  #000003E8
srli x1, x10, 5  #0000001F
li x20, 8

# Test SRAI
srai x1, x10, 5  #0000001F
li x20, 9

# Test LUI
lui x1, 1
li x20, 10

# Test AUIPC
auipc x1, 0
li x20, 11

# TODO LB, LH, LW, LBU, LHU

Done: j Done
