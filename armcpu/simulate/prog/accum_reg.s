loop:
addiu $a3, 1
li $v0, 0x200
sw $a3, 0($v0)
j loop
