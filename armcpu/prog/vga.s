#define dest	2
#define FLASH	3
#define HEIGHT	4
#define row_num	5
#define src	6
#define val	7
#define VGA_START	8
#define WIDTH	9
#define col_num	10
#define out_switch 11

li $VGA_START, 0x9A000000
li $FLASH, 0x9EE00000
li $WIDTH, 400
li $HEIGHT, 300

start_load:
move $dest, $VGA_START
move $src, $FLASH
li $row_num, 0

load_row:
li $col_num, 0

load_pxl:
bnez $out_switch, 1f
li $val, 0
b 2f
1:
lw $val, 0($src)
2:
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
