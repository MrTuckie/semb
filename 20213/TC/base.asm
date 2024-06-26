; Nome: Yuri Rissi Negri - Turma 6.1
; Professor: Evandro
segment code
..start:
	mov 		ax,data
	mov 		ds,ax
	mov 		ax,stack
	mov 		ss,ax
	mov 		sp,stacktop

	mov  		ah,0Fh
	int  		10h
	mov  		[modo_anterior],al   

	mov     	al,12h
	mov     	ah,0
	int     	10h

; desenhando interface
call faz_interface

start:
	; se uma tecla for apertada, vai para adelante
	mov ah,0bh
	int 21h 
	cmp al,0 
		jne adelante
	jmp start 

adelante:
	; salva a variável em al
	mov ah, 08H 
	int 21H
	mov bx,0
	mov bl,byte[qntTecla]
	mov byte[new_com+bx],al ; salva a tecla em new_com
	inc byte[qntTecla] ; aumenta a quantidade de teclas apertadas
	cmp al,13 ; se al for enter
		je apertou_enter
	cmp byte[qntTecla],4
		je cmd_inval
	call msg_new_com
	call msg_debug
	call limpa_msg
	jmp start
	
	apertou_enter:
	mov bl,byte[qntTecla]
	; se tiver apertado apenas 1 tecla de enter ou 3 teclas, tá inválido
	cmp bl,1
		je cmd_inval
	cmp bl,3
		je cmd_inval
	cmp bl,2
		je analise_2
	cmp bl,4
		je analise_4

	cmd_inval:
		call msg_inval
		call troca_msg
		call limpa_cmd
		mov byte[qntTecla],0
		mov byte[new_com+0],0
		mov byte[new_com+1],0
		mov byte[new_com+2],0
		mov byte[new_com+3],0
		jmp start

	jg_inval:
		call limpa_cmd
		call troca_msg
		call msg_jg_inval
		mov byte[qntTecla],0
		mov byte[new_com+0],0
		mov byte[new_com+1],0
		mov byte[new_com+2],0
		mov byte[new_com+3],0
		jmp start

	analise_2:
		cmp byte[new_com+0],'n'
			je novo_jogo
		cmp byte[new_com+0],'s'
			je sai_ext
		jmp start
		
	analise_4:

		verifica_numero:
			; se não for apertado número na posição certa
			cmp byte[new_com+1],'1'
				jb cmd_inval
			cmp byte[new_com+1],'3'
				jg cmd_inval
			cmp byte[new_com+2],'1'
				jb cmd_inval
			cmp byte[new_com+2],'3'
				jg cmd_inval

			; salva os números
			mov cl,byte[new_com+1]
			sub cl,48
			mov byte[l_pos],cl
			mov cl,byte[new_com+2]
			sub cl,48
			mov byte[c_pos],cl

			cmp byte[new_com+0],'c'
				je cmd_valido_ext
			cmp byte[new_com+0],'q'
				je cmd_valido_ext

			; se não for nem c e nem q no início, comando inválido
			
			jmp cmd_inval

cmd_valido_ext:
jmp cmd_valido

sai_ext:
jmp sai

novo_jogo:

	mov byte[old_com],'0000'
	mov byte[new_com+0],0
	mov byte[new_com+1],0
	mov byte[new_com+2],0
	mov byte[new_com+3],0
	mov byte[qntTecla],0
	mov byte[l_pos],0
	mov byte[c_pos],0
	mov byte[table],'a'
	mov byte[table+1],'b'
	mov byte[table+2],'c'
	mov byte[table+3],'d'
	mov byte[table+4],'e'
	mov byte[table+5],'f'
	mov byte[table+6],'g'
	mov byte[table+7],'h'
	mov byte[table+8],'i'
	mov byte[table_aux],0
	mov byte[jogada],0
	mov byte[jogada_val],0
	mov byte[jogada_init],0
	mov word[ult_jogada],0
	mov ah,0   
	mov al,[modo_anterior] 
	int 10h
	jmp ..start




cmd_valido:
	call troca_msg
	cmp byte[new_com+0],'c'
			je analise_cross
	cmp byte[new_com+0],'q'
			je analise_square
	mov byte[qntTecla],0
	jmp start

; 1 indica cruz
analise_cross:
	cmp byte[jogada_init],0
		je primeira_jogada_x
	cmp byte[jogada],1
		jne primeira_jogada_x
	jmp jg_inval_ext
	primeira_jogada_x:
	call analisa_tabela
	call cross
	mov bx, word[ult_jogada]
	mov byte[table+bx],1
	call limpa_cmd
	mov byte[qntTecla],0
	call analisa_venceu_linha
	inc byte[jogada_val]
	mov byte[jogada],1
	mov byte[jogada_init],1
	jmp start

; 2 indica quadrado
analise_square:
	cmp byte[jogada_init],0
		je primeira_jogada_q
	cmp byte[jogada],2
		jne primeira_jogada_q
	jmp jg_inval_ext
	primeira_jogada_q:
	call analisa_tabela
	call square
	mov bx, word[ult_jogada]
	mov byte[table+bx],2
	call limpa_cmd
	mov byte[qntTecla],0
	call analisa_venceu_linha
	inc byte[jogada_val]
	mov byte[jogada],2
	mov byte[jogada_init],2
	jmp start


