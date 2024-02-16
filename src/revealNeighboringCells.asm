.include "macros.asm"

.globl revealNeighboringCells

revealNeighboringCells:
  save_context
  move $s0, $a0     # tabuleiro
  move $s1, $a1     # row
  move $s4, $a2     # column
  
  addi $s2, $s1, -1     # row - 1
  addi $s3, $s1, 1      # row + 1
  for_i_loop:
    bgt $s2, $s3, end_for_i    	# i > row + 1
    
    addi $s5, $s4, -1       	# column - 1
    addi $s6, $s4, 1        	# column + 1
    for_j_loop:
      bgt $s5, $s6, end_for_j   # j > column + 1

      blt $s2, $zero, continue
      bge $s2, SIZE, continue
      blt $s5, $zero, continue
      bge $s5, SIZE, continue

      sll $t0, $s2, 5
      sll $t1, $s5, 2
      add $t0, $t0, $t1
      add $t0, $t0, $s0
      move $s7,$t0

      lw $t1, 0($t0)

      bne $t1, -2, continue

      move $a0, $s0
      move $a1, $s2
      move $a2, $s5
      jal countAdjacentBombs

      sw $v0,0 ($s7)
      
      move $t8,$v0
      bne $t8, 0, continue

      move $a0, $s0
      move $a1, $s2
      move $a2, $s5
      jal revealNeighboringCells

      continue:
        addi $s5, $s5, 1
        j for_j_loop
    end_for_j:
      addi $s2, $s2, 1
      j for_i_loop
  end_for_i:
    restore_context

  jr $ra