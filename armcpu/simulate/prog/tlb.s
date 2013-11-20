li $v0, 7
mtc0 $v0, $2	# EntryLo0
tlbwi
lw $v0, 0
halt: j halt

# vim: ft=mips
