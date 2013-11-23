# simu: 60ns 
li $a0, 8
li $a1, 1
sll $a2, $a0, 2			#a2 = 32
sllv $a2, $a0, $a1		#a2 = 16
li $a2, -24
sra $a0, $a2, 2 		#a0 = -6
srav $a0, $a2, $a1      #a0 = -12
srl $a0, $a2, 2 		#a0 = 0x3ffffffa
srlv $a0, $a2, $a1		#a0 = 0x7ffffff4
halt: b halt

# vim: ft=mips
