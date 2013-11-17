li $a0, 0x100
sw $zero, 0($a0)
halt:
lw $a3, 0($a0)
addiu $a3, $a3, 1
sw $a3, 0($a0)
j halt
