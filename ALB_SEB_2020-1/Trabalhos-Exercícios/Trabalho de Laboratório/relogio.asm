segment code
..start:
    mov 	ax,data
    mov 	ds,ax
    mov 	ax,stack
    mov 	ss,ax
    mov 	sp,stacktop


	XOR 	AX, AX ; limpeza
    MOV 	ES, AX 					; ES = Extra Segment
    MOV     AX, [ES:intr*4]			;carregou AX com offset anterior
    MOV     [offset_dos], AX        ; offset_dos guarda o end. para qual ip de int 9 estava apontando anteriormente
    MOV     AX, [ES:intr*4+2]     	; cs_dos guarda o end. anterior de CS
    MOV     [cs_dos], AX
    CLI     						; CLI = Clear interrupt Flag (Limpa IF)
    MOV     [ES:intr*4+2], CS
    MOV     WORD [ES:intr*4],relogio; relógio é o nome da ISR !!!!!!!!!!!!!!!!!! PARTE IMPORTANTE!!!!
    STI								; STI = Set Interrupt Flag (Set 1 to IF)
	
l1:	
	cmp 	byte [tique], 0 
	jne 	ab						; Se o conteúdo de tique for diferente de zero, vai para "ab" (ab deve ser um nome qualuqer)
	call 	converte				; Se for igual, vai para "converte"

ab: mov 	ah,0bh		
    int 	21h			; Le buffer de teclado
    cmp 	al,0
    jne 	fim	
    jmp 	l1
fim:
	CLI
    XOR     AX, AX
    MOV     ES, AX
    MOV     AX, [cs_dos]
    MOV     [ES:intr*4+2], AX
    MOV     AX, [offset_dos]
    MOV     [ES:intr*4], AX 
    MOV     AH, 4Ch
    int     21h

relogio: 							; Essa daqui é a ISR, Rotina que trata da interrupção.
	push	ax
	push	ds
	mov     ax,data	
	mov     ds,ax	
    
    inc	byte [tique]
    cmp	byte[tique], 18				; 18,2Hz é a frequência do tique. Se você junta 18 tiques, você tem 1 segundo.
    jb		Fimrel

	mov byte [tique], 0				
	inc byte [segundo]
	cmp byte [segundo], 60			; Se você tem 60 segundos, você tem um minuto
	jb   	Fimrel					; Se o conteúdo de segundo for menor que 60, você vai para 'Fimrel'

	mov byte [segundo], 0
	inc byte [minuto]
	cmp byte [minuto], 60
	jb   	Fimrel

	mov byte [minuto], 0
	inc byte [hora]
	cmp byte [hora], 24
	jb   	Fimrel

	mov byte [hora], 0	
Fimrel:								; Deve ser fim do relógio
    mov		al,20h
	out		20h,al					; isso daqui tá com cara de imprimir algo na tela.
	pop		ds						; Ela programa o OCW 2
	pop		ax
	iret							; IRET = Retorno da Interrupção, serve para indicar que já acabou a interrupção
	
converte:
    push 	ax
	push    ds
	mov     ax, data
	mov     ds, ax
	xor 	ah, ah
	MOV     BL, 10
	mov 	al, byte [segundo]
    DIV     BL
    ADD     AL, 30h                                                                                          
    MOV     byte [horario+6], AL
    ADD     AH, 30h
    mov 	byte [horario+7], AH
    
	xor 	ah, ah
	mov 	al, byte [minuto]
    DIV     BL
    ADD     AL, 30h                                                                                          
    MOV     byte [horario+3], AL
    ADD     AH, 30h
    mov 	byte [horario+4], AH
	
	xor 	ah, ah
	mov 	al, byte [hora]
    DIV     BL
    ADD     AL, 30h                                                                                          
    MOV     byte [horario], AL
    ADD     AH, 30h
    mov 	byte [horario+1], AH


	mov 	ah, 09h			; Parte responsável pela a impressão do horário
	mov 	dx, horario
	int 	21h
	pop     ds
	pop     ax
	ret  

segment data
	eoi     	EQU 20h
    intr	   	EQU 08h
	char		db	0
	offset_dos	dw	0
	cs_dos		dw	0
	tique		db  0
	segundo		db  0
	minuto 		db  0
	hora 		db  0
	horario		db  0,0,':',0,0,':',0,0,' ', 13,'$'
segment stack stack
    resb 256
stacktop:
