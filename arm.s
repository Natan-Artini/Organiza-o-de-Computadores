@ Programa para leitura de uma chave e de uma mensagem
@ Atraves da chave é criada uma criptografia para a mensagem
@ Apos é pedido a chave para descriptografia da mensagem
@ Se a chave for a mesma que digitada no inicio a mensagem aparecera
@ Caso contrario aparecera caracteres aleatorios
 
	.global _start      @ ligador necessita deste rótulo
	
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
	
leitura_kdb:
	ldr		r3, =kdb_status
	ldr		r4, [r3]				@ Carrega no R4 o valor de R3
	cmp     r4, #kdb_ready			@ Compara R4 com 0x1
	bne    	leitura_kdb				@ Fica no loop se diferentes
	ldr		r3, =kdb_data			@ Se nao, carrega em R3 o valor digitado
	ldr		r4, [r3]

	@AINDA NAO DEU BOA TA TUDO ERRADO
	@ Compara se ja precionou '*' para iniciar a chave
	ldr		r5, =digito_um			@ carega digito_um, flag se iniciou chave
	cmp		r5, #0					@ compara se é 0
	bne		comparar				@ se nao, ja foi digitado o * entao vai para o comparar
	cmp		r4, #10					@ compara se é *
	bne		leitura_kdb				@ se nao for * volta pra leitura
	add		r5, r5, #1				@ se sim add 1
	str 	r5, digito_um			@ guarda na memoria
	
	@ Exibe um asterisco na tela
	mov    	r0, #1  				@ stdout
	mov    	r1,	#10			 		@ Define a mensagem como *
	mov    	r2, #1					@ Define tamanho mensagem a ser escrita como 1
	mov    	r7, #4
	svc    	#0x55
	
	@ Compara se precionou '#' para encerar a chave
comparar:
	cmp		r4, #11				@ compara se foi '#' 
	bne		guardar_chave			@ se for diferente salva e le outro valor
	b 		descriptografia			@ se nao vai para descriptografia
	
@ Guarda a chave na memoria	
guardar_chave:

	ldr 	r10, =chave				@ coloca endereco em R10
	strb	r4, [r10, r5]			@ Armazena o valor
	add 	r5, r5, #1				@ Deslocamento
	mov 	r4, #0					@ Limpa registrador
	
	b		leitura_kdb				@ Retorna a leitura da chave
	
descriptografia:	
	
  @CRIAR DESCRIPTOGRAFIA
  
	@Escreve a mensagem pedindo para digitar a mensagem
	mov     r0, #1      		@ fd -> stdout
	ldr     r1, =msg2   		@ buf -> msg2
	ldr     r2, =len2   		@ count -> len2(msg2)
	mov     r7, #4      		@ write é syscall #4
	svc     0x055       		@ executa syscall 

	
	
final:	
	mov     r0, #0
	mov     r7, #1
	svc     #0x55
	
@onde serao armazenados os caracteres lidos
chave:
	.skip max_chave			@ Chave inicial
chave_des:
	.skip max_chave			@ Chave descriptografia
mensagem:
	.skip max_msg			@ Mensagem digitada
msg_cripto:
	.skip max_msg_cripto	@ Mensagem criptografada
digito_um:
	.byte 0x0				@ Flag de leitura

@Mensagem que serao apresentadas ao usuario
msg:		.ascii   "Digite a chave para criar a criptografia\n"
len = . - msg
msg2:		.ascii   "Digite a mensagem a ser criptografada\n"
len2 = . - msg2
msg3:		.ascii   "Digite a chave para descriptografar\n"
len3 = . - msg3
