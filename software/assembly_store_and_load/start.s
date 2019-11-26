.section    .start
.global     _start

_start:

# Follow a convention
# x1 = result register 1
# x2 = result register 2
# x10 = argument 1 register
# x11 = argument 2 register
# x20 = flag register

# Test 1
li x10, 100
li x11, 0x10000000
sw x10, 0(x11)
lw x1, 0(x11)
li x20, 1

# Test 2
li x10, 128 # 1000 0000
sb x10, 2(x11) # 1000 0000
lb x1, 2(x11) # 1111 1111 1000 0000
li x20, 2

# Test 3
sh x10, 1(x11) # 0000 0000 1000 0000
lh x1, 1(x11) # 0000 0000 1000 0000
li x20, 3

# Test 4
li x10, 128 # 1000 0000
sb x10, 2(x11) # 1000 0000
lbu x1, 2(x11) # 0000 0000 1000 0000
li x20, 4

# Test 5
sb x10, 0(x11) # 1000 0000
lhu x1, 0(x11) # 1000 0000 1000 0000
li x20, 5

Done: j Done
