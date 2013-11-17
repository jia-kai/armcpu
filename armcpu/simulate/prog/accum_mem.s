# simu: 100ns
li $a0, 0x100
sw $zero, 0($a0)
halt:
lw $k0, 0($a0)
addiu $k0, $k0, 1
sw $k0, 0($a0)
b halt
