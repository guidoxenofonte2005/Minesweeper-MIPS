.include "macros.asm"

.data
	msg_row:  		.asciiz "Enter the row for the move: "
 	msg_column:  	.asciiz "Enter the column for the move: "
 	msg_win:  		.asciiz "Congratulations! You won!\n"
 	msg_lose:  		.asciiz "Oh no! You hit a bomb! Game over.\n"
	msg_invalid:  .asciiz "Invalid move. Please try again.\n"

.globl main 	 	
.text

main:
  addi $sp, $sp, -256 	# define o tamanho do tabuleiro 
  li $s1, 1		# variável gameActive = 1;
  move $s0, $sp		# move o registrador de pilha para o registrador s0
  move $a0, $s0		# move o valor do registrador s0 para o a0
  
  jal inicialializeBoard# realiza a função initializeBoard;
  move $a0, $s0		# move o valor de s0 para a0 novamente
  jal plantBombs 	# realiza a função plantBombs;
  
  begin_while:		# cria um loop while
  beqz $s1, end_while	# enquanto s1 for diferente de zero, o loop continuará
  move $a0, $s0 
  li $a1, 0		# carrega o valor 0 no registrador a1
  jal printBoard	# imprime o tabuleiro
  
  la $a0, msg_row	# carrega a mensagem de input de linha no registrador a0
  li $v0, 4		# imprime a mensagem
  syscall
  
  li $v0, 5  		# lê o valor da linha
  syscall
  move $s2, $v0		# coloca o valor da linha no registrador s2
  
  la $a0, msg_column	# imprime a mensagem de leitura de coluna
  li $v0, 4
  syscall
  
  li $v0, 5		# lê o valor da coluna
  syscall
  move $s3, $v0 	# coloca o valor da coluna no registrador s3
  
  li $t0, SIZE		# carrega o valor da constante SIZE no registrador t0 (o valor de size é 8)
  blt $s2, $zero, else_invalid	#realiza a checagem das condinções row >= 0, row < SIZE, column >= 0 e column < SIZE)
  bge $s2, $t0, else_invalid		
  blt $s3, $zero, else_invalid
  bge $s3, $t0, else_invalid
  
  addi $sp, $sp, -4
  sw $s0, 0 ($sp)
  move $a0, $s2
  move $a1, $s3
  move $a2, $s0
  jal play			# realiza a função play
  addi $sp, $sp, 4
  bne $v0, $zero, else_if_main 	# condição: !play(board, row, column)
  li $s1, 0			# gameActive = 0;
  la $a0, msg_lose		# imprime a mensagem de derrota caso a função play retorne 0
  
  li $v0, 4
  syscall
  j end_if_main
  
  else_if_main:
  	move $a0, $s0
  	jal checkVictory	# else if (checkVictory(board)) {
  	beq $v0, $zero, end_if_main
  	
  	la $a0, msg_win		# printf("Congratulations! You won!\n");
  	li $v0, 4
  	syscall
  	li $s1, 0											# gameActive = 0; // Game ends
  	j end_if_main 
  else_invalid:		
  	la $a0, msg_invalid	# imprime uma mensagem caso haja um input inválido
  	li $v0, 4
  	syscall
  end_if_main:
  	j begin_while
  end_while:
  	move $a0, $s0 
  	li $a1, 1		# carrega o valor 1 (true) no registrador a1, que permite a visualização das bombas
  	jal printBoard		# imprime o tabuleiro, desta vez mostrando as bombas
  	li $v0, 10
  	syscall

