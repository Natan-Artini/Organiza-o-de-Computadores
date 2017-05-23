@ Programa para leitura de uma chave e de uma mensagem
@ Atraves da chave é criada uma criptografia para a mensagem
@ Apos é pedido a chave para descriptografia da mensagem
@ Se a chave for a mesma que digitada no inicio a mensagem aparecera
@ Caso contrario aparecera caracteres aleatorios
 
	.global _start      @ ligador necessita deste rótulo
@------------------------------------CONSTANTES E CONTROLES---------------------------------------------
	@ Endereco do teclado
	.set kdb_data,   	0x00090000	@ Endereco teclado 
	.set kdb_status, 	0x00090001	@ Endereco status teclado
	.equ kdb_ready,		1			@ Flag teclado

	@ Constantes de tamanho de chave e da mensagem
	.equ max_chave,		16			@ Define o tamanho maximo para chave de 15 caracteres 1 espaco para o \n
	.equ max_msg,		255			@ Define o tamanho maximo para mensagem 254 caracteres 1 espaco para o \n
	.equ max_msg_cripto,255			@ Define o tamanho maximo para mensagem criptografada
	
_start:
	
	@Escreve a mensagem inicial pedindo para digitar a chave
	mov     r0, #1      		@ stdout
	ldr     r1, =msg    		@ Endereco da mensagem
	ldr     r2, =len    		@ Tamanho mensagem a ser escrita
	mov     r7, #4
	svc     0x055
	
@------------------------------------LEITURA CHAVE---------------------------------------------
	@ Leitura inicial da chave *
leitura_inicial:
	ldr		r3, =kdb_status
	ldr		r4, [r3]				@ Carrega no R4 o valor de R3
	cmp     r4, #kdb_ready			@ Compara R4 com 0x1
	bne    	leitura_inicial			@ Fica no loop se diferentes
	ldr		r3, =kdb_data
	ldr		r4, [r3]				@ Se nao, carrega em R4 o valor digitado

	@ Comparar se precionou '*' para iniciar a chave
	cmp		r4, #10					@ Comprar se foi digitado o *
	bne		leitura_inicial			@ Se diferente de * volta para leitura
	b		escrever				@ Se * vai para escrever

	@ Apos digitado * leitura da chave
leitura_kdb_chave:
	ldr		r3, =kdb_status
	ldr		r4, [r3]				@ Carrega no R4 o valor de R3
	cmp     r4, #kdb_ready			@ Compara R4 com 0x1
	bne    	leitura_kdb_chave		@ Fica no loop se diferentes
	ldr		r3, =kdb_data
	ldr		r4, [r3]				@ Se nao, carrega em R4 o valor digitado
	cmp		r4, #10					@ Compara se foi outro *
	bne		escrever				@ Se diferente de * escreve na tela e guarda
	b		leitura_kdb_chave

	@ Exibe um asterisco na tela
escrever:
	mov    	r0, #1  				@ stdout
	mov    	r1,	#10			 		@ Define a mensagem como *
	mov    	r2, #1					@ Define tamanho mensagem a ser escrita como 1
	mov    	r7, #4
	svc    	#0x55
	
	@ Compara se precionou '#' para encerar a chave
	cmp		r4, #11					@ compara se foi '#' 
	bne		guardar_chave			@ se for diferente salva e le outro valor
	b 		leitura_mensagem		@ se nao vai para descriptografia
	
@ Guarda a chave na memoria	
guardar_chave:

	ldr 	r10, =chave				@ coloca endereco em R10
	strb	r4, [r10, r5]			@ Armazena o valor
	add 	r5, r5, #1				@ Deslocamento
	mov 	r4, #0					@ Limpa registrador
	
	b		leitura_kdb_chave		@ Retorna a leitura da chave
	
@------------------------------------LEITURA MENSAGEM---------------------------------------------	
leitura_mensagem:
	
	@Escreve a mensagem pedindo para digitar a mensagem
	mov     r0, #1      		@ fd -> stdout
	ldr     r1, =msg2   		@ buf -> msg2
	ldr     r2, =len2   		@ count -> len2(msg2)
	mov     r7, #4      		@ write é syscall #4
	svc     0x055       		@ executa syscall 

	@Faz a leitura da mensagem digitada pelo usuario
	mov     r0, #0      		@ fd -> stdin
	ldr     r1, =mensagem 		@ buf -> buffer
	ldr     r2, =max_chave		@ count -> max_msg
	mov     r7, #3      		@ write é syscall #3
	svc     #0x55       		@ executa syscall 
	mov		r2, r0      		@ número de bytes a serem lidos

