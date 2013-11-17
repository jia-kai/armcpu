li $v0, 0x100
li $a1, 1
sw $a1, 0($v0)
loop_start:
lw $a0, 0($v0)
addiu $a1, $a0, 1
sw $a1, 0($v0)
move $a3, $a1
j loop_start