sai:
	mov ah,0 
	mov al,[modo_anterior] 
	int 10h
	mov ax,4c00h
	int 21h


faz_interface:
	call msg_materia
	call msg_nome

	call msg_11
	call msg_12
	call msg_13
	
	call msg_21
	call msg_22
	call msg_23

	call msg_31
	call msg_32
	call msg_33

	call borders
	ret

borders:
		push ax
		push bx
		push cx
		push dx
		
		mov		byte[cor],branco_intenso	

		mov		ax,0
		push	ax
		mov		ax,479
		push	ax
		mov		ax,0
		push	ax
		mov		ax,0
		push	ax
		call	line
		
		mov		ax,639
		push	ax
		mov		ax,479
		push	ax
		mov		ax,639
		push	ax
		mov		ax,0
		push	ax
		call	line

		mov		ax,639
		push	ax
		mov		ax,479
		push	ax
		mov		ax,0
		push	ax
		mov		ax,479
		push	ax
		call	line

		mov		ax,639
		push	ax
		mov		ax,0
		push	ax
		mov		ax,0
		push	ax
		mov		ax,0
		push	ax
		call	line

		; linhas do jogo da velha

		; horizontal inferior
		mov		ax,200
		push	ax
		mov		ax,160
		push	ax
		mov		ax,440
		push	ax
		mov		ax,160
		push	ax
		call	line
		; horizontal superior
		mov		ax,200
		push	ax
		mov		ax,240
		push	ax
		mov		ax,440
		push	ax
		mov		ax,240
		push	ax
		call	line
		; vertical esquerda ok 
		mov		ax,280
		push	ax
		mov		ax,320
		push	ax
		mov		ax,280
		push	ax
		mov		ax,80
		push	ax
		call	line
		; vertical direita ok
		mov		ax,360
		push	ax
		mov		ax,320
		push	ax
		mov		ax,360
		push	ax
		mov		ax,80
		push	ax
		call	line
		

		; mensagens

		; horizontal superior
		mov		ax,80
		push	ax
		mov		ax,75
		push	ax
		mov		ax,560
		push	ax
		mov		ax,75
		push	ax
		call	line
		; horizontal meio
		mov		ax,80
		push	ax
		mov		ax,37
		push	ax
		mov		ax,560
		push	ax
		mov		ax,37
		push	ax
		call	line
		; vertical esquerda ok 
		mov		ax,80
		push	ax
		mov		ax,0
		push	ax
		mov		ax,80
		push	ax
		mov		ax,75
		push	ax
		call	line
		; vertical meio ok 
		mov		ax,320
		push	ax
		mov		ax,37
		push	ax
		mov		ax,320
		push	ax
		mov		ax,75
		push	ax
		call	line
		; vertical direita ok
		mov		ax,560
		push	ax
		mov		ax,0
		push	ax
		mov		ax,560
		push	ax
		mov		ax,75
		push	ax
		call	line

		pop dx 
		pop cx
		pop bx
		pop ax
	ret

cross:
	push ax
	push dx
	mov		byte[cor],azul_claro	
	; esquerda descendo
	; x = xi + 80*c_pos
	; y = yi - 80*l_pos
	
	mov ax,0
	mov al,80
	mul byte[c_pos]
	add ax,word[xi]
	mov word[xi_f],ax

	mov ax,0
	mov al, 80
	mul byte[l_pos]
	mov dx,word[yi]
	sub dx,ax
	mov ax,dx
	mov word[yi_f],ax

	; esquerda descendo
	;mov    ax,0
	mov		ax,word[xi_f]
	push	ax
	;mov		ax,40
	mov		ax,word[yi_f]
	add 	ax,40
	push	ax
	;mov		ax,40
	mov    	ax,word[xi_f]
	add    	ax,40
	push	ax
	mov 	ax,word[yi_f]
	;sub		ax,40
	;mov		ax,0
	push	ax
	call	line
	
	; direita subindo
	;mov		ax,0
	mov		ax,word[xi_f]
	push	ax
	;mov		ax,0
	mov		ax,word[yi_f]
	push	ax
	;mov		ax,40
	mov		ax,word[xi_f]
	add ax,40
	push	ax
	;mov		ax,40
	mov		ax,word[yi_f]
	add		ax,40
	push	ax
	call	line
	mov word[xi_f],0
	mov word[yi_f],0
	pop dx
	pop ax
	ret

square:
    push    cx     
    push    ax
    push    dx
    push    bx


	mov ax,0
	mov al,80
	mul byte[c_pos]
	add ax,word[xi]
	add ax,40
	mov word[xi_f],ax
	mov word[coluna_atual], ax
	
	mov ax,0
	mov al, 80
	mul byte[l_pos]
	mov dx,word[yi]
	sub dx,ax
	mov ax,dx
	mov word[yi_f],ax
    mov word[linha_atual],ax
    

    mov cx,40
    linhas_2:
        push cx
        mov cx, 39         
    colunas_2:
        call plota_pixel    
        dec word[coluna_atual]
        cmp cx, 40
            je colunas_2_out
        loop colunas_2
        colunas_2_out:
        inc word[linha_atual]
		mov ax,word[xi_f]
        mov word[coluna_atual],ax
        pop cx
        loop linhas_2
    pop   bx
    pop   dx
    pop   ax    
    pop   cx
	ret



