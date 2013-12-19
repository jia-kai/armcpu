.globl main

main:
jal f0
li $v0, 0x66
li $gp, 0xBFD00400
sw $v0, 0($gp)

li $a0, 0
j exit

f0:
  sw $fp, 0($sp)                
  sw $ra, -4($sp)               
  li $ra, 0
  move $fp, $sp                 
  addiu $sp, $sp, -16           
  move  $sp, $fp                
  lw    $ra, -4($fp)            
  lw    $fp, 0($fp)             
  jr    $ra                     

# vim: ft=mips
