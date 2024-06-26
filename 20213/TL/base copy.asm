;Trabalho de Laboratório - EMBARCADOS
; Aluno: Arthur Venturini Nascimento
; Turma: 1

segment code
..start:
    ; config padrão
    cli
    mov 	ax,data
    mov 	ds,ax
    mov 	ax,stack
    mov 	ss,ax
    mov 	sp,stacktop
    
	mov  		ah,0Fh
	int  		10h
	mov  		[modo_anterior],al   

	mov     	al,12h
	mov     	ah,0
	int     	10h



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
    MOV     [offset_dos_1], AX        ; offset_dos guarda o end. para qual ip de int 9 estava apontando anteriormente
    MOV     AX, [ES:int9*4+2]     ; cs_dos guarda o end. anterior de CS
    MOV     [cs_dos_1], AX
    CLI     
    MOV     [ES:int9*4+2], CS
    MOV     WORD [ES:int9*4],keyint
    STI
            
call msg_hora
call msg_nome
call msg_ajusta
call msg_horas_2
call msg_minutos
call msg_segundos
call msg_sair
call msg_menu
    ; loop infinito
l1:	
	cmp byte [tique], 0
    je chama_converte
    volta_converte:
    cmp byte[finalDaFlag],1
        je fim
    jmp     l1

chama_converte:
    call converte
    jmp volta_converte

fim:

	CLI
    XOR     AX, AX
    MOV     ES, AX
    MOV     AX, [cs_dos]
    MOV     [ES:intr*4+2], AX
    MOV     AX, [offset_dos]
    MOV     [ES:intr*4], AX 

    CLI
    XOR     AX, AX
    MOV     ES, AX
    MOV     AX, [cs_dos_1]
    MOV     [ES:int9*4+2], AX
    MOV     AX, [offset_dos_1]
    MOV     [ES:int9*4], AX

	mov ah,0 
	mov al,[modo_anterior] 
	int 10h
	mov ax,4c00h
	int 21h

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

        cmp byte[bx+tecla], 45   
            je fim_flag
        cmp byte[bx+tecla], 31   
            je zera_segundos
        cmp byte[bx+tecla], 50   
            je zera_minutos
        cmp byte[bx+tecla], 35  
            je zera_horas
        cmp byte[bx+tecla], 25  
            je reseta_horario
; a = 30
; s = 31

; f = 33
; b = 48
; c = 66 ?

; x sai 45 certo
; s reseta segundos 31 certo
; m reseta minutos 50 
; h reseta horas 35 certo
; p seta o horário
        jmp vaza
    fim_flag:
        mov byte[finalDaFlag],1
        jmp vaza
    zera_segundos:
        mov byte[segundo],0
        jmp vaza

    zera_minutos:
        mov byte[minuto],0
        jmp vaza

    zera_horas:
        mov byte[hora],0
        jmp vaza

    reseta_horario:
        mov byte[hora],6
        mov byte[minuto],59
        mov byte[segundo],58 

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

    call msg_rel

	pop     ds
	pop     ax
	ret 


msg_rel:
    
    push ax
    push bx
    push cx
    push dx
    mov cx,8     
    mov bx,0
    mov dh,15     
    mov dl,30     
    mov		byte[cor],branco	
    loop_msg_rel:
        call cursor
        mov al,[bx+horario]
        call  caracter
        inc bx      
        inc dl     
    loop loop_msg_rel
    pop dx 
    pop cx
    pop bx
    pop ax
    ret

msg_nome:
		
		push ax
		push bx
		push cx
		push dx
		mov cx,34      
		mov bx,0
		mov dh,1     
		mov dl,20      
		mov		byte[cor],branco_intenso	
		loop_msg_nome:
			call cursor
			mov al,[bx+cabecalho]
			call  caracter
			inc bx      
			inc dl     
		loop loop_msg_nome
		pop dx 
		pop cx
		pop bx
		pop ax
		ret
    
msg_menu:
		
		push ax
		push bx
		push cx
		push dx
		mov cx,15      
		mov bx,0
		mov dh,16   
		mov dl,30      
		mov		byte[cor],branco_intenso	
		loop_msg_menu:
			call cursor
			mov al,[bx+menu]
			call  caracter
			inc bx      
			inc dl     
		loop loop_msg_menu
		pop dx 
		pop cx
		pop bx
		pop ax
		ret

msg_sair:
		
		push ax
		push bx
		push cx
		push dx
		mov cx,7      
		mov bx,0
		mov dh,17     
		mov dl,30      
		mov		byte[cor],branco_intenso	
		loop_msg_sair:
			call cursor
			mov al,[bx+txtSair]
			call  caracter
			inc bx      
			inc dl     
		loop loop_msg_sair
		pop dx 
		pop cx
		pop bx
		pop ax
		ret

msg_segundos:
		
		push ax
		push bx
		push cx
		push dx
		mov cx,31      
		mov bx,0
		mov dh,18     
		mov dl,30      
		mov		byte[cor],branco_intenso	
		loop_msg_segundos:
			call cursor
			mov al,[bx+txtSegundos]
			call  caracter
			inc bx      
			inc dl     
		loop loop_msg_segundos
		pop dx 
		pop cx
		pop bx
		pop ax
		ret