analisa_tabela:

	push bx
	push ax
	mov ax,0
	mov bx,0

	mov byte[table_aux],0
	cmp byte[l_pos],1
		je linha_1
	cmp byte[l_pos],2
		je linha_2
	cmp byte[l_pos],3
		je linha_3

	linha_1:
		add byte[table_aux],0
		jmp analisa_coluna
	linha_2:
		add byte[table_aux],3
		jmp analisa_coluna
	linha_3:
		add byte[table_aux],6

	analisa_coluna:
		cmp byte[c_pos],1
			je coluna_1
		cmp byte[c_pos],2
			je coluna_2
		cmp byte[c_pos],3
			je coluna_3


	coluna_1:
		add byte[table_aux],0
		jmp junta_final
	coluna_2:
		add byte[table_aux],1
		jmp junta_final
	coluna_3:
		add byte[table_aux],2

	junta_final:
		mov bl,byte[table_aux]
		cmp byte[table+bx],3 ; se já tiver jogado naquela posição
			jbe cmd_inval_ext

		mov word[ult_jogada],bx
		pop ax
		pop bx
	ret

cmd_inval_ext:
jmp cmd_inval
jg_inval_ext:
jmp jg_inval



victory:
	push ax
	push dx
	mov		byte[cor],verde	

	cmp byte[linha_venceu],1
		je linha_victoria
	cmp byte[coluna_venceu],1
		je coluna_victoria
	cmp byte[diag1_venceu],1
		je diag1_victoria
	cmp byte[diag2_venceu],1
		je diag2_victoria
	
	linha_victoria:
	sub word[y1_aux],80
	sub word[y2_aux],80
	mov word[x1_aux],120
	mov word[x2_aux],480
	jmp desenha_resto
	coluna_victoria:

	mov word[y1_aux],300
	mov word[y2_aux],120
	jmp desenha_resto

	diag1_victoria:
	mov word[x1_aux],240
	mov word[y1_aux],280
	mov word[x2_aux],400
	mov word[y2_aux],120
	jmp desenha_resto
	diag2_victoria:
	mov word[x1_aux],240
	mov word[y1_aux],120
	mov word[x2_aux],400
	mov word[y2_aux],280
	jmp desenha_resto
	desenha_resto:

	mov    	ax,word[x1_aux]
	push	ax

	mov		ax,word[y1_aux]
	push	ax

	mov		ax,word[x2_aux]
	push	ax

	mov		ax,word[y2_aux]
	push	ax

	call	line
	
	pop dx
	pop ax
	ret

venceu_ext:
jmp venceu
analisa_venceu_linha:

	push cx
	push bx
	push ax

	; analise das linhas
	mov cx,0
	mov bx,6 ; -> 6,3,0
	mov cl,3 ; -> 3,2,1
	mov word[y1_aux],120
	mov word[y2_aux],120
	l1:
		add word[y1_aux],80
		add word[y2_aux],80
		mov al,byte[table+bx+1]
		cmp byte[table+bx],al
			je dois_ig
		jmp nao_venceu_linha
		dois_ig:
	
		mov byte[linha_venceu],1
		cmp al,byte[table+bx+2]
			je venceu_ext
		nao_venceu_linha:
		mov byte[linha_venceu],0
		sub bx,3
		loop l1


	; analise das colunas
	mov bx,0
	mov cl,3
	mov word[x1_aux],160
	mov word[x2_aux],160
	c1:
		add word[x1_aux],80
		add word[x2_aux],80
		mov al,byte[table+bx+3]
		cmp byte[table+bx],al
			je dois_ig_2
		jmp nao_venceu_coluna
		dois_ig_2:
		mov byte[coluna_venceu],1
		cmp al,byte[table+bx+6]
			je venceu
		nao_venceu_coluna:
		mov byte[coluna_venceu],0
		add bx,1
		loop c1
	

	; analise diagonal esquerda direita
	mov al,byte[table+4]
	cmp byte[table],al
		je diag_ig
	jmp analise_diag_2
	diag_ig:	
	mov byte[diag1_venceu],1
	cmp al,byte[table+8]
		je venceu
	mov byte[diag1_venceu],0

	analise_diag_2:
	; analise diagonal direita esquerda
	mov byte[diag1_venceu],0
	mov word[x1_aux],240
	mov word[y1_aux],120
	mov word[x2_aux],400
	mov word[y2_aux],280
	mov al,byte[table+4]
	cmp byte[table+2],al
		je diag_ig_2
	jmp nao_venceu
	diag_ig_2:
	mov byte[diag2_venceu],1
	cmp al,byte[table+6]
		je venceu
	mov byte[diag2_venceu],0

	nao_venceu:
	cmp byte[jogada_val],9
		jne rolando
	empatou:
		call msg_empate
	rolando:

	pop ax
	pop bx
	pop cx
	ret