@------------------------------------CRIPTOGRAFIA-------------------------------------------------
criptografia:
	@Escreve a mensagem criptografada
	mov     r0, #1
	ldr     r1, =mensagem   	@ buf -> msg3
	ldr     r2, =len3   		@ count -> len3(msg3)
	mov     r7, #4      		@ write é syscall #4
	svc     0x055       		@ executa syscall

@------------------------------------INICIO DESCRIPTOGRAFIA-----------------------------------------------

	@Escreve a mensagem pedindo a chave de descriptografia
	mov     r0, #1      		@ fd -> stdout
	ldr     r1, =msg3   		@ buf -> msg3
	ldr     r2, =len3   		@ count -> len3(msg3)
	mov     r7, #4      		@ write é syscall #4
	svc     0x055       		@ executa syscall 
	
@------------------------------------LEITURA CHAVE DESCRIPTOGRAFIA---------------------------------
		@ Leitura inicial da chave *
leitura_desc:
	ldr		r3, =kdb_status
	ldr		r4, [r3]				@ Carrega no R4 o valor de R3
	cmp     r4, #kdb_ready			@ Compara R4 com 0x1
	bne    	leitura_desc			@ Fica no loop se diferentes
	ldr		r3, =kdb_data
	ldr		r4, [r3]				@ Se nao, carrega em R4 o valor digitado

	@ Comparar se precionou '*' para iniciar a chave
	cmp		r4, #10					@ Comprar se foi digitado o *
	bne		leitura_desc			@ Se diferente de * volta para leitura
	b		escrever2				@ Se * vai para escrever
	
	@ Apos digitado * leitura da chave
leitura_kdb_desc:
	ldr		r3, =kdb_status
	ldr		r4, [r3]				@ Carrega no R4 o valor de R3
	cmp     r4, #kdb_ready			@ Compara R4 com 0x1
	bne    	leitura_kdb_desc		@ Fica no loop se diferentes
	ldr		r3, =kdb_data
	ldr		r4, [r3]				@ Se nao, carrega em R4 o valor digitado
	cmp		r4, #10					@ Compara se foi outro *
	bne		escrever2				@ Se diferente de * escreve na tela e guarda
	b		leitura_kdb_desc

	@ Exibe um asterisco na tela
escrever2:
	mov    	r0, #1  				@ stdout
	mov    	r1,	#10			 		@ Define a mensagem como *
	mov    	r2, #1					@ Define tamanho mensagem a ser escrita como 1
	mov    	r7, #4
	svc    	#0x55
	
	@ Compara se precionou '#' para encerar a chave
	cmp		r4, #11					@ compara se foi '#' 
	bne		guardar_desc			@ se for diferente salva e le outro valor
	b 		descriptografia		@ se nao vai para descriptografia
	
@ Guarda a chave na memoria	
guardar_desc:

	ldr 	r10, =chave_desc				@ coloca endereco em R10
	strb	r4, [r10, r5]			@ Armazena o valor
	add 	r5, r5, #1				@ Deslocamento
	mov 	r4, #0					@ Limpa registrador
	
	b		leitura_kdb_desc		@ Retorna a leitura da chave
	
@------------------------------------DESCRIPTOGRAFIA-----------------------------------------------
descriptografia:
	
final:	
	mov     r0, #0
	mov     r7, #1
	svc     #0x55

@------------------------------------VARIAVEIS E MENSAGENS-----------------------------------------
@onde serao armazenados os caracteres lidos
chave:
	.skip max_chave			@ Chave inicial
chave_desc:
	.skip max_chave			@ Chave descriptografia
mensagem:
	.skip max_msg			@ Mensagem digitada
msg_cripto:
	.skip max_msg_cripto	@ Mensagem criptografada

@Mensagem que serao apresentadas ao usuario
msg:		.ascii   "Digite a chave para criar a criptografia \n-no teclado numerico\n"
len = . - msg
msg2:		.ascii   "\nDigite a mensagem a ser criptografada\n"
len2 = . - msg2
msg3:		.ascii   "Digite a chave para descriptografar \n-no teclado numerico\n"
len3 = . - msg3
