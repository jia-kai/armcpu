addiu $a0, $a0, 1
addiu $a1, $a1, 1
loop_start:
addu $a2, $a0, $a1
move $a0, $a1
move $a1, $a2
j loop_start