venceu:

cmp byte[jogada],1
	je venceu_c
cmp byte[jogada],2
	je venceu_q

venceu_c:
call msg_venceu_c
call victory
jmp start
venceu_q:
call msg_venceu_q
call victory
jmp start

troca_msg:
	push ax
	push cx
	push bx

	mov ax,0
	mov bx,0
	mov cl,byte[qntTecla]
	trc:
		mov al,byte[new_com+bx]
		cmp al,13
			jne nao_eh_enter
		sub al,13
		nao_eh_enter:
		mov byte[old_com+bx],al
		inc bx
	loop trc

	call msg_old_com

	pop bx
	pop cx
	pop ax
	ret

plota_pixel:  
    push ax
    push bx
    push dx
    mov byte[cor],vermelho   
    mov bx,[coluna_atual]
    add bx,1
    push bx       
    mov bx,[linha_atual]
    push bx       
    call plot_xy
    pop dx
    pop bx
    pop ax
	ret

msgs:
	; 11
	msg_11:
		
		push ax
		push bx
		push cx
		push dx
		mov cx,2      
		mov bx,0
		mov dh,10     
		mov dl,25      
		mov		byte[cor],amarelo	
		loop_msg_11:
			call cursor
			mov al,[bx+text_11]
			call  caracter
			inc bx      
			inc dl     
		loop loop_msg_11
		pop dx 
		pop cx
		pop bx
		pop ax
		ret

	; 12
	msg_12:
		
		push ax
		push bx
		push cx
		push dx
		mov cx,2      
		mov bx,0
		mov dh,10     
		mov dl,35      
		mov		byte[cor],amarelo	
		loop_msg_12:
			call cursor
			mov al,[bx+text_12]
			call  caracter
			inc bx      
			inc dl     
		loop loop_msg_12
		pop dx 
		pop cx
		pop bx
		pop ax
		ret

	; 13
	msg_13:
		
		push ax
		push bx
		push cx
		push dx
		mov cx,2      
		mov bx,0
		mov dh,10     
		mov dl,45      
		mov		byte[cor],amarelo	
		loop_msg_13:
			call cursor
			mov al,[bx+text_13]
			call  caracter
			inc bx      
			inc dl     
		loop loop_msg_13
		pop dx 
		pop cx
		pop bx
		pop ax
		ret


	; 21
	msg_21:
		
		push ax
		push bx
		push cx
		push dx
		mov cx,2      
		mov bx,0
		mov dh,15     
		mov dl,25      
		mov		byte[cor],amarelo	
		loop_msg_21:
			call cursor
			mov al,[bx+text_21]
			call  caracter
			inc bx      
			inc dl     
		loop loop_msg_21
		pop dx 
		pop cx
		pop bx
		pop ax
		ret

	
	; 22
	msg_22:
		
		push ax
		push bx
		push cx
		push dx
		mov cx,2      
		mov bx,0
		mov dh,15     
		mov dl,35      
		mov		byte[cor],amarelo	
		loop_msg_22:
			call cursor
			mov al,[bx+text_22]
			call  caracter
			inc bx      
			inc dl     
		loop loop_msg_22
		pop dx 
		pop cx
		pop bx
		pop ax
		ret

	
	; 23
	msg_23:
		
		push ax
		push bx
		push cx
		push dx
		mov cx,2      
		mov bx,0
		mov dh,15    
		mov dl,45      
		mov		byte[cor],amarelo	
		loop_msg_23:
			call cursor
			mov al,[bx+text_23]
			call  caracter
			inc bx      
			inc dl     
		loop loop_msg_23
		pop dx 
		pop cx
		pop bx
		pop ax
		ret

	; 31
	msg_31:
		
		push ax
		push bx
		push cx
		push dx
		mov cx,2      
		mov bx,0
		mov dh,20    
		mov dl,25      
		mov		byte[cor],amarelo	
		loop_msg_31:
			call cursor
			mov al,[bx+text_31]
			call  caracter
			inc bx      
			inc dl     
		loop loop_msg_31
		pop dx 
		pop cx
		pop bx
		pop ax
		ret

	; 32
	msg_32:
		
		push ax
		push bx
		push cx
		push dx
		mov cx,2      
		mov bx,0
		mov dh,20  
		mov dl,35      
		mov		byte[cor],amarelo	
		loop_msg_32:
			call cursor
			mov al,[bx+text_32]
			call  caracter
			inc bx      
			inc dl     
		loop loop_msg_32
		pop dx 
		pop cx
		pop bx
		pop ax
		ret

	; 33
	msg_33:
		
		push ax
		push bx
		push cx
		push dx
		mov cx,2      
		mov bx,0
		mov dh,20    
		mov dl,45      
		mov		byte[cor],amarelo	
		loop_msg_33:
			call cursor
			mov al,[bx+text_33]
			call  caracter
			inc bx      
			inc dl     
		loop loop_msg_33
		pop dx 
		pop cx
		pop bx
		pop ax
		ret

	msg_inval:
		
		push ax
		push bx
		push cx
		push dx
		mov cx,16      
		mov bx,0
		mov dh,28    
		mov dl,12      
		mov		byte[cor],branco_intenso	
		loop_msg_inval:
			call cursor
			mov al,[bx+comando_inval]
			call  caracter
			inc bx      
			inc dl     
		loop loop_msg_inval
		pop dx 
		pop cx
		pop bx
		pop ax
		ret

	msg_jg_inval:
		
		push ax
		push bx
		push cx
		push dx
		mov cx,15      
		mov bx,0
		mov dh,28    
		mov dl,12      
		mov		byte[cor],branco_intenso	
		loop_jg_inval:
			call cursor
			mov al,[bx+jogada_inval]
			call  caracter
			inc bx      
			inc dl     
		loop loop_jg_inval
		pop dx 
		pop cx
		pop bx
		pop ax
		ret

	msg_empate:
		
		push ax
		push bx
		push cx
		push dx
		mov cx,7      
		mov bx,0
		mov dh,28    
		mov dl,12       
		mov		byte[cor],branco_intenso	
		loop_msg_empate:
			call cursor
			mov al,[bx+empate]
			call  caracter
			inc bx      
			inc dl     
		loop loop_msg_empate
		pop dx 
		pop cx
		pop bx
		pop ax
		ret

	msg_venceu_c:
		
		push ax
		push bx
		push cx
		push dx
		mov cx,16      
		mov bx,0
		mov dh,28    
		mov dl,12       
		mov		byte[cor],branco_intenso	
		loop_msg_venceu_c:
			call cursor
			mov al,[bx+jogadorx]
			call  caracter
			inc bx      
			inc dl     
		loop loop_msg_venceu_c
		pop dx 
		pop cx
		pop bx
		pop ax
		ret

	msg_venceu_q:
		
		push ax
		push bx
		push cx
		push dx
		mov cx,16      
		mov bx,0
		mov dh,28    
		mov dl,12       
		mov		byte[cor],branco_intenso	
		loop_msg_venceu_q:
			call cursor
			mov al,[bx+jogadorq]
			call  caracter
			inc bx      
			inc dl     
		loop loop_msg_venceu_q
		pop dx 
		pop cx
		pop bx
		pop ax
		ret

	msg_debug:
		push ax
		push bx
		push cx
		push dx
		mov cl,9    
		mov bx,0
		mov dh,2     
		mov dl,2      
		mov		byte[cor],branco_intenso	
		loop_msg_debug:
			call cursor
			mov al,[bx+table]
			add al,48
			call  caracter
			inc bx      
			inc dl     
		loop loop_msg_debug
		pop dx 
		pop cx
		pop bx
		pop ax
		ret


	msg_new_com:
		push ax
		push bx
		push cx
		push dx
		mov cl,byte[qntTecla]      
		mov bx,0
		mov dh,26     
		mov dl,12      
		mov		byte[cor],branco_intenso	
		loop_msg_new_com:
			call cursor
			mov al,[bx+new_com]
			call  caracter
			inc bx      
			inc dl     
		loop loop_msg_new_com
		pop dx 
		pop cx
		pop bx
		pop ax
		ret

	msg_old_com:
		push ax
		push bx
		push cx
		push dx
		mov cl,byte[qntTecla]      
		mov bx,0
		mov dh,26     
		mov dl,48      
		mov		byte[cor],branco_intenso	
		loop_msg_old_com:
			call cursor
			mov al,[bx+old_com]
			call  caracter
			inc bx      
			inc dl     
		loop loop_msg_old_com
		pop dx 
		pop cx
		pop bx
		pop ax
		ret

	; desenha a parte de nomes e placares
	msg_materia:

		push ax
		push bx
		push cx
		push dx
		mov cx,9   
		mov bx,0
		mov dh,1    
		mov dl,25      
		mov		byte[cor],branco_intenso	
		loop_msg_materia:
			call cursor
			mov al,[bx+materia]
			call  caracter
			inc bx      
			inc dl     
		loop loop_msg_materia
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
		mov cx,16      
		mov bx,0
		mov dh,1     
		mov dl,35      
		mov		byte[cor],branco_intenso	
		loop_msg_nome:
			call cursor
			mov al,[bx+nome]
			call  caracter
			inc bx      
			inc dl     
		loop loop_msg_nome
		pop dx 
		pop cx
		pop bx
		pop ax
		ret

	limpa_cmd:
		
		push ax
		push bx
		push cx
		push dx
		mov cx,4      
		mov bx,0
		mov dh,26     
		mov dl,12       
		mov		byte[cor],branco_intenso	
		loop_limpa_cmd:
			call cursor
			mov al,[bx+cls_cmd]
			call  caracter
			inc bx      
			inc dl     
		loop loop_limpa_cmd
		pop dx 
		pop cx
		pop bx
		pop ax
		ret

	limpa_msg:
	
		push ax
		push bx
		push cx
		push dx
		mov cx,17      
		mov bx,0
		mov dh,28    
		mov dl,12      
		mov		byte[cor],branco_intenso	
		loop_limpa_msg:
			call cursor
			mov al,[bx+cls_cmd]
			call  caracter
			inc bx      
			inc dl     
		loop loop_limpa_msg
		pop dx 
		pop cx
		pop bx
		pop ax
		ret


