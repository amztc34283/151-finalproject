.section    .start
.global     _start

_start:
	li x1, 100			# Set x1 to be initial value
	auipc x11, 0		# Set x11 to be PC @ `li x1, 100`
	lw x1, -4(x11)		# Read machine code for `li x1, 100`
	lw x2, 0(x11)		# Read machine code for `auipc x11, 0`
	li x20, 1			# Check register flag
