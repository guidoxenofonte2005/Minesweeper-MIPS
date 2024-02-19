# • - Minesweeper - MIPS Assembly - •
## Introdução:
- O projeto consiste em uma recriação, em formato de aplicativo de terminal, do jogo **Minesweeper** (“Campo Minado”, no Brasil). O código em **C** apresenta todas as funções necessárias para o funcionamento correto do jogo, e o código em Assembly *MIPS* representa o mesmo código, caso designado para um processador de mesma arquitetura.
- Dentre as funções do projeto, as principais são: ***initializeBoard***, responsável por inicializar o tabuleiro; ***placeBombs***, responsável por dispersar as bombas pelo tabuleiro de modo aleatório; ***countAdjacentBombs***, responsável por contar a quantidade de bombas em torno de uma das casas do tabuleiro; ***revealAdjacentCells***, responsável por revelar o valor de uma casa ou de várias casas adjacentes; ***checkVictory***, responsável por estabelecer condições de vitória, e; ***play***, responsável por realizar uma jogada.
- A seguir, serão exibidos com mais detalhes o funcionamento de cada função mencionada acima.
---
## Funções
### InitializeBoard:
- A função ***initializeBoard*** é responsável por inicializar o tabuleiro, como dito anteriormente. Por meio de dois loops, a mesma aplica o valor **-2** à coordenada que está atualmente em seu interior, como visto abaixo:
```c
void initializeBoard(int board[][SIZE]) {
    // Initializes the board with zeros
    for (int i = 0; i < SIZE; ++i) {
        for (int j = 0; j < SIZE; ++j) {
            board[i][j] = -2; // -2 means no bomb
        }
    }
}
```
- O código em assembly é dado por: 
```assembly
inicialializeBoard:
  save_context # permite com que os valores dos registradores s sejam salvos
  move $s0, $a0 # coloca o valor de a0 no registrador s0, ou seja, o tabuleiro
  
  li $s1,0 # carrega o valor 0 no registrador s1, que será utilizado como a variável i
  begin_for_i_it:	# inicializa o primeiro loop for
    li $t0,SIZE		# carrega o tamanho do tabuleiro em t0, neste caso, 8
    bge $s1,$t0,end_for_i_it # define a condição de parada do loop (i >= 8)
  
    li $s2,0 # carrega o valor 0 no registrador s1, que será utilizado como a variável j
    begin_for_j_it:	# inicializa o segundo loop for
      li $t0,SIZE
      bge $s2,$t0,end_for_j_it
      
      # as próximas 4 linhas são responsáveis por obter as coordenadas da matriz baseado em i e j
      sll $t0, $s1, 5 # i*8 (cada variável tem 4 bits, por isso multiplica por 2^5)
      sll $t1, $s2, 2 # j*1
      add $t0, $t0, $t1 # soma as coordenadas
      add $t0, $t0, $s0 # soma a coordenada resultante com o valor base do tabuleiro
      
      li $t1, -2
      sw $t1,0($t0)	# salva o valor de t1 no tabuleiro, isto é, board[i][j] = -2
      
      addi $s2,$s2,1 # j++
      j begin_for_j_it # executa novamente o loop j
    end_for_j_it:
      addi $s1, $s1, 1 # i++
      j begin_for_i_it # executa novamente o loop i
  end_for_i_it:
    restore_context # restaura os valores originais dos registradores s
    jr $ra # retorna para a função principal
```
### PlaceBombs:
- A função ***placeBombs*** é responsável por posicionar as bombas no tabuleiro de modo aleatório, como dito anteriormente. Por meio de um loop, a mesma gera valores aleatórios variando de 0 a 7 enquanto as casas possuírem bombas. Caso uma casa gerada não possua, a função aplica o valor **-1** à coordenada atual, indicando que a mesma possui uma bomba. O código será repetido enquanto o limite de bombas não for atingido, como visto abaixo:
```c
void placeBombs(int board[][SIZE]) {
    srand(time(NULL));
    // Places bombs randomly on the board
    for (int i = 0; i < BOMB_COUNT; ++i) {
        int row, column;
        do {
            row = rand() % SIZE;
            column = rand() % SIZE;
        } while (board[row][column] == -1);
        board[row][column] = -1; // -1 means bomb present
    }
}
```
- O código em assembly é dado por: 
```assembly
placeBombs:
  save_context
  move $s0, $a0
	
  li $a0, 0	  # srand(time(NULL));
  li $a1, 8
	
  li $s1, 0   # i = 0
  begin_for_i_pb:
    li $t0, BOMB_COUNT
    bge $s1, $t0, end_for_i_pb 
	
	do_cb:	# inicializa o loop do... while
	  li $v0, 42 # carrega o comando random int range (inteiro aleatório num conjunto x) no registrador v0
	  syscall    # chamada do sistema
	  move $s2, $a0		# row = rand() % SIZE;
	  syscall 
	  move $s3, $a0		# column = rand() % SIZE;
	  
	sll $t0, $s2, 5
	sll $t1, $s3, 2
	add $t2, $t0, $t1
	add $t0, $t2, $s0
	lw $t1,0 ($t0)      # as 5 linhas acima representam a leitura de um valor do tabuleiro
	
	li $t2, -1
	beq $t2, $t1, do_cb # enquanto o valor lido for igual a -1, repetir a geração aleatória
	
	sw $t2,0 ($t0)	# salva o valor -1 na coordenada, indicando presença de bomba
	
	addi $s1, $s1, 1    # aumenta 1 no contador de bombas
	j begin_for_i_pb
  end_for_i_pb:
	restore_context
	jr $ra
```
### CountAdjacentBombs:
- A função ***countAdjacentBombs*** é responsável por contar as bombas nas células adjacentes à posição selecionada, como dito anteriormente. Possuindo um contador, indicado por count, a mesma utiliza dois loops que iteram sobre os valores adjacentes ao selecionado. Caso uma casa possua valor entre 0 e 7 e possua uma bomba, é **adicionado o valor 1** ao contador. O código será repetido enquanto todas as células não houverem sido checadas, como visto abaixo:
```c
int countAdjacentBombs(int board[][SIZE], int row, int column) {
    // Counts the number of bombs adjacent to a cell
    int count = 0;
    for (int i = row - 1; i <= row + 1; ++i) {
        for (int j = column - 1; j <= column + 1; ++j) {
            if (i >= 0 && i < SIZE && j >= 0 && j < SIZE && board[i][j] == -1) {
                count++;
            }
        }
    }
    return count;
}
```
- O código em assembly é dado por: 
```assembly
countAdjacentBombs:
  save_context
  move $s0, $a0     # tabuleiro -> board[][]
  move $s1, $a1     # linha -> row
  move $s2, $a2     # coluna -> column
  
  li $s7, 0         # count = 0

  addi $s3, $s1, -1 # i = row - 1
  addi $s4, $s1, 1  # limit_i = row + 1
  for_i_loop:
    bgt $s3, $s4, end_for_i # if i > limit_i
    
    addi $s5, $s2, -1 # j = column - 1
    addi $s6, $s2, 1  # limit_j = column + 1
    for_j_loop:
      bgt $s5, $s6, end_for_j # if j > limit_j
      li $t5, SIZE
      
      # bloco condicional:
      # if i >= 0 and i < size and j >= 0 and j < size and board[i][j] == -1
      blt $s3, $zero, continue
      bge $s3, $t5, continue
      blt $s5, $zero, continue
      bge $s5, $t5, continue
      
      sll $t0, $s3, 5
      sll $t1, $s5, 2
      add $t0, $t0, $t1 # checar todos os registradores S
      add $t2, $t0, $s0
  
      lw $s6, 0 ($t2)
      bne $s6, -1, continue
      # fim do bloco condicional

      addi $s7, $s7, 1   # count += 1
      continue:
      	addi $s5, $s5, 1 # j += 1
      	j for_j_loop
    end_for_j:
      addi $s3, $s3, 1   # i += 1
      j for_i_loop
  end_for_i:
    restore_context
  
  move $v0, $s7 # return count
  jr $ra
```
### RevealAdjacentCells:
- A função ***revealAdjacentCells*** é responsável por revelar os valores das células adjacentes à coordenada escolhida. Por meio de dois loops e de forma semelhante à função ***countAdjacentBombs***, utiliza as mesmas comparações da mesma, com exceção do valor procurado na tabela (**-2**). Caso as condições sejam cumpridas, a função ***countAdjacentBombs*** será chamada, e seu valor resultante será inserido no tabuleiro na posição espeificada. Caso o valor seja **zero**, a própria função será chamada recursivamente, com os valores de i e j nos lugares da linha e coluna, respectivamente:
```c
void revealAdjacentCells(int board[][SIZE], int row, int column) {
    // Reveals the adjacent cells of an empty cell
    for (int i = row - 1; i <= row + 1; ++i) {
        for (int j = column - 1; j <= column + 1; ++j) {
            if (i >= 0 && i < SIZE && j >= 0 && j < SIZE && board[i][j] == -2) {
                int x = countAdjacentBombs(board, i, j); // Marks as revealed
                board[i][j] = x;
                if (!x)
                    revealAdjacentCells(board, i, j); // Continues the revelation recursively
            }
        }
    }
}
```
- O código em assembly é dado por: 
```assembly
revealAdjacentCells:
  save_context
  move $s0, $a0     # tabuleiro -> board[][]
  move $s1, $a1     # linha -> row
  move $s4, $a2     # coluna -> column
  
  addi $s2, $s1, -1     # i = row - 1
  addi $s3, $s1, 1      # limit_i = row + 1
  for_i_loop:
    bgt $s2, $s3, end_for_i    	# if i > limit_i
    
    addi $s5, $s4, -1       	# j = column - 1
    addi $s6, $s4, 1        	# limit_j = column + 1
    for_j_loop:
      bgt $s5, $s6, end_for_j   # j > limit_j

      # bloco condicional:
      # if i >= 0 and i < size and j >= 0 and j < size and board[i][j] == -2
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
      # fim do bloco condicional

      move $a0, $s0
      move $a1, $s2
      move $a2, $s5
      jal countAdjacentBombs # realiza a contagem de bombas

      sw $v0,0 ($s7) # salva o valor resultante no tabuleiro
      
      move $t8,$v0
      bne $t8, 0, continue # se o valor de bombas é diferente de zero, passar para a proxima iteração

      move $a0, $s0
      move $a1, $s2
      move $a2, $s5
      jal revealNeighboringCells # caso contrário, realizar a função novamente com os valores atuais de i e j

      continue:
        addi $s5, $s5, 1 # j++
        j for_j_loop
    end_for_j:
      addi $s2, $s2, 1 # i++
      j for_i_loop
  end_for_i:
    restore_context

  jr $ra
```
### CheckVictory:
- A função ***checkVictory*** é responsável por checar se as condições de vitória foram satisfeitas, isto é, **nenhuma bomba acertada e todas as células liberadas**. A mesma realiza tal por meio de dois loops que, a cada vez que o  valor de uma célula for maior ou igual a zero, somar **1** a um contador. Caso este contador seja **menor que o tamanho do tabuleiro (excluídas as bombas)**, a função retorna **0**, indicando que a vitória não foi alcançada. Caso contrário, a função retorna **1**:
```c
int checkVictory(int board[][SIZE]) {
    int count = 0;
    // Checks if the player has won
    for (int i = 0; i < SIZE; ++i) {
        for (int j = 0; j < SIZE; ++j) {
            if (board[i][j] >= 0) {
                count++;
            }
        }
    }
    if (count < SIZE * SIZE - BOMB_COUNT)
        return 0;
    return 1; // All valid cells have been revealed
}
```
- O código em assembly é dado por: 
```assembly
checkVictory:
  save_context
  move $s0, $a0
  
  li $s3, 0 # count = 0
	
  li $s1, 0 # i = 0
  begin_for_i_iteration:
    li $t0, SIZE
    bge $s1, $t0, end_for_i_iteration # if i >= SIZE
    
    li $s2, 0 # j = 0
    begin_for_j_iteration:
      li $t0, SIZE
      bge $s2, $t0, end_for_j_iteration # if j >= SIZE
      
      sll $t0, $s1, 5
      sll $t1, $s2, 2
      add $t0, $t0, $t1
      add $t0, $t0, $s0
      lw $t2, 0 ($t0)
      
      blt $t2, $zero, pass  # if board[i][j] == 0 pass
      addi $s3, $s3, 1      # count++
   
      pass:
      	addi $s2, $s2, 1    # j++
        j begin_for_j_iteration
    end_for_j_iteration:
      addi $s1, $s1, 1  # i++
      j begin_for_i_iteration
  end_for_i_iteration:
    li $t5, SIZE
    mul $t5, $t5, $t5   # t5 = SIZE * SIZE
    sub $t4, $t5, BOMB_COUNT  # t4 = t5 - BOMB_COUNT
    
    bge $s3, $t4, fail  # if count >= t4 fail
    li $v0, 0 # return 0
    restore_context
    jr $ra
    fail:
      li $v0, 1 # return 1
      restore_context
      jr $ra
```
### Play:
- A função ***play*** é responsável por executar de maneira correta os códigos responsáveis pela jogada do usuário, isto é, a implementação correta das funções ***countAdjacentBombs*** e ***revealAdjacentCells***. Caso a coordenada inserida possua uma bomba, a função retornará zero, indicando a derrota do jogador. Caso contrário, executará as funções citadas acima e retornará 1, como visto abaixo:
```c
int play(int board[][SIZE], int row, int column) {
    // Performs the move
    if (board[row][column] == -1) {
        return 0; // Player hit a bomb, game over
    }
    if (board[row][column] == -2) {
        int x = countAdjacentBombs(board, row, column); // Marks as revealed
        board[row][column] = x;
        if (!x)
            revealAdjacentCells(board, row, column); // Reveals adjacent cells
    }
    return 1; // Game continues
}
```
- O código em assembly é dado por: 
```assembly
play:
  save_context
  move $s0, $a0 # valor da linha
  move $s1, $a1 # valor da coluna
  move $s2, $a2 # valor que representa o início do tabuleiro
  
  #código pra pegar um elemento numa posição da matriz
  sll $t0, $s0, 5
  sll $t1, $s1, 2
  add $t0, $t0, $t1 # checar todos os registradores S
  add $s4, $t0, $s2
  
  lw $s3, 0 ($s4)
  
  beq $s3, -1, game_over # caso o jogador atinja uma bomba, game over
  beq $s3, -2, continue # caso contrário, continuar o código
  j final               # caso o jogador insira uma casa já aberta, pular para o final
  continue:
    move $a0, $s2
    move $a1, $s0       # os 3 "move" inserem os valores do tabuleiro, linha e coluna nos registradores a0 a a2
    move $a2, $s1
    jal countAdjacentBombs    # realiza a função de contar bombas adjacentes
    
    sw $v0, 0 ($s4) 		# salva o valor de bombas adjacentes na coordenada inserida
    
    beqz $v0, reveal 		# se s2 for igual a zero, realiza a função reveal
    j final 			# caso contrário, pule direto pro final

    reveal:
      move $a0, $s2
      move $a1, $s0     # os 3 "move" inserem os valores do tabuleiro, linha e coluna nos registradores a0 a a2
      move $a2, $s1
      jal revealNeighboringCells # realiza a função de revelar células adjacentes
      j final
      
    final:
      restore_context
      li $v0, 1 # return 1
      jr $ra
  game_over:
    restore_context
    li $v0, 0 # return 0
    jr $ra
```