linec:

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
	;_____________________________________________________________________________
	;
	;   função plot_xy
	;
	; push x; push y; call plot_xy;  (x<639, y<479)
	; cor definida na variavel cor
	plot_xy:
			push		bp
			mov		bp,sp
			pushf
			push 		ax
			push 		bx
			push		cx
			push		dx
			push		si
			push		di
			mov     	ah,0ch
			mov     	al,[cor]
			mov     	bh,0
			mov     	dx,479
			sub		dx,[bp+4]
			mov     	cx,[bp+6]
			int     	10h
			pop		di
			pop		si
			pop		dx
			pop		cx
			pop		bx
			pop		ax
			popf
			pop		bp
			ret		4
	;_____________________________________________________________________________
	;    função circle
	;	 push xc; push yc; push r; call circle;  (xc+r<639,yc+r<479)e(xc-r>0,yc-r>0)
	; cor definida na variavel cor
	circle:
		push 	bp
		mov	 	bp,sp
		pushf                        ;coloca os flags na pilha
		push 	ax
		push 	bx
		push	cx
		push	dx
		push	si
		push	di
		
		mov		ax,[bp+8]    ; resgata xc
		mov		bx,[bp+6]    ; resgata yc
		mov		cx,[bp+4]    ; resgata r
		
		mov 	dx,bx	
		add		dx,cx       ;ponto extremo superior
		push    ax			
		push	dx
		call plot_xy
		
		mov		dx,bx
		sub		dx,cx       ;ponto extremo inferior
		push    ax			
		push	dx
		call plot_xy
		
		mov 	dx,ax	
		add		dx,cx       ;ponto extremo direita
		push    dx			
		push	bx
		call plot_xy
		
		mov		dx,ax
		sub		dx,cx       ;ponto extremo esquerda
		push    dx			
		push	bx
		call plot_xy
			
		mov		di,cx
		sub		di,1	 ;di=r-1
		mov		dx,0  	;dx será a variável x. cx é a variavel y
		
	;aqui em cima a lógica foi invertida, 1-r => r-1
	;e as comparações passaram a ser jl => jg, assim garante 
	;valores positivos para d

	stay:				;loop
		mov		si,di
		cmp		si,0
		jg		inf       ;caso d for menor que 0, seleciona pixel superior (não  salta)
		mov		si,dx		;o jl é importante porque trata-se de conta com sinal
		sal		si,1		;multiplica por doi (shift arithmetic 0)
		add		si,3
		add		di,si     ;nesse ponto d=d+2*dx+3
		inc		dx		;incrementa dx
		jmp		plotar
	inf:	
		mov		si,dx
		sub		si,cx  		;faz x - y (dx-cx), e salva em di 
		sal		si,1
		add		si,5
		add		di,si		;nesse ponto d=d+2*(dx-cx)+5
		inc		dx		;incrementa x (dx)
		dec		cx		;decrementa y (cx)
		
	plotar:	
		mov		si,dx
		add		si,ax
		push    si			;coloca a abcisa x+xc na pilha
		mov		si,cx
		add		si,bx
		push    si			;coloca a ordenada y+yc na pilha
		call plot_xy		;toma conta do segundo octante
		mov		si,ax
		add		si,dx
		push    si			;coloca a abcisa xc+x na pilha
		mov		si,bx
		sub		si,cx
		push    si			;coloca a ordenada yc-y na pilha
		call plot_xy		;toma conta do sétimo octante
		mov		si,ax
		add		si,cx
		push    si			;coloca a abcisa xc+y na pilha
		mov		si,bx
		add		si,dx
		push    si			;coloca a ordenada yc+x na pilha
		call plot_xy		;toma conta do segundo octante
		mov		si,ax
		add		si,cx
		push    si			;coloca a abcisa xc+y na pilha
		mov		si,bx
		sub		si,dx
		push    si			;coloca a ordenada yc-x na pilha
		call plot_xy		;toma conta do oitavo octante
		mov		si,ax
		sub		si,dx
		push    si			;coloca a abcisa xc-x na pilha
		mov		si,bx
		add		si,cx
		push    si			;coloca a ordenada yc+y na pilha
		call plot_xy		;toma conta do terceiro octante
		mov		si,ax
		sub		si,dx
		push    si			;coloca a abcisa xc-x na pilha
		mov		si,bx
		sub		si,cx
		push    si			;coloca a ordenada yc-y na pilha
		call plot_xy		;toma conta do sexto octante
		mov		si,ax
		sub		si,cx
		push    si			;coloca a abcisa xc-y na pilha
		mov		si,bx
		sub		si,dx
		push    si			;coloca a ordenada yc-x na pilha
		call plot_xy		;toma conta do quinto octante
		mov		si,ax
		sub		si,cx
		push    si			;coloca a abcisa xc-y na pilha
		mov		si,bx
		add		si,dx
		push    si			;coloca a ordenada yc-x na pilha
		call plot_xy		;toma conta do quarto octante
		
		cmp		cx,dx
		jb		fim_circle  ;se cx (y) está abaixo de dx (x), termina     
		jmp		stay		;se cx (y) está acima de dx (x), continua no loop
		
		
	fim_circle:
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		pop		bp
		ret		6
	;-----------------------------------------------------------------------------
	;    função full_circle
	;	 push xc; push yc; push r; call full_circle;  (xc+r<639,yc+r<479)e(xc-r>0,yc-r>0)
	; cor definida na variavel cor					  
	full_circle:
		push 	bp
		mov	 	bp,sp
		pushf                        ;coloca os flags na pilha
		push 	ax
		push 	bx
		push	cx
		push	dx
		push	si
		push	di

		mov		ax,[bp+8]    ; resgata xc
		mov		bx,[bp+6]    ; resgata yc
		mov		cx,[bp+4]    ; resgata r
		
		mov		si,bx
		sub		si,cx
		push    ax			;coloca xc na pilha			
		push	si			;coloca yc-r na pilha
		mov		si,bx
		add		si,cx
		push	ax		;coloca xc na pilha
		push	si		;coloca yc+r na pilha
		call line
		
			
		mov		di,cx
		sub		di,1	 ;di=r-1
		mov		dx,0  	;dx será a variável x. cx é a variavel y
		
	;aqui em cima a lógica foi invertida, 1-r => r-1
	;e as comparações passaram a ser jl => jg, assim garante 
	;valores positivos para d

	stay_full:				;loop
		mov		si,di
		cmp		si,0
		jg		inf_full       ;caso d for menor que 0, seleciona pixel superior (não  salta)
		mov		si,dx		;o jl é importante porque trata-se de conta com sinal
		sal		si,1		;multiplica por doi (shift arithmetic 0)
		add		si,3
		add		di,si     ;nesse ponto d=d+2*dx+3
		inc		dx		;incrementa dx
		jmp		plotar_full
	inf_full:	
		mov		si,dx
		sub		si,cx  		;faz x - y (dx-cx), e salva em di 
		sal		si,1
		add		si,5
		add		di,si		;nesse ponto d=d+2*(dx-cx)+5
		inc		dx		;incrementa x (dx)
		dec		cx		;decrementa y (cx)
		
	plotar_full:	
		mov		si,ax
		add		si,cx
		push	si		;coloca a abcisa y+xc na pilha			
		mov		si,bx
		sub		si,dx
		push    si		;coloca a ordenada yc-x na pilha
		mov		si,ax
		add		si,cx
		push	si		;coloca a abcisa y+xc na pilha	
		mov		si,bx
		add		si,dx
		push    si		;coloca a ordenada yc+x na pilha	
		call 	line
		
		mov		si,ax
		add		si,dx
		push	si		;coloca a abcisa xc+x na pilha			
		mov		si,bx
		sub		si,cx
		push    si		;coloca a ordenada yc-y na pilha
		mov		si,ax
		add		si,dx
		push	si		;coloca a abcisa xc+x na pilha	
		mov		si,bx
		add		si,cx
		push    si		;coloca a ordenada yc+y na pilha	
		call	line
		
		mov		si,ax
		sub		si,dx
		push	si		;coloca a abcisa xc-x na pilha			
		mov		si,bx
		sub		si,cx
		push    si		;coloca a ordenada yc-y na pilha
		mov		si,ax
		sub		si,dx
		push	si		;coloca a abcisa xc-x na pilha	
		mov		si,bx
		add		si,cx
		push    si		;coloca a ordenada yc+y na pilha	
		call	line
		
		mov		si,ax
		sub		si,cx
		push	si		;coloca a abcisa xc-y na pilha			
		mov		si,bx
		sub		si,dx
		push    si		;coloca a ordenada yc-x na pilha
		mov		si,ax
		sub		si,cx
		push	si		;coloca a abcisa xc-y na pilha	
		mov		si,bx
		add		si,dx
		push    si		;coloca a ordenada yc+x na pilha	
		call	line
		
		cmp		cx,dx
		jb		fim_full_circle  ;se cx (y) está abaixo de dx (x), termina     
		jmp		stay_full		;se cx (y) está acima de dx (x), continua no loop
		
		
	fim_full_circle:
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		pop		bp
		ret		6
	;-----------------------------------------------------------------------------
	;
	;   função line
	;
	; push x1; push y1; push x2; push y2; call line;  (x<639, y<479)
	line:
			push		bp
			mov		bp,sp
			pushf                        ;coloca os flags na pilha
			push 		ax
			push 		bx
			push		cx
			push		dx
			push		si
			push		di
			mov		ax,[bp+10]   ; resgata os valores das coordenadas
			mov		bx,[bp+8]    ; resgata os valores das coordenadas
			mov		cx,[bp+6]    ; resgata os valores das coordenadas
			mov		dx,[bp+4]    ; resgata os valores das coordenadas
			cmp		ax,cx
			je		line2
			jb		line1
			xchg		ax,cx
			xchg		bx,dx
			jmp		line1
	line2:		; deltax=0
			cmp		bx,dx  ;subtrai dx de bx
			jb		line3
			xchg		bx,dx        ;troca os valores de bx e dx entre eles
	line3:	; dx > bx
			push		ax
			push		bx
			call 		plot_xy
			cmp		bx,dx
			jne		line31
			jmp		fim_line
	line31:		inc		bx
			jmp		line3
	;deltax <>0
	line1:
	; comparar módulos de deltax e deltay sabendo que cx>ax
		; cx > ax
			push		cx
			sub		cx,ax
			mov		[deltax],cx
			pop		cx
			push		dx
			sub		dx,bx
			ja		line32
			neg		dx
	line32:		
			mov		[deltay],dx
			pop		dx

			push		ax
			mov		ax,[deltax]
			cmp		ax,[deltay]
			pop		ax
			jb		line5

		; cx > ax e deltax>deltay
			push		cx
			sub		cx,ax
			mov		[deltax],cx
			pop		cx
			push		dx
			sub		dx,bx
			mov		[deltay],dx
			pop		dx

			mov		si,ax
	line4:
			push		ax
			push		dx
			push		si
			sub		si,ax	;(x-x1)
			mov		ax,[deltay]
			imul		si
			mov		si,[deltax]		;arredondar
			shr		si,1
	; se numerador (DX)>0 soma se <0 subtrai
			cmp		dx,0
			jl		ar1
			add		ax,si
			adc		dx,0
			jmp		arc1
	ar1:		sub		ax,si
			sbb		dx,0
	arc1:
			idiv		word [deltax]
			add		ax,bx
			pop		si
			push		si
			push		ax
			call		plot_xy
			pop		dx
			pop		ax
			cmp		si,cx
			je		fim_line
			inc		si
			jmp		line4

	line5:		cmp		bx,dx
			jb 		line7
			xchg		ax,cx
			xchg		bx,dx
	line7:
			push		cx
			sub		cx,ax
			mov		[deltax],cx
			pop		cx
			push		dx
			sub		dx,bx
			mov		[deltay],dx
			pop		dx



			mov		si,bx
	line6:
			push		dx
			push		si
			push		ax
			sub		si,bx	;(y-y1)
			mov		ax,[deltax]
			imul		si
			mov		si,[deltay]		;arredondar
			shr		si,1
	; se numerador (DX)>0 soma se <0 subtrai
			cmp		dx,0
			jl		ar2
			add		ax,si
			adc		dx,0
			jmp		arc2
	ar2:		sub		ax,si
			sbb		dx,0
	arc2:
			idiv		word [deltay]
			mov		di,ax
			pop		ax
			add		di,ax
			pop		si
			push		di
			push		si
			call		plot_xy
			pop		dx
			cmp		si,dx
			je		fim_line
			inc		si
			jmp		line6

	fim_line:
			pop		di
			pop		si
			pop		dx
			pop		cx
			pop		bx
			pop		ax
			popf
			pop		bp
			ret		8
	;*******************************************************************
