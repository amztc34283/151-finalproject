.section    .start
.global     _start

_start:

# Follow a convention
# x1 = result register 1
# x2 = result register 2
# x10 = argument 1 register
# x11 = argument 2 register
# x20 = flag register

li x10, 100		# Set an initial value of x10
csrw 0x51E, x10  # Set CSR register to value of x10
li x20, 1		# Set flag register to initiate check register
nop
csrwi 0x51E, 16  # Set CSR register value of 16
li x20, 2		# Set flag register to initiate check register


