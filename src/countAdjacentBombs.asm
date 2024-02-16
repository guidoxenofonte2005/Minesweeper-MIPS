.include "macros.asm"

.globl countAdjacentBombs

countAdjacentBombs:
  save_context
  move $s0, $a0 # tabuleiro
  addi $s1, $a1, -1 # i = row - 1
  addi $s2, $a1, 1 # row + 1
  move $s5, $a2

  li $s7, 0 # count = 0

  for_i_loop:
    bgt $s1, $s2, end_for_i     # i > row + 1

    addi $s3, $s5, -1         	# j = column - 1 
    addi $s4, $s5, 1         	# column + 1
    for_j_loop:
      bgt $s3, $s4, end_for_j 	# j > column + 1

      blt $s1, $zero, continue
      bge $s1, SIZE, continue
      blt $s3, $zero, continue
      bge $s3, SIZE, continue

      sll $t0, $s1, 5
      sll $t1, $s3, 2
      add $t0, $t0, $t1
      add $t2, $t0, $s0
      lw $t1, 0 ($t2)

      bne $t1, -1, continue

      addi $s7, $s7, 1
      continue:
          addi $s3, $s3, 1 # j++
          j for_j_loop
    end_for_j:
      addi $s1, $s1, 1 # i++
      j for_i_loop
  end_for_i:
    move $v0, $s7
    restore_context
  jr $ra