segment data

cor		db		branco_intenso

;	I R G B COR
;	0 0 0 0 preto
;	0 0 0 1 azul
;	0 0 1 0 verde
;	0 0 1 1 cyan
;	0 1 0 0 vermelho
;	0 1 0 1 magenta
;	0 1 1 0 marrom
;	0 1 1 1 branco
;	1 0 0 0 cinza
;	1 0 0 1 azul claro
;	1 0 1 0 verde claro
;	1 0 1 1 cyan claro
;	1 1 0 0 rosa
;	1 1 0 1 magenta claro
;	1 1 1 0 amarelo
;	1 1 1 1 branco intenso

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

materia          db      'TC-2021/2'
nome             db      'Yuri Rissi Negri'
turma            db      ' 6.1'

text_11			db		'11'
text_12			db		'12'
text_13			db		'13'

text_21			db		'21'
text_22			db		'22'
text_23			db		'23'

text_31			db		'31'
text_32			db		'32'
text_33			db		'33'

old_com			db		'0000'
new_com			db		0,0,0,0
cls_cmd			db		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
qntTecla		db		0
l_pos			db		0
c_pos			db		0
table			db		'abcdefghi'
table_aux		db		0
xi				dw		140
yi				dw		340
xi_f			dw		0
yi_f			dw		0

x1_aux			dw		0
x2_aux			dw		0
y1_aux			dw		0
y2_aux			dw		0

linha_venceu	db		0
coluna_venceu	db		0
diag1_venceu    db		0
diag2_venceu	db		0
ult_jogada		db		0

jogada			db		0
jogada_val      db		0
jogada_init		db		0
comando_inval	db		'Comando Invalido'
jogada_inval	db		'Jogada Invalida'
jogadorx		db		'Jogador X ganhou'
jogadorq		db		'Jogador Q ganhou'
empate			db		'Empatou' 

linha_atual   	dw    	0
coluna_atual  	dw    	0

segment stack stack
    		resb 		512
stacktop:
