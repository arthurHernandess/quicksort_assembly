.data 
	introducao: .asciiz "\n vetor desordenado: "
	resultado: .asciiz  "\n vetor ordenado:    "
	separador: .asciiz ", "
	array: .word 12, 5, 7, 19, 3, 8, 4, 10, 14, 6, 1, 15, 2, 9, 11
	tamanho: .word 15
	
.text
main:
	la $s0, array     # inicio do array
	lw $s1, tamanho   # tamanho
	
	li $v0, 4
	la $a0, introducao # "vetor desornado: "
	syscall
	li $a1, 0	  # indice pra percorrer
	move $a2, $s1	  # tamanho do vetor
	jal exibirVetor
	
	# ordena o vetor
	li $a1, 0	  # comeco do subarray
	addi $a2, $s1, -1 # final do subarray
	jal quicksort
	
	li $v0, 4
	la $a0, resultado # "vetor ordenado: "
	syscall
	li $a1, 0	  # indice pra percorrer
	move $a2, $s1	  # tamanho
	jal exibirVetor
	
	j fim

# s0 posicao inicial do array
# a1 indice atual
# a2 tamanho do array
exibirVetor:
	beq $a1, $a2, voltar  # se o indice bater no tamanho acabou o loop
		li $t4, 4
		mult $a1, $t4
		mflo $t2   	  # t2 é o deslocamento no vetor
		add $t3, $s0, $t2  # t3 é a posicao do array deslocado t2
		
		li $v0, 1
		lw $a0, 0($t3)  # exibe o array na posicao t3 calculada
		syscall
		li $v0, 4
		la $a0, separador # coloca uma virgula pra separar
		syscall
		
		addi $a1, $a1, 1
		j exibirVetor
		
voltar: 
	jr $ra
	
# s0 posicao inicial array completo;
# a1 indice comeco do subarray;
# a2 indice fim do subarray;
quicksort:
	addi $sp, $sp, -16 
	sw $a1, 0($sp)
	sw $a2, 4($sp)
	sw $ra, 8($sp)
		
	slt $t0, $a1, $a2      # se o comeco é menor que o fim faz o resto, se nao, sai fora
	beq $t0, $zero, retornar
		# antes da proxima chamada salva espaço na pilha para o comeco, o fim e a linha de retorno
	
		jal partition
		move $t1, $v1
		sw $t1, 12($sp) # empilha o pivo dessa execucao pra nao perder
		
		lw $t1, 12($sp)         # recupera o pivo pra calcular o fim do subarray
		addi $a2, $t1, -1
		lw $a1, 0($sp)
		jal quicksort
	
		lw $t1, 12($sp)	        # recupera o pivo pra calcular o comeco do subarray
		addi $a1, $t1, 1
		lw $a2, 4($sp)
		jal quicksort
		
retornar: 
	# recupera os parametros dessa chamada na pilha e desempilha eles
	lw $a1, 0($sp)
	lw $a2, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 16
	
	j voltar
	
partition:	
	li $t0, 4
	mult $a2, $t0
	mflo $t0
	
	add $t0, $s0, $t0
	
	lw $t1, 0($t0)   # t1 é o pivo. valor do fim do subarray atual
	move $t0, $a1    # t0 é o indice que ta "livre" pra trocar. comeca como a posicao inicial do subarray
	move $t2, $a1    # t2 é o indice pra percorrer o subarray
	
loopPercorrerSubarray:	
	li $v0, 1
	move $a0, $t2
		
	slt $t3, $t2, $a2
	beq $t3, $zero, fimLoop		# t3 é auxiliar pra fazer os condicionais			
		li $t4, 4
		mult $t2, $t4
		mflo $t4
		add $t4, $s0, $t4	# t4 é o endereco do array no indice atual
		lw $t5, 0($t4)  	# t5 recebe o valor do array no indice atual (vai ser sobrescrito)
		slt $t3, $t5, $t1	# verifica se o valor do array no indice atual é menor que o pivo
		beq $t3, $zero, pularTroca		# se sim, troca os dois valores de posicao			
			li $t5, 4
			mult $t0, $t5
			mflo $t5
			add $t5, $s0, $t5   # t5 agora é o endereco do array no indice "livre"
			lw $t6, 0($t5)      # joga o valor do array no indice "livre" pra t6 (auxiliar)
			lw $t7, 0($t4)	    # joga o valor do array no indice atual pra t7 (auxiliar tb)			
			sw $t7, 0($t5)      # troca o valor do array no indice atual pelo indice "livre"
			sw $t6, 0($t4)	    # substitui o valor do array no indice livre pelo t6
			
			addi $t0, $t0, 1

pularTroca:
		addi $t2, $t2, 1
		j loopPercorrerSubarray
	
fimLoop:
	li $t5, 4
	mult $t0, $t5
	mflo $t5
	add $t5, $s0, $t5   # t5 agora é o endereco do array no indice "livre"
	
	li $t4, 4
	mult $a2, $t4
	mflo $t4
	add $t4, $s0, $t4   # t4 agora é o endereco do array no ultimo indice do subarray atual
	
	lw $t6, 0($t5)      # joga o valor do array no indice "livre" pra t6 (auxiliar)
	lw $t7, 0($t4)	    # joga o valor do array no ultimo indice pra t7 (auxiliar tb)			
	sw $t7, 0($t5)      # troca o valor do array no ultimo indce pelo indice "livre"
	sw $t6, 0($t4)	    # substitui o valor do array no indice livre pelo t6
	
	move $v1, $t0
	j voltar

fim: 
	li $v0, 10
	syscall
