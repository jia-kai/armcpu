# totally noncense program just to verify all memory instructions 
# simu: 100ns
li $a0, 5 * 1024 * 1024 + 0x80000000
sw $zero, 0($a0)
halt:
lw $k0, 0($a0)
addiu $k0, $k0, 1
sw $k0, 0($a0)
nop
lbu $k0, 0($a0)
addiu $k0, $k0, 0x2345
sb $k0, 0($a0)
nop
lb $k0, 0($a0)
b halt
