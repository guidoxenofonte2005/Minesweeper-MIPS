.include "macros.asm"

.globl checkVictory

checkVictory:
  save_context
  move $s0, $a0
  
  li $s3, 0 # count = 0
	
  li $s1, 0 # i = 0
  begin_for_i_iteration:
    li $t0, SIZE
    bge $s1, $t0, end_for_i_iteration
    
    li $s2, 0 # j = 0
    begin_for_j_iteration:
      li $t0, SIZE
      bge $s2, $t0, end_for_j_iteration 
      
      sll $t0, $s1, 5
      sll $t1, $s2, 2
      add $t0, $t0, $t1
      add $t0, $t0, $s0
      lw $t2, 0 ($t0)
      
      blt $t2, $zero, pass
      addi $s3, $s3, 1 # count++;
   
      pass:
      	addi $s2, $s2, 1
        j begin_for_j_iteration
    end_for_j_iteration:
      addi $s1, $s1, 1
      j begin_for_i_iteration
  end_for_i_iteration:
    li $t5, SIZE
    mul $t5, $t5, $t5
    sub $t4, $t5, BOMB_COUNT
    
    bge $s3, $t4, fail
    li $v0, 0
    restore_context
    jr $ra
    fail:
      li $v0, 1
      restore_context
      jr $ra
