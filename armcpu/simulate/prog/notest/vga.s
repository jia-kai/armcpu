# simu: 100000ns
li $gp, 0x9A000000
li $v0, 0xFF
sw $v0, 0($gp)
b .
