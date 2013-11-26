# simu: 200ns
start:

li $v0, 3		# valid, global
mtc0 $v0, $2	# EntryLo0

li $v0, 0x23000000	# VPN2
mtc0 $v0, $10	# EntryHI
tlbwi

li $v0, 1
mtc0 $v0, $0	# index
li $v0, 0x24000000	# VPN2
mtc0 $v0, $10	# EntryHI
tlbwi

li $v0, 0x1000
mtc0 $v0, $15, 1 # EBase

li $gp, 0x23000000
lw $v0, 0($gp)	# should got first instr
li $gp, 0x24000004
lw $v1, 0($gp)	# should got second instr
sw $v0, 0($gp)	# should cause exception

b .

.org start + 0x1000	# TLB missing
j 0x1180

.org start + 0x1180	# syscall handler

mfc0 $v0, $10	# EntryHI, badvaddr
beqz $t0, 1f
sw $v0, 4($zero)	# write missing
1:
li $t0, 1
lw $v0, 4($zero)	# read missing
b next	# above in delay slot
next:
b .

# vim: ft=mips
