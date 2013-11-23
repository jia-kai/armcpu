# simu: 70ns
li $gp, 0x80001000
li $v0, 0x19931102
sw $v0, 0($gp)
lw $a0, 0($gp)
li $a0, 0x123
addiu $a1, $a0, 1

halt: b halt
