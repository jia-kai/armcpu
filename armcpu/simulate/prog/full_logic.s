# totally noncense program just to verify all logical instructions 
li $a0, 0x19931102
li $a1, 0x00ff
li $a2, 0xff00
and $a3, $a0, $a1			#a3 = 2
nop
andi $a3, $a0, 0x0f0f       #a3 = 0x102
nop
nor $a3, $a1, $a2			#a3 = 0xffff0000
nop
or $a3, $a0, $a1			#a3 = 0x199311ff
nop
ori $a3, $a0, 0x0f0f 	    #a3 = 0x19931f0f
nop
xor $a3, $a0, $a1			#a3 = 0x199311fd
nop
xori $a3, $a0, 0x1403		#a3 = 0x19930501 
halt:
	j halt