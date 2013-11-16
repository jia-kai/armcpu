li $a0, 0x100	# base mem address, current ptr
li $a1, 1
sw $a1, -4($a0)
sw $a1, 0($a0)

loop_start:
lw $a1, -4($a0)
lw $a2, 0($a0)
addu $a3, $a1, $a2
sw $a2, -4($a0)
sw $a3, 0($a0)
j loop_start