msg_minutos:
		
		push ax
		push bx
		push cx
		push dx
		mov cx,30      
		mov bx,0
		mov dh,19     
		mov dl,30      
		mov		byte[cor],branco_intenso	
		loop_msg_minutos:
			call cursor
			mov al,[bx+txtMinutos]
			call  caracter
			inc bx      
			inc dl     
		loop loop_msg_minutos
		pop dx 
		pop cx
		pop bx
		pop ax
		ret

msg_horas_2:
		
		push ax
		push bx
		push cx
		push dx
		mov cx,28      
		mov bx,0
		mov dh,20     
		mov dl,30      
		mov		byte[cor],branco_intenso	
		loop_msg_horas_2:
			call cursor
			mov al,[bx+txtHoras]
			call  caracter
			inc bx      
			inc dl     
		loop loop_msg_horas_2
		pop dx 
		pop cx
		pop bx
		pop ax
		ret

msg_ajusta:
		
		push ax
		push bx
		push cx
		push dx
		mov cx,34      
		mov bx,0
		mov dh,21     
		mov dl,30      
		mov		byte[cor],branco_intenso	
		loop_msg_ajusta:
			call cursor
			mov al,[bx+txtAjuste]
			call  caracter
			inc bx      
			inc dl     
		loop loop_msg_ajusta
		pop dx 
		pop cx
		pop bx
		pop ax
		ret


msg_hora:
		
		push ax
		push bx
		push cx
		push dx
		mov cx,5     
		mov bx,0
		mov dh,15     
		mov dl,15      
		mov		byte[cor],branco_intenso	
		loop_msg_hora:
			call cursor
			mov al,[bx+txtHora]
			call  caracter
			inc bx      
			inc dl     
		loop loop_msg_hora
		pop dx 
		pop cx
		pop bx
		pop ax
		ret


	;***************************************************************************
	;   função cursor
	;
	; dh = linha (0-29) e  dl=coluna  (0-79)
	cursor:
			pushf
			push 		ax
			push 		bx
			push		cx
			push		dx
			push		si
			push		di
			push		bp
			mov     	ah,2
			mov     	bh,0
			int     	10h
			pop		bp
			pop		di
			pop		si
			pop		dx
			pop		cx
			pop		bx
			pop		ax
			popf
			ret
	;_____________________________________________________________________________
	;
	;   função caracter escrito na posição do cursor
	;
	; al= caracter a ser escrito
	; cor definida na variavel cor
	caracter:
			pushf
			push 		ax
			push 		bx
			push		cx
			push		dx
			push		si
			push		di
			push		bp
				mov     	ah,9
				mov     	bh,0
				mov     	cx,1
			mov     	bl,[cor]
				int     	10h
			pop		bp
			pop		di
			pop		si
			pop		dx
			pop		cx
			pop		bx
			pop		ax
			popf
			ret
	;_________________

segment data
cor		db		branco_intenso
    preto			equ		0
    azul			equ		1
    verde			equ		2
    cyan			equ		3
    vermelho		equ		4
    magenta			equ		5
    marrom			equ		6
    branco			equ		7
    cinza			equ		8
    azul_claro		equ		9
    verde_claro		equ		10
    cyan_claro		equ		11
    rosa			equ		12
    magenta_claro	equ		13
    amarelo			equ		14
    branco_intenso	equ		15

    modo_anterior	db		0
    linha   		dw  	0
    coluna  		dw  	0
    deltax			dw		0
    deltay			dw		0	

cabecalho    db      'TL - 2021/2 Aluno  Aluno Aluno 6.1'

	eoi     	EQU 20h
    intr	   	EQU 08h
	char		db	0
	offset_dos	dw	0
	cs_dos		dw	0
	tique		db  0
	segundo		db  0
	minuto 		db  0
	hora 		db  0
	horario		db  0,0,':',0,0,':',0,0
    txtHora     db  'hora',':'

	kb_data         EQU 60h  ;PORTA DE LEITURA DE TECLADO
	kb_ctl          EQU 61h  ;PORTA DE RESET PARA PEDIR NOVA INTERRUPCAO
	pictrl          EQU 20h

	int9            EQU 9h
	cs_dos_1        DW  1 ; atenção ao cs_dos, que se tornou 1 agora.
	offset_dos_1    DW 1  ; atenção ao offset_dos, que se tornou 1 agora.
	tecla           resb  8 
	p_i             dw  0   ;ponteiro p/ interrupcao (qnd pressiona tecla)  
	p_t             dw  0   ;ponterio p/ interrupcao ( qnd solta tecla)    

    finalDaFlag db 0

    menu db 'Menu de teclas',':'
    txtSair db 'x: sair'
    txtSegundos db 's: zera o contador dos segundos'
    txtMinutos db 'm: zera o contador dos minutos'
    txtHoras db 'h: zera o contador das horas'
    txtAjuste db 'p: ajusta o relogio para 06:59:59.'
    m1 db 'm1',13,10,'$'
    m2 db 'm2',13,10,'$'
    m3 db 'm3',13,10,'$'

segment stack stack
    resb 256
stacktop:
