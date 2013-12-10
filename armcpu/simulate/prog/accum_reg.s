loop:
addiu $a3, 1
li $gp, 0xBFD00400
sw $a3, 0($gp)
b loop
