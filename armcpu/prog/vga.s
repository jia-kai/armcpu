#define dest	2
#define FLASH	3
#define HEIGHT	4
#define row_num	5
#define src	6
#define val	7
#define VGA_START	8
#define WIDTH	9
#define col_num	10
#define out_switch ra
#define segdisp 15

j start

.org 0x180
mfc0 $t0, $13
srl $t0, $t0, 2
li $gp, 0x9FD00400
sw $t0, 0($gp)
b .

start:
li $v0, 0x23
li $segdisp, 0x9FD00400
sw $v0, 0($segdisp)

li $VGA_START, 0x9A000000
li $FLASH, 0x9EE00000
li $WIDTH, 400
li $HEIGHT, 300

li $out_switch, 0

start_load:
move $dest, $VGA_START
move $src, $FLASH
li $row_num, 0

load_row:
li $col_num, 0

load_pxl:
beqz $out_switch, label_mem
li $val, 0xFFFF
b out
label_mem:
lw $val, 0($src)
out:
addiu $src, 4
sw $val, 0($dest)
addiu $dest, 4
srl $val, 8
sw $val, 0($dest)
addiu $dest, 4
addiu $col_num, 2
bne $col_num, $WIDTH, load_pxl

addiu $dest, (512 - 400) * 4
addiu $row_num, 1
bne $row_num, $HEIGHT, load_row

xori $out_switch, 1
b start_load

# vim: ft=mips
