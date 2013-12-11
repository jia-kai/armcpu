#simu: 50ns
#if 0
#define write_one_tlb(idx, hi, low0, low1) \
	li $v0, idx ;\
	mtc0 $v0, $0 ;\
	li $v0, hi ;\
	mtc0 $v0, $10 ;\
	li $v0, low0 ;\
	mtc0 $v0, $2 ;\
	li $v0, low1 ;\
	mtc0 $v0, $3; \
	tlbwi

write_one_tlb(3, 0x7fffe000, 0xef57, 0xef17)
write_one_tlb(4, 0x10002000, 0xecd7, 0xed17)
write_one_tlb(5, 0x10000000, 0xec17, 0xec97)
write_one_tlb(6, 0x10004000, 0xed57, 0xed97)

li $gp, 0x10007000
#lb $v0, 1($gp)
lb $v0, 1($gp)
#endif

li $gp, 0x10007000
lb $v0, 1($gp) # exception

b .
