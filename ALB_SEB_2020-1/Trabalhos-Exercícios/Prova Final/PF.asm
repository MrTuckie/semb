segment code
..start:
    ; config padrão
    cli
    mov 	ax,data
    mov 	ds,ax
    mov 	ax,stack
    mov 	ss,ax
    mov 	sp,stacktop
    
    ; relogio
	XOR 	AX, AX
    MOV 	ES, AX
    MOV     AX, [ES:intr*4];carregou AX com offset anterior
    MOV     [offset_dos], AX        ; offset_dos guarda o end. para qual ip de int 9 estava apontando anteriormente
    MOV     AX, [ES:intr*4+2]     ; cs_dos guarda o end. anterior de CS
    MOV     [cs_dos], AX    
    MOV     [ES:intr*4+2], CS
    MOV     WORD [ES:intr*4],relogio
    STI

    ;keyint
    XOR     AX, AX
    MOV     ES, AX
    MOV     AX, [ES:int9*4];carregou AX com offset anterior
    MOV     [offset_dos], AX        ; offset_dos guarda o end. para qual ip de int 9 estava apontando anteriormente
    MOV     AX, [ES:int9*4+2]     ; cs_dos guarda o end. anterior de CS
    MOV     [cs_dos], AX
    CLI     
    MOV     [ES:int9*4+2], CS
    MOV     WORD [ES:int9*4],keyint
    STI
            
	
    ; loop infinito
l1:	
	cmp 	byte [tique], 0
	call 	converte
    jmp     l1

fim:

	CLI
    XOR     AX, AX
    MOV     ES, AX
    MOV     AX, [cs_dos]
    MOV     [ES:intr*4+2], AX
    MOV     AX, [offset_dos]
    MOV     [ES:intr*4], AX 
	sti

    CLI
    XOR     AX, AX
    MOV     ES, AX
    MOV     AX, [cs_dos]
    MOV     [ES:int9*4+2], AX
    MOV     AX, [offset_dos]
    MOV     [ES:int9*4], AX

    ; devo eu tentar fazer alguma outra limpeza de interrupção aqui?

    MOV     AH, 4Ch
    int     21h

relogio:
	push	ax
	push	ds
	mov     ax,data	
	mov     ds,ax	
    
    inc	byte [tique]
    cmp	byte[tique], 18	
    jb		Fimrel
	mov byte [tique], 0
	inc byte [segundo]
	cmp byte [segundo], 60
	jb   	Fimrel
	mov byte [segundo], 0
	inc byte [minuto]
	cmp byte [minuto], 60
	jb   	Fimrel
	mov byte [minuto], 0
	inc byte [hora]
	cmp byte [hora], 24
	jb   	Fimrel
	mov byte [hora], 0	
Fimrel:
    mov		al,20h
	out		20h,al
	pop		ds
	pop		ax
	iret
	

keyint:
        ; push regs
        PUSH    AX
        push    bx
        push    ds

        mov     ax,data
        mov     ds,ax
        IN      AL, kb_data ;PORTA DE LEITURA DE TECLADO
        inc     WORD [p_i]
        and     WORD [p_i],7
        mov     bx,[p_i]
        mov     [bx+tecla],al ; tecla deve ser o cara para ser comparado





        cmp byte[bx+tecla], 1
        jne teste
        jmp fim
    teste:
        cmp byte[bx+tecla], 2
        je zeras

        cmp byte[bx+tecla], 3
        je zeram

        cmp byte[bx+tecla], 4
        je zerah

        jmp vaza

zeras:
        mov byte[segundo],0
        jmp vaza

zeram:
        mov byte[minuto],0
        jmp vaza

zerah:
        mov byte[hora],0
        jmp vaza

vaza:

        IN      AL, kb_ctl ;PORTA DE RESET PARA PEDIR NOVA INTERRUPCAO
        OR      AL, 80h 
        OUT     kb_ctl, AL
        AND     AL, 7Fh
        OUT     kb_ctl, AL
        MOV     AL, eoi
        OUT     pictrl, AL
        ; pop regs
        pop     ds
        pop     bx
        POP     AX
        
		IRET


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
	mov 	ah, 09h
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
	minuto 		db  34
	hora 		db  12
	horario		db  0,0,':',0,0,':',0,0,' ', 13,'$'

	kb_data EQU 60h  ;PORTA DE LEITURA DE TECLADO
	kb_ctl  EQU 61h  ;PORTA DE RESET PARA PEDIR NOVA INTERRUPCAO
	pictrl  EQU 20h

	int9    EQU 9h
	;cs_dos  DW  1 ; atenção ao cs_dos, que se tornou 1 agora.
	;offset_dos  DW 1  ; atenção ao offset_dos, que se tornou 1 agora.
	tecla_u db 0
	tecla   resb  8 
	p_i     dw  0   ;ponteiro p/ interrupcao (qnd pressiona tecla)  
	p_t     dw  0   ;ponterio p/ interrupcao ( qnd solta tecla)    
	teclasc DB  0,0,13,10,'$'

    m1 db 'm1',13,10,'$'
    m2 db 'm2',13,10,'$'
    m3 db 'm3',13,10,'$'

segment stack stack
    resb 256
stacktop:
