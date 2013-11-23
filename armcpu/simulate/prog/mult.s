# simu: 90ns
li $a0, 0x19930501
li $a1, 0x19931102
mult $a0, $a1
mfhi $v0
mflo $v1
mthi $a0
mtlo $a1
mfhi $v0
mflo $v1

halt: b halt
# vim: ft=mips
