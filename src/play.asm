.include "macros.asm"

.globl play

play:
  save_context # salva a matriz
  move $s0, $a0 # row
  move $s1, $a1 # column
  move $s2, $a2 # 
  
  #código pra pegar um elemento numa posição da matriz
  sll $t0, $s0, 5
  sll $t1, $s1, 2
  add $t0, $t0, $t1 # checar todos os registradores S
  add $s4, $t0, $s2
  
  lw $s3, 0 ($s4)
  
  # condições baseadas no valor obtido na posição da matriz
  beq $s3, -1, game_over
  beq $s3, -2, continue
  j final
  continue:
    move $a0, $s2
    move $a1, $s0
    move $a2, $s1
    jal countAdjacentBombs  	# realiza a função de contar bombas adjacentes
    
    sw $v0, 0 ($s4) 		# salva o valor dentro da matriz
    
    beqz $v0, reveal 		# se s2 for igual a zero, realiza a função reveal
    j final 			# caso contrário, pule direto pro final
    reveal:
      move $a0, $s2
      move $a1, $s0
      move $a2, $s1
      jal revealNeighboringCells
      j final
      
    final:
      restore_context # realiza a edição na matriz
      li $v0, 1 # return 1
      jr $ra
  game_over:
    restore_context # realiza a edição na matriz
    li $v0, 0 # return 0
    jr $ra
  
# your code here
