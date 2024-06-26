	;***************************************************************
	;
	; Departamento de Engenharia Elétrica - UFES
	; Sistemas Embarcados I - 2018/2
	;
	;***************************************************************
	; EXERCÍCIO DE PROGRAMAÇÃO
	;
	; Aluno: Bruno Novelli Bonela
	;
	; Última Modificação: 29/10/2018
	; Versão: 0.0.10
	; Detalhamento de versão: Filtro terminado
	;
	;***************************************************************
	; Objetivos: Deseja-se filtrar um sinal digital, lido de um arquivo texto, aplicando-se filtro de Kalman.
	; O Filtro de Kalman é um filtro estocástico que é capaz de tratar sinais não estacionários.
	;
	;***************************************************************
	;                                                              ;
	; 				  INICIALIZAÇÃO DO PROGRAMA                    ;
	;															   ;
	;***************************************************************
	
		segment code
		..start:
			  
		mov ax,data
		mov ds,ax
		mov ax,stack
		mov ss,ax
		mov sp,stacktop

		;Salva modo corrente de vídeo
		mov ah,0Fh                            
		int 10h
		mov [modo_anterior],al   

		;Altera modo de vídeo para gráfico 640x480 16 cores
		mov al,12h                           
		mov ah,0
		int 10h
		  
		;Inicialização da interface gráfica do programa
		mov byte[cor],branco_intenso ; Inicialmente, tudo branco
		call faz_interface

		xor 	ax, ax
		mov 	es, ax
		mov     ax, [es:intr*4];carregou AX com offset anterior
		mov     [offset_dos], ax        ; offset_dos guarda o end. para qual ip de int 9 estava apontando anteriormente
		mov     ax, [ES:intr*4+2]     ; cs_dos guarda o end. anterior de CS
		mov     [cs_dos], ax    
		mov     [es:intr*4+2], cs
		mov     word[ES:intr*4],relogio
		sti

		jmp inicializa_mouse

	;***************************************************************
	;															   ;
	;    			    INICIALIZAÇÃO DO RELOGIO				   ;
	;															   ;
	;***************************************************************	

		relogio:
			push	ax
			push	ds
			mov     ax,data	
			mov     ds,ax	
		    
			mov byte[tique], 0

			Fimrel:
		    mov		al,20h
			out		20h,al
			pop		ds
			pop		ax
			iret

	;***************************************************************
	;															   ;
	; 					INICIALIZAÇÃO DO MOUSE					   ;
	;															   ;
	;***************************************************************
	
		inicializa_mouse:
			mov ax,0
			int 33h
			mov ax,1
			int 33h 
	  
	;***************************************************************
	;                                                              ;
	; 				   DETECÇÃO DO CLIQUE DO MOUSE                 ;
	;                                                              ;
	;***************************************************************
	
		checa_clique:
			; Chamada da int 33h para saber onde houve clique do mouse 
			mov ax,5              
			mov bx,0
			int 33h               
			; cx <- posição horizontal do último clique
			; dx <- posição vertical do último clique
			; bx <- # de cliques
			; Se bx for zero, não houve clique, deve retornar
			cmp bx,0              
			jne trata_clique
			jmp checa_clique

	;***************************************************************
	;                                                              ;
	; 				  TRATAMENTO DO CLIQUE DO MOUSE                ;
	;                                                              ;
	;***************************************************************	
		
		;pois (0,0) está na posição superior esquerda
		trata_clique:
			;verificando se o clique foi na parte de incrementar ou decrementar, x<64
			cmp   cx, 64                                  
				jb    localiza_clique_1
			;verificando se o clique foi na parte do menu, x<190
			cmp   cx, 190                                    
				jb    localiza_clique_2
			jmp   checa_clique
		  
	;***************************************************************
	;                                                              ;
	; 				LOCALIZAÇÃO DO CLIQUE DO MOUSE                 ;
	;                                                              ;
	;***************************************************************
		
		; Extendendo a localidade do metodo checa_clique
		checa_clique_2:
			jmp checa_clique
		
		; Uma vez que o clique foi no menu, localiza-se 
		; qual botão foi selecionado
		
		localiza_clique_1:
			; Se o valor de y for <80, o botão clicado foi o de abrir
			cmp dx,80
				jb botao_abrir
			; Se o valor de y for >80 e <160, o botão clicado foi o de executar
			cmp dx,160
				jb botao_executar
			; Se o valor de y for >160 e <200 e x<64, o botão clicado foi o de incrementar Qw
			cmp dx,200
				jb botao_qw_inc_1
			; Se o valor de y for >200 e <240 e x<64, o botão clicado foi o de decremenar Qw
			cmp dx,240
				jb botao_qw_dec_1
			; Se o valor de y for >240 e <280 e x<64, o botão clicado foi o de incrementar P
			cmp dx,280
				jb botao_p_inc_1
			; Se o valor de y for >280 e <320 e x<64, o botão clicado foi o de decrementar P
			cmp dx,320
				jb botao_p_dec_1
			; Se o valor de y for >320 e <360 e x<64, o botão clicado foi o de incrementar Qv
			cmp dx,360
				jb botao_qv_inc_1
			; Se o valor de y for >360 e <400 e x<64, o botão clicado foi o de decrementar Qv
			cmp dx,400
				jb botao_qv_dec_1
			; Se o valor de y for >400, o botão clicado foi o de sair	
			cmp dx,480
				jb botao_sair
			jmp checa_clique
		
		localiza_clique_2:
			; Se o valor de y for <80, o botão clicado foi o de abrir
			cmp dx,80
				jb botao_abrir
			; Se o valor de y for >80 e <160, o botão clicado foi o de executar
			cmp dx,160
				jb botao_executar
			; Se o valor de y for >160 e <200 e x<64, o botão clicado foi o de incrementar Qw
			cmp dx,200
				jb checa_clique_2
			; Se o valor de y for >200 e <240 e x<64, o botão clicado foi o de decremenar Qw
			cmp dx,240
				jb checa_clique_2
			; Se o valor de y for >240 e <280 e x<64, o botão clicado foi o de incrementar P
			cmp dx,280
				jb checa_clique_2
			; Se o valor de y for >280 e <320 e x<64, o botão clicado foi o de decrementar P
			cmp dx,320
				jb checa_clique_2
			; Se o valor de y for >320 e <360 e x<64, o botão clicado foi o de incrementar Qv
			cmp dx,360
				jb checa_clique_2
			; Se o valor de y for >360 e <400 e x<64, o botão clicado foi o de decrementar Qv
			cmp dx,400
				jb checa_clique_2
			; Se o valor de y for >400, o botão clicado foi o de sair	
			cmp dx,480
				jb botao_sair
			jmp checa_clique_2
		  
		; Extendendo a localidade dos metodos dos botoes
		botao_abrir:
			jmp botao_abrir_2	
		botao_executar:
			jmp botao_executar_2
		botao_qw_inc_1:
			jmp botao_qw_inc
		botao_qw_dec_1:
			jmp botao_qw_dec
		botao_p_inc_1:
			jmp botao_p_inc
		botao_p_dec_1:
			jmp botao_p_dec
		botao_qv_inc_1:
			jmp botao_qv_inc
		botao_qv_dec_1:
			jmp botao_qv_dec	
		botao_sair:
			jmp botao_sair_2
	  
		;Deseja-se abrir o arquivo de dados:
		botao_abrir_2:
			; Muda a cor da mensagem 'abrir' para verde
			mov byte[cor],verde
			call msg_abrir
			mov byte[cor],preto
			call msg_parametros			
			call msg_saturou_qv
			call msg_saturou_qv_2
			call msg_saturou_qw
			call msg_saturou_qw_2
			call msg_saturou_p			
			call msg_saturou_p_2
			call msg_arquivo_aberto			
			mov byte[cor],branco_intenso
			call msg_abrindo_arquivo
			; Mantém a mensagem das outras funções em branco			
			call msg_executar
			call msg_sair
			call msg_qw
			call msg_p
			call msg_qv
			
			; Apaga mouse
			mov ax,2h
			int 33h
			; Verifica o valor da variável aberto, para saber se o arquivo ja foi aberto alguma vez
			mov al,byte[aberto]     
			cmp al,0
				; Caso seja a primeira vez, aberto=0 , abre o arquivo
				je  vai_abrir       
			; Limpa a imagem caso aberto = 1
			;call limpa_imagem_e
			;Fecha o arquivo
			mov bx,[file_handle]
			mov ah,3eh
			mov al,00h
			int 21h
			; Abre o arquivo
			vai_abrir:

			call limpa_grafico
			call abre_arquivo

			; Zera a variavel da coluna do grafico
			mov word[coluna_grafico], 0

			; Carrega a mensagem de termino de carregamento do arquivo
			mov byte[cor],preto
			call msg_parametros			
			call msg_saturou_qv
			call msg_saturou_qv_2
			call msg_saturou_qw
			call msg_saturou_qw_2
			call msg_saturou_p			
			call msg_saturou_p_2
			call msg_abrindo_arquivo
			mov byte[cor],branco_intenso
			call msg_arquivo_aberto	

			; Mostra mouse
			mov ax,1h
			int 33h 
			; Retorna para o cheque de ocorrência do clique do mouse
			jmp checa_clique
		  
		;Deseja-se executar o filtro:
		botao_executar_2:
			; Muda a cor da mensagem 'executar' para verde
			mov byte[cor],verde
			call msg_executar
			; Mantém a mensagem das outras funções em branco
			mov byte[cor],branco_intenso
			call msg_abrir
			call msg_sair
			call msg_qw
			call msg_p
			call msg_qv
			call msg_parametros
			
			
			; Apaga mouse
			mov ax,2h
			int 33h

			; Verifica se o arquivo ja foi carregado
			mov al,byte[aberto]     
			cmp al,0
			je pula_plot
			
			call limpa_grafico
			call plota_grafico
			
			jmp pula_plot_final

			pula_plot:
			
			mov byte[cor],preto	
			call msg_parametros
			call msg_arquivo_aberto
			call msg_abrindo_arquivo
			call msg_saturou_qv_2
			call msg_saturou_qv
			call msg_saturou_qw_2
			call msg_saturou_p			
			call msg_saturou_p_2
			call msg_saturou_qw
			mov byte[cor],branco_intenso			
			call msg_arquivo_nao_aberto
			
			pula_plot_final:
			
			; Mostra mouse
			mov ax,1h
			int 33h 
			; Retorna para o cheque de ocorrência do clique do mouse
			jmp checa_clique  
			
		; Deseja-se sair do programa:
		botao_sair_2:
			; Muda a cor da mensagem 'sair' para verde
			mov byte[cor],verde
			call msg_sair
			; Mantém a mensagem das outras funções em branco
			mov byte[cor],branco_intenso
			call msg_abrir
			call msg_executar
			call msg_qw
			call msg_p
			call msg_qv
			call msg_parametros
			; Se direciona para a saída do programa
			jmp sair
			
		; Deseja-se incrementar o valor de qw:
		botao_qw_inc:	
			
			; Apaga mouse
			mov ax,2h
			int 33h
			
			push cx
			push bx
			mov cx,3     			;número de caracteres
			mov bx,0
			loop_qw_validar:
				mov al,[bx+var_qw]
				cmp byte[bx+var_limite_max_qv_qw], al
				jnz	valida_2_inc_qv
				inc bx              ;proximo caracter
				loop loop_qw_validar

			jmp continua_qw_inc_1

			valida_2_inc_qv:
				push cx
				push bx
				mov cx,3     			;número de caracteres
				mov bx,0
				loop_qw_validar_2:
					mov al,[bx+var_qw]
					cmp byte[bx+var_limite_max_p], al
					jnz	continua_qw_inc
					inc bx              ;proximo caracter
					loop loop_qw_validar_2				

			; Mantém a mensagem das outras funções em preto
			mov byte[cor],preto	
			call msg_parametros
			call msg_arquivo_aberto
			call msg_abrindo_arquivo
			call msg_saturou_qv_2
			call msg_saturou_qv
			call msg_saturou_qw_2
			call msg_saturou_p			
			call msg_saturou_p_2
			call msg_arquivo_nao_aberto
			mov byte[cor],branco_intenso		
			call msg_saturou_qw

			jmp equal_inc_qw_2

			continua_qw_inc_1:
			; Incrementa o Valor de qw em 10
			mov     esi, 2       ;digito mais a direita
			mov     ecx, 3       ;numero de digitos de var_qw
			clc					 ;limpo a flag de carry
			loop_qw_inc_10:  
				mov	al, [var_qw + esi]
				adc	al, [var_inc_dec_10 + esi]
				aaa				 ;ajuste apos adição
				pushf
				or	al, 30h
				popf			
				mov	[var_qw + esi], al
				dec	esi
				loop loop_qw_inc_10

			jmp equal_inc_qw
			
			continua_qw_inc:
			
			; Incrementa o Valor de qw em 20
			mov     esi, 2       ;digito mais a direita
			mov     ecx, 3       ;numero de digitos de var_qw
			clc					 ;limpo a flag de carry
			loop_qw_inc:  
				mov	al, [var_qw + esi]
				adc	al, [var_inc_dec + esi]
				aaa				 ;ajuste apos adição
				pushf
				or	al, 30h
				popf			
				mov	[var_qw + esi], al
				dec	esi
				loop loop_qw_inc

			jmp equal_inc_qw

			equal_inc_qw_2:			

			; Muda a cor da mensagem 'Qw = XXX' para verde
			mov byte[cor],verde	
			call msg_qw
			; Mantém a mensagem das outras funções em branco
			mov byte[cor],branco_intenso
			call msg_executar
			call msg_sair
			call msg_abrir
			call msg_p
			call msg_qv
			
			jmp final_inc_qw

			equal_inc_qw:
				
			; Muda a cor da mensagem 'Qw = XXX' para verde
			mov byte[cor],verde	
			call msg_qw
			; Mantém a mensagem das outras funções em branco
			mov byte[cor],branco_intenso
			call msg_executar
			call msg_sair
			call msg_abrir
			call msg_p
			call msg_qv
			call msg_parametros	

			final_inc_qw:		

			mov word[var_qw_dec], 0
			mov cx,3
			mov bx,0
			converte_qw:
				mov al, byte[var_qw+bx]
				mov [ascii], al
				inc bx
				call ascii2decimal
				loop converte_qw
			call junta_digitos_qw
		
			;equal_inc_qw:
			
			pop bx
			pop cx
			
			; Mostra mouse
			mov ax,1h
			int 33h 
			; Retorna para o cheque de ocorrência do clique do mouse
			jmp checa_clique
			
		; Deseja-se decrementar o valor de qw:
		botao_qw_dec:
				
			; Apaga mouse
			mov ax,2h
			int 33h		
			
			push cx
			push bx
			mov cx,3     			;número de caracteres
			mov bx,0
			loop_qw_validar_dec:
				mov al,[bx+var_qw]
				cmp byte[bx+var_limite_min_qv_qw], al
				jnz	valida_dec_qw
				inc bx              ;proximo caracter
				loop loop_qw_validar_dec

			jmp continua_qw_dec_1

			valida_dec_qw:
				push cx
				push bx
				mov cx,3     			;número de caracteres
				mov bx,0
				loop_qw_validar_dec_2:
					mov al,[bx+var_qw]
					cmp byte[bx+var_limite_min_p], al
					jnz	continua_qw_dec
					inc bx              ;proximo caracter
					loop loop_qw_validar_dec_2

			; Mantém a mensagem das outras funções em preto
			mov byte[cor],preto
			call msg_arquivo_aberto
			call msg_abrindo_arquivo
			call msg_parametros
			call msg_saturou_qv
			call msg_saturou_qv_2
			call msg_saturou_p
			call msg_saturou_p_2
			call msg_saturou_qw
			call msg_arquivo_nao_aberto
			mov byte[cor],branco_intenso		
			call msg_saturou_qw_2
			jmp equal_dec_qw_2

			continua_qw_dec_1:		
			
			mov     esi, 2       ;digito mais a direita
			mov     ecx, 3       ;numero de digitos de var_qw
			clc					 ;limpo a flag de carry
			loop_qw_dec_2:  
				mov	al, [var_qw + esi]
				sbb	al, [var_inc_dec_10 + esi]
				aas				 ;ajuste apos subtração
				pushf
				or	al, 30h
				popf			
				mov	[var_qw + esi], al
				dec	esi
				loop	loop_qw_dec_2

			jmp equal_dec_qw
			
			continua_qw_dec:
			
			mov     esi, 2       ;digito mais a direita
			mov     ecx, 3       ;numero de digitos de var_qw
			clc					 ;limpo a flag de carry
			loop_qw_dec:  
				mov	al, [var_qw + esi]
				sbb	al, [var_inc_dec + esi]
				aas				 ;ajuste apos subtração
				pushf
				or	al, 30h
				popf			
				mov	[var_qw + esi], al
				dec	esi
				loop	loop_qw_dec

			jmp equal_dec_qw

			equal_dec_qw_2:	

			; Muda a cor da mensagem 'P=XXX' para verde
			mov byte[cor],verde	
			call msg_qw
			; Mantém a mensagem das outras funções em branco		
			mov byte[cor],branco_intenso
			call msg_executar
			call msg_sair
			call msg_abrir
			call msg_p
			call msg_qv

			jmp fim_qw_dec
			
			equal_dec_qw:	

			; Muda a cor da mensagem 'P=XXX' para verde
			mov byte[cor],verde	
			call msg_qw
			; Mantém a mensagem das outras funções em branco		
			mov byte[cor],branco_intenso
			call msg_executar
			call msg_sair
			call msg_abrir
			call msg_p
			call msg_qv
			call msg_parametros

			fim_qw_dec:

			mov word[var_qw_dec], 0
			mov cx,3
			mov bx,0
			converte_qw_dec:
				mov al, byte[var_qw+bx]
				mov [ascii], al
				inc bx
				call ascii2decimal
				loop converte_qw_dec
			call junta_digitos_qw			
			
			pop bx
			pop cx
			
			; Mostra mouse
			mov ax,1h
			int 33h 
			; Retorna para o cheque de ocorrência do clique do mouse
			jmp checa_clique	
		
		; Deseja-se incrementar o valor de p:
		botao_p_inc:	
			
			; Apaga mouse
			mov ax,2h
			int 33h
						
			push cx
			push bx
			mov cx,3     			;número de caracteres
			mov bx,0
			loop_p_validar:
				mov al,[bx+var_p]
				cmp byte[bx+var_limite_max_p], al
				jnz	continua_p_inc
				inc bx              ;proximo caracter
				loop loop_p_validar

			; Mantém a mensagem das outras funções em preto
			mov byte[cor],preto	
			call msg_arquivo_aberto
			call msg_abrindo_arquivo
			call msg_parametros
			call msg_saturou_qv_2
			call msg_saturou_qv
			call msg_saturou_qw
			call msg_saturou_qw_2
			call msg_saturou_p_2
			call msg_arquivo_nao_aberto
			mov byte[cor],branco_intenso		
			call msg_saturou_p
			jmp equal_inc_p
			
			continua_p_inc:
			
			; Incrementa o Valor de p em 1
			mov     esi, 2       ;digito mais a direita
			mov     ecx, 3       ;numero de digitos de var_p
			clc					 ;limpo a flag de carry
			loop_p_inc:  
				mov 	al, [var_p + esi]
				adc 	al, [var_inc_dec + esi]
				aaa					 ;ajuste apos adição
				pushf
				or 	al, 30h
				popf			
				mov	[var_p + esi], al
				dec	esi
				loop	loop_p_inc
				
			; Muda a cor da mensagem 'P=XXX' para verde
			mov byte[cor],verde	
			call msg_p
			; Mantém a mensagem das outras funções em branco
			mov byte[cor],branco_intenso
			call msg_executar
			call msg_sair
			call msg_abrir
			call msg_qw
			call msg_qv
			call msg_parametros

			mov word[var_p_dec], 0
			mov cx,3
			mov bx,0
			converte_p:
				mov al, byte[var_p+bx]
				mov [ascii], al
				inc bx
				call ascii2decimal
				loop converte_p
			call junta_digitos_p
			
			equal_inc_p:
			
			pop bx
			pop cx
			
			; Mostra mouse
			mov ax,1h
			int 33h 
			; Retorna para o cheque de ocorrência do clique do mouse
			jmp checa_clique
			
		; Deseja-se decrementar o valor de p:
		botao_p_dec:
				
			; Apaga mouse
			mov ax,2h
			int 33h
			
			push cx
			push bx
			mov cx,3     			;número de caracteres
			mov bx,0
			loop_p_validar_dec:
				mov al,[bx+var_p]
				cmp byte[bx+var_limite_min_p], al
				jnz	continua_p_dec
				inc bx              ;proximo caracter
				loop loop_p_validar_dec

			; Mantém a mensagem das outras funções em preto
			mov byte[cor],preto	
			call msg_arquivo_aberto
			call msg_abrindo_arquivo
			call msg_parametros
			call msg_saturou_qw	
			call msg_saturou_qw_2
			call msg_saturou_qv	
			call msg_saturou_qv_2
			call msg_saturou_p
			call msg_arquivo_nao_aberto
			mov byte[cor],branco_intenso		
			call msg_saturou_p_2
			jmp equal_dec_p
			
			continua_p_dec:			
			
			mov     esi, 2       ;digito mais a direita
			mov     ecx, 3       ;numero de digitos de var_p
			clc					 ;limpo a flag de carry
			loop_p_dec:  
				mov 	al, [var_p + esi]
				sbb 	al, [var_inc_dec + esi]
				aas				 ;ajuste apos subtração
				pushf
				or 	al, 30h
				popf			
				mov	[var_p + esi], al
				dec	esi
				loop	loop_p_dec		
				
			; Muda a cor da mensagem 'P=XXX' para verde
			mov byte[cor],verde	
			call msg_p
			; Mantém a mensagem das outras funções em branco		
			mov byte[cor],branco_intenso
			call msg_executar
			call msg_sair
			call msg_abrir
			call msg_qw
			call msg_qv
			call msg_parametros

			mov word[var_p_dec], 0
			mov cx,3
			mov bx,0
			converte_p_dec:
				mov al, byte[var_p+bx]
				mov [ascii], al
				inc bx
				call ascii2decimal
				loop converte_p_dec
			call junta_digitos_p
			
			equal_dec_p:
			
			pop bx
			pop cx
			
			; Mostra mouse
			mov ax,1h
			int 33h 
			; Retorna para o cheque de ocorrência do clique do mouse
			jmp checa_clique
			
		; Deseja-se incrementar o valor de qv:
		botao_qv_inc:	
			
			; Apaga mouse
			mov ax,2h
			int 33h
			
			push cx
			push bx
			mov cx,3     			;número de caracteres
			mov bx,0
			loop_qv_validar:
				mov al,[bx+var_qv]
				cmp byte[bx+var_limite_max_qv_qw], al
				jnz	valida_inc_qv
				inc bx              ;proximo caracter
				loop loop_qv_validar

			jmp continua_2

			valida_inc_qv:
			push cx
			push bx
			mov cx,3     			;número de caracteres
			mov bx,0
			loop_qv_validar_2:
				mov al,[bx+var_qv]
				cmp byte[bx+var_limite_max_p], al
				jnz	continua
				inc bx              ;proximo caracter
				loop loop_qv_validar_2	

			; Mantém a mensagem das outras funções em preto
			mov byte[cor],preto
			call msg_arquivo_aberto
			call msg_abrindo_arquivo
			call msg_parametros
			call msg_saturou_qv_2
			call msg_saturou_qw
			call msg_saturou_qw_2
			call msg_saturou_p
			call msg_saturou_p_2
			call msg_arquivo_nao_aberto
			mov byte[cor],branco_intenso		
			call msg_saturou_qv
			jmp equal_2

			continua_2:
			; Incrementa o Valor de p em 1
			mov     esi, 2       ;digito mais a direita
			mov     ecx, 3       ;numero de digitos de var_qv
			clc					 ;limpo a flag de carry
			loop_qv_inc:  
				mov	al, [var_qv + esi]
				adc	al, [var_inc_dec_10 + esi]
				aaa				 ;ajuste apos adição
				pushf
				or	al, 30h
				popf			
				mov	[var_qv + esi], al
				dec	esi
				loop loop_qv_inc

			jmp equal
			
			continua:
			; Incrementa o Valor de p em 1
			mov     esi, 2       ;digito mais a direita
			mov     ecx, 3       ;numero de digitos de var_qv
			clc					 ;limpo a flag de carry
			loop_qv_inc_2:  
				mov	al, [var_qv + esi]
				adc	al, [var_inc_dec + esi]
				aaa				 ;ajuste apos adição
				pushf
				or	al, 30h
				popf			
				mov	[var_qv + esi], al
				dec	esi
				loop loop_qv_inc_2
				
			equal_2:

			; Muda a cor da mensagem 'Qv = XXX' para verde
			mov byte[cor],verde	
			call msg_qv
			; Mantém a mensagem das outras funções em branco
			mov byte[cor],branco_intenso
			call msg_executar
			call msg_sair
			call msg_abrir
			call msg_p
			call msg_qw
			jmp fim_qv

			equal:
				
			; Muda a cor da mensagem 'Qv = XXX' para verde
			mov byte[cor],verde	
			call msg_qv
			; Mantém a mensagem das outras funções em branco
			mov byte[cor],branco_intenso
			call msg_executar
			call msg_sair
			call msg_abrir
			call msg_p
			call msg_qw
			call msg_parametros

			fim_qv:

			mov word[var_qv_dec], 0
			mov cx,3
			mov bx,0
			converte_qv:
				mov al, byte[var_qv+bx]
				mov [ascii], al
				inc bx
				call ascii2decimal
				loop converte_qv
			call junta_digitos_qv		
			
			pop bx
			pop cx

			; Mostra mouse
			mov ax,1h
			int 33h 
			; Retorna para o cheque de ocorrência do clique do mouse
			jmp checa_clique
			
		; Deseja-se decrementar o valor de qv:
		botao_qv_dec:
				
			; Apaga mouse
			mov ax,2h
			int 33h	

			push cx
			push bx
			mov cx,3     			;número de caracteres
			mov bx,0
			loop_qv_validar_dec:
				mov al,[bx+var_qv]
				cmp byte[bx+var_limite_min_qv_qw], al
				jnz	valida_qv_dec
				inc bx              ;proximo caracter
				loop loop_qv_validar_dec

			jmp continua_qv_dec_1

			valida_qv_dec:
			push cx
			push bx
			mov cx,3     			;número de caracteres
			mov bx,0
			loop_qv_validar_dec_2:
				mov al,[bx+var_qv]
				cmp byte[bx+var_limite_min_p], al
				jnz	continua_qv_dec
				inc bx              ;proximo caracter
				loop loop_qv_validar_dec_2	

			; Mantém a mensagem das outras funções em preto
			mov byte[cor],preto	
			call msg_arquivo_aberto
			call msg_abrindo_arquivo
			call msg_parametros
			call msg_saturou_qv	
			call msg_saturou_qw
			call msg_saturou_qw_2
			call msg_saturou_p
			call msg_saturou_p_2
			call msg_arquivo_nao_aberto
			mov byte[cor],branco_intenso		
			call msg_saturou_qv_2
			jmp equal_dec_qv_1

			continua_qv_dec_1:
			
			mov     esi, 2       ;digito mais a direita
			mov     ecx, 3       ;numero de digitos de var_qv
			clc					 ;limpo a flag de carry
			loop_qv_dec_2:  
				mov	al, [var_qv + esi]
				sbb	al, [var_inc_dec_10 + esi]
				aas				 ;ajuste apos subtração
				pushf
				or	al, 30h
				popf			
				mov	[var_qv + esi], al
				dec	esi
				loop	loop_qv_dec_2
			jmp equal_dec_qv	
			
			continua_qv_dec:
			
			mov     esi, 2       ;digito mais a direita
			mov     ecx, 3       ;numero de digitos de var_qv
			clc					 ;limpo a flag de carry
			loop_qv_dec:  
				mov	al, [var_qv + esi]
				sbb	al, [var_inc_dec + esi]
				aas				 ;ajuste apos subtração
				pushf
				or	al, 30h
				popf			
				mov	[var_qv + esi], al
				dec	esi
				loop	loop_qv_dec		
				
			equal_dec_qv_1:
			; Muda a cor da mensagem 'Qv=XXX' para verde
			mov byte[cor],verde	
			call msg_qv
			; Mantém a mensagem das outras funções em branco		
			mov byte[cor],branco_intenso
			call msg_executar
			call msg_sair
			call msg_abrir
			call msg_p
			call msg_qw
			jmp fim_dec_qv

			equal_dec_qv:	
			; Muda a cor da mensagem 'Qv=XXX' para verde
			mov byte[cor],verde	
			call msg_qv
			; Mantém a mensagem das outras funções em branco		
			mov byte[cor],branco_intenso
			call msg_executar
			call msg_sair
			call msg_abrir
			call msg_p
			call msg_qw
			call msg_parametros

			fim_dec_qv:

			mov word[var_qv_dec], 0
			mov cx,3
			mov bx,0
			converte_qv_dec:
				mov al, byte[var_qv+bx]
				mov [ascii], al
				inc bx
				call ascii2decimal
				loop converte_qv_dec
			call junta_digitos_qv		
			
			pop bx
			pop cx
			
			; Mostra mouse
			mov ax,1h
			int 33h 
			; Retorna para o cheque de ocorrência do clique do mouse
			jmp checa_clique	
	  
	;***************************************************************
	;                                                              ;
	; 					  ABERTURA DE ARQUIVOS                     ; 
	;                                                              ;
	;***************************************************************

		abre_arquivo:
			; Salvando contexto
			pushf
			push ax
			push bx
			push cx
			push dx
			push si
			push di
			push bp
			
			; Zera o contador de numeros lidos
			mov	word[num_count],0
			
			; Abrir arquivo somente para leitura
			mov ah,3dh        
			mov al,00h
			mov dx,file_name
			int 21h
			mov [file_handle],ax
			
			; Verifica se o arquivo foi aberto corretamente
			lahf                
			and ah,01           
			cmp ah,01           
				jne abriu_corretamente          
			;Caso contrário, retorna ao cheque de ocorrência de clique
			pop	bp
			pop	di
			pop	si
			pop	dx
			pop	cx
			pop	bx
			pop	ax
			popf
			ret
			
			; Caso o arquivo tenha sido aberto corretamente	
			abriu_corretamente:

				; Sinaliza ao fazer [aberto] <- 1 
				mov byte[aberto],1

				proximo_byte:
					
					mov bx,[file_handle]
					mov dx,buffer
					mov cx,1
					mov ah,3Fh
					int 21h

					;Caso não seja lido 1 byte, chegou ao final do arquivo
					cmp ax,cx
						jne final_arquivo
					
					mov al,byte[buffer]
					mov byte[ascii],al
					
					mov bl, byte[count]
					
					cmp al, 32
						je proximo_byte
					cmp al, '.'
						je proximo_byte
					cmp bl, 3
						jne continua_lendo
					cmp al, 'e'
						jne proximo_byte
				
					mov bx,[file_handle]
					mov dx,buffer
					mov cx,1
					mov ah,3Fh
					int 21h

					mov bx,[file_handle]
					mov dx,buffer
					mov cx,1
					mov ah,3Fh
					int 21h

					mov bx,[file_handle]
					mov dx,buffer
					mov cx,1
					mov ah,3Fh
					int 21h

					mov al,byte[buffer]
					mov byte[deslocamento],al
					
					call junta_digitos

					mov	byte[count],0

					jmp proximo_byte
				
					continua_lendo:

					; Chama a função de conversão de ascii para decimal
					call 	ascii2decimal
					
					; Incrementa o contador de algarismos
					inc		bl
					mov		byte[count],bl

					; Volta para a leitura do proximo byte
					jmp 	proximo_byte
				  
				jne		proximo_byte
				
				; Agora temos em decimal como um vetor de valores do arquivo sinal.txt	 		
				final_arquivo:

				; Fecha o arquivo aberto
				mov bx,[file_handle]
				mov ah,3eh
				mov al,00h
				int 21h
			
			; Recuperando contexto
			pop		bp
			pop		di
			pop		si
			pop		dx
			pop		cx
			pop		bx
			pop		ax
			popf
			ret

 	;***************************************************************
	;                                                              ;
	; 		     	CONVERSÃO DE ASCII PARA DECIMAL                ; 
	;                                                              ;
	;***************************************************************
		
		ascii2decimal:
			; Salvando contexto
			pushf
			push 	ax
			push 	bx
			push	cx
			push	dx
			push	si
			push	di
			push	bp

			; Zera cx para as operações a seguir
			xor 	cx,cx
			
			; Número decimal = (Número em ASCII - 30h)
			; O valor em ascii do byte lido é passado em al
			mov 	al,[ascii]
			sub 	al,30h
			mov 	cl,byte[unidade] 
			mov 	ch,byte[dezena]
			; O valor lido é tido como unidade; Quando outros bytes do mesmo número 
			; são lidos, é feito um "shift left" de maneira que o novo valor lido se 
			; torna unidade e o lido anteriormente se torna dezena, e assim 
			; sucessivamente, até o fim da leitura do número.
			mov 	byte[unidade],al
			mov 	byte[dezena],cl
			mov 	byte[centena],ch

			; Recuperando contexto
			pop		bp
			pop		di
			pop		si
			pop		dx
			pop		cx
			pop		bx
			pop		ax
			popf
			ret
	
 	;***************************************************************
	;                                                              ;
	; 		     JUNTA OS DIGITOS E ARMAZENA EM DECIMAL            ; 
	;                                                              ;
	;***************************************************************
	; Função que gera um número juntando os digitos,
	; mutiplicando-os por seus respectivos valores de base
	; e somando-os.

		junta_digitos:  
			; Salvando contexto
			pushf
			push 	ax
			push 	bx
			push	cx
			push	dx
			push	si
			push	di
			push	bp
			
			; Zera os registradores para as operações a seguir
			xor		ax,ax
			xor		bx,bx
			xor		cx,cx
			xor		dx,dx	
			xor 	ah,ah
			xor 	ch,ch
			
			; Verifica o valor do deslocamento necessário para o numero lido
			mov 	bl,byte[deslocamento]	
			
			cmp bl, '2'
				je numero_3	
			cmp bl, '1'
				je numero_2	
			jmp	numero_1
				
			numero_3:
			; [decimal] <- 100*[centena] + 10*[dezena] + [unidade]
			
			mov 	al,byte[centena]
			mov 	bl,100
			mul 	bl
			mov 	cx,ax	
			
			xor 	ah,ah
			mov 	al,byte[dezena]
			mov 	bl,10
			mul 	bl
			add 	cx,ax	
			
			xor 	ah,ah
			mov 	al,[unidade]
			add 	cx,ax 
			
			jmp final_juncao
			
			numero_2:
			; [decimal] <- 10*[centena] + [dezena]

			mov 	al,byte[centena]
			mov 	bl,10
			mul 	bl
			mov 	cx,ax	
			
			xor 	ah,ah
			mov 	al,byte[dezena]
			add 	cx,ax	
			
			jmp final_juncao
			
			numero_1:
			; [decimal] <- [centena]
			
			mov 	al,byte[centena]
			mov 	cx,ax	
			
			final_juncao:	
			
			mov		bx, word[num_count]
			
			; Carrega na posição anterior + 1, o novo valor na variavel decimal
			mov 	byte[decimal+bx],cl

			; Incrementa o contador de numeros
			inc 	bx
			mov		word[num_count],bx		

			; Após formado o número,
			; limpo os dígitos para não sujar uma próxima leituras
			mov 	byte[unidade],0
			mov 	byte[dezena],0
			mov 	byte[centena],0
			
			; Recuperando contexto
			pop		bp
			pop		di
			pop		si
			pop		dx
			pop		cx
			pop		bx
			pop		ax
			popf
			ret

		junta_digitos_qw:  
			; Salvando contexto
			pushf
			push 	ax
			push 	bx
			push	cx
			push	dx
			push	si
			push	di
			push	bp
			
			; Zera os registradores para as operações a seguir
			xor		ax,ax
			xor		bx,bx
			xor		cx,cx
			xor		dx,dx	
			xor 	ah,ah
			xor 	ch,ch
			
			; [decimal] <- 100*[centena] + 10*[dezena] + [unidade]
			
			mov 	al,byte[centena]
			mov 	bl,100
			mul 	bl
			mov 	cx,ax	
			
			xor 	ah,ah
			mov 	al,byte[dezena]
			mov 	bl,10
			mul 	bl
			add 	cx,ax	
			
			xor 	ah,ah
			mov 	al,[unidade]
			add 	cx,ax 
			
			; Carrega na posição anterior + 1, o novo valor na variavel decimal
			mov 	word[var_qw_dec],cx

			; Após formado o número,
			; limpo os dígitos para não sujar uma próxima leituras
			mov 	byte[unidade],0
			mov 	byte[dezena],0
			mov 	byte[centena],0
			
			; Recuperando contexto
			pop		bp
			pop		di
			pop		si
			pop		dx
			pop		cx
			pop		bx
			pop		ax
			popf
			ret	

		junta_digitos_p:  
			; Salvando contexto
			pushf
			push 	ax
			push 	bx
			push	cx
			push	dx
			push	si
			push	di
			push	bp
			
			; Zera os registradores para as operações a seguir
			xor		ax,ax
			xor		bx,bx
			xor		cx,cx
			xor		dx,dx	
			xor 	ah,ah
			xor 	ch,ch
			
			; [decimal] <- 100*[centena] + 10*[dezena] + [unidade]
			
			mov 	al,byte[centena]
			mov 	bl,100
			mul 	bl
			mov 	cx,ax	
			
			xor 	ah,ah
			mov 	al,byte[dezena]
			mov 	bl,10
			mul 	bl
			add 	cx,ax	
			
			xor 	ah,ah
			mov 	al,[unidade]
			add 	cx,ax 
			
			; Carrega na posição anterior + 1, o novo valor na variavel decimal
			mov 	word[var_p_dec],cx

			; Após formado o número,
			; limpo os dígitos para não sujar uma próxima leituras
			mov 	byte[unidade],0
			mov 	byte[dezena],0
			mov 	byte[centena],0
			
			; Recuperando contexto
			pop		bp
			pop		di
			pop		si
			pop		dx
			pop		cx
			pop		bx
			pop		ax
			popf
			ret	

		junta_digitos_qv:  
			; Salvando contexto
			pushf
			push 	ax
			push 	bx
			push	cx
			push	dx
			push	si
			push	di
			push	bp
			
			; Zera os registradores para as operações a seguir
			xor		ax,ax
			xor		bx,bx
			xor		cx,cx
			xor		dx,dx	
			xor 	ah,ah
			xor 	ch,ch
			
			; [decimal] <- 100*[centena] + 10*[dezena] + [unidade]
			
			mov 	al,byte[centena]
			mov 	bl,100
			mul 	bl
			mov 	cx,ax	
			
			xor 	ah,ah
			mov 	al,byte[dezena]
			mov 	bl,10
			mul 	bl
			add 	cx,ax	
			
			xor 	ah,ah
			mov 	al,[unidade]
			add 	cx,ax 
			
			; Carrega na posição anterior, o novo valor na variavel decimal
			mov 	word[var_qv_dec],cx

			; Após formado o número,
			; limpo os dígitos para não sujar uma próxima leituras
			mov 	byte[unidade],0
			mov 	byte[dezena],0
			mov 	byte[centena],0
			
			; Recuperando contexto
			pop		bp
			pop		di
			pop		si
			pop		dx
			pop		cx
			pop		bx
			pop		ax
			popf
			ret	

	;***************************************************************
	;															   ;
	; 				CRIAÇÃO DA INTERFACE GRÁFICA                   ;
	;															   ;
	;***************************************************************
	
		faz_interface:     
			call cria_divisorias
			call msg_abrir
			call msg_sair
			call msg_qw
			call msg_p
			call msg_qv
			call msg_parametros
			ret 
	  
	;***************************************************************
	;                                                              ;
	; 				FUNÇÕES DE INTERFACE GRÁFICA                   ;
	;                                                              ;
	;***************************************************************
	; Função para desenho das divisórias dos botões e estruturas : 
	; faz as divisórias e contorno das entruturas da interface a partir da função line
	
		cria_divisorias:
			push ax       
			push bx       
			push cx       
			push dx       
			push si       
			push di   
			  
			; Borda Superior
			mov ax,0                        
			push ax
			mov ax,479
			push ax
			mov ax,639
			push ax
			mov ax,479
			push ax
			call line
			
			; Borda Esquerda
			mov ax,0              
			push ax
			mov ax,0
			push ax
			mov ax,0
			push ax
			mov ax,479
			push ax
			call line
			
			; Borda Direita 
			mov ax,639             
			push ax
			mov ax,0
			push ax
			mov ax,639
			push ax
			mov ax,479
			push ax
			call line
				
			; Borda Inferior
			mov ax,0             
			push ax
			mov ax,0
			push ax
			mov ax,639
			push ax
			mov ax,0
			push ax
			call line
					
			; Divisória Vertical
			mov ax, 190                     
			push ax
			mov ax,0
			push ax
			mov ax, 190
			push ax
			mov ax,479
			push ax
			call line
				
			; Contorno do botão de "Sair"
			mov ax, 0                      
			push ax
			mov ax,80
			push ax
			mov ax, 190
			push ax
			mov ax,80
			push ax
			call line
				
			; Contorno do botão de "Qv"  
			mov ax, 0                
			push ax
			mov ax, 160
			push ax
			mov ax, 190
			push ax
			mov ax, 160
			push ax
			call line		
				
			; Terceira mini-divisória vertical    P
			mov ax, 0                
			push ax
			mov ax, 240
			push ax
			mov ax, 190
			push ax
			mov ax, 240
			push ax
			call line
			
			; Desenho Seta Botão Qw
				; Seta Inferior
				mov ax, 22                
				push ax
				mov ax, 272
				push ax
				mov ax, 42
				push ax
				mov ax, 272
				push ax
				call line
				mov ax, 22                
				push ax
				mov ax, 272
				push ax
				mov ax, 32
				push ax
				mov ax, 248
				push ax
				call line
				mov ax, 42                
				push ax
				mov ax, 272
				push ax
				mov ax, 32
				push ax
				mov ax, 248
				push ax
				call line
				
				; Seta Superior
				mov ax, 22                
				push ax
				mov ax, 288
				push ax
				mov ax, 42
				push ax
				mov ax, 288
				push ax
				call line
				mov ax, 22                
				push ax
				mov ax, 288
				push ax
				mov ax, 32
				push ax
				mov ax, 312
				push ax
				call line
				mov ax, 42                
				push ax
				mov ax, 288
				push ax
				mov ax, 32
				push ax
				mov ax, 312
				push ax
				call line
			
			; Desenho Seta Botão P
				; Seta Inferior
				mov ax, 22                
				push ax
				mov ax, 192
				push ax
				mov ax, 42
				push ax
				mov ax, 192
				push ax
				call line
				mov ax, 22                
				push ax
				mov ax, 192
				push ax
				mov ax, 32
				push ax
				mov ax, 168
				push ax
				call line
				mov ax, 42                
				push ax
				mov ax, 192
				push ax
				mov ax, 32
				push ax
				mov ax, 168
				push ax
				call line
				
				; Seta Superior
				mov ax, 22                
				push ax
				mov ax, 208
				push ax
				mov ax, 42
				push ax
				mov ax, 208
				push ax
				call line
				mov ax, 22                
				push ax
				mov ax, 208
				push ax
				mov ax, 32
				push ax
				mov ax, 232
				push ax
				call line
				mov ax, 42                
				push ax
				mov ax, 208
				push ax
				mov ax, 32
				push ax
				mov ax, 232
				push ax
				call line
			
			; Desenho Seta Botão Qv
				; Seta Inferior
				mov ax, 22                
				push ax
				mov ax, 112
				push ax
				mov ax, 42
				push ax
				mov ax, 112
				push ax
				call line
				mov ax, 22                
				push ax
				mov ax, 112
				push ax
				mov ax, 32
				push ax
				mov ax, 88
				push ax
				call line
				mov ax, 42                
				push ax
				mov ax, 112
				push ax
				mov ax, 32
				push ax
				mov ax, 88
				push ax
				call line
				
				; Seta Superior
				mov ax, 22                
				push ax
				mov ax, 128
				push ax
				mov ax, 42
				push ax
				mov ax, 128
				push ax
				call line
				mov ax, 22                
				push ax
				mov ax, 128
				push ax
				mov ax, 32
				push ax
				mov ax, 152
				push ax
				call line
				mov ax, 42                
				push ax
				mov ax, 128
				push ax
				mov ax, 32
				push ax
				mov ax, 152
				push ax
				call line
				
			; Linha horizontal botão Qw 
			mov ax, 64                
			push ax
			mov ax, 280
			push ax
			mov ax, 0
			push ax
			mov ax, 280
			push ax
			call line
			
			; Linha horizontal botão P 
			mov ax, 64                
			push ax
			mov ax, 200
			push ax
			mov ax, 0
			push ax
			mov ax, 200
			push ax
			call line
			
			; Linha horizontal botão Qv
			mov ax, 64                
			push ax
			mov ax, 120
			push ax
			mov ax, 0
			push ax
			mov ax, 120
			push ax
			call line
			
			; Linha vertical botões 
			mov ax, 64                
			push ax
			mov ax, 320
			push ax
			mov ax, 64
			push ax
			mov ax, 80
			push ax
			call line
			  
			; Contorno do botão "Executar"
			mov ax, 0                
			push ax
			mov ax, 320
			push ax
			mov ax, 190
			push ax
			mov ax, 320
			push ax
			call line		
			
			; Desenho da seta do botão executar		
				;Linha Vertical
				mov ax, 30                      
				push ax
				mov ax, 345
				push ax
				mov ax, 30
				push ax
				mov ax, 370
				push ax
				call line
				
				;Parte de Cima
				mov ax, 30                      
				push ax
				mov ax,345
				push ax
				mov ax, 110
				push ax
				mov ax,345
				push ax
				call line
				
				;Parte de Baixo
				mov ax, 30                      
				push ax
				mov ax,370
				push ax
				mov ax, 110
				push ax
				mov ax,370
				push ax
				call line
				
				;Linha Vertical Superior
				mov ax, 110                      
				push ax
				mov ax,370
				push ax
				mov ax, 110
				push ax
				mov ax,380
				push ax
				call line
				
				;Linha Vertical Inferior
				mov ax, 110                      
				push ax
				mov ax, 345
				push ax
				mov ax, 110
				push ax
				mov ax, 335
				push ax
				call line
				
				;Ponta da Seta Superior
				mov ax, 110                      
				push ax
				mov ax, 380
				push ax
				mov ax, 160
				push ax
				mov ax, 360
				push ax
				call line
				
				;Ponta da Seta Inferior
				mov ax, 110                      
				push ax
				mov ax, 335
				push ax
				mov ax, 160
				push ax
				mov ax, 360
				push ax
				call line
			
			; Contorno botão "Abrir"
			mov ax, 0                
			push ax
			mov ax, 400
			push ax
			mov ax, 190
			push ax
			mov ax, 400
			push ax
			call line
				
			; Mensagens - Linha vertical esquerda interna
			mov ax, 210                
			push ax
			mov ax,20
			push ax
			mov ax, 210
			push ax
			mov ax,70
			push ax
			call line
			
			; Mensagens - Linha vertical direita interna
			mov ax, 620                
			push ax
			mov ax,20
			push ax
			mov ax, 620
			push ax
			mov ax,70
			push ax
			call line
			
			; Mensagens - Linha horizontal superior interna
			mov ax, 210                
			push ax
			mov ax,70
			push ax
			mov ax, 620
			push ax
			mov ax,70
			push ax
			call line
			
			; Mensagens - Linha horizontal inferior interna
			mov ax, 210                
			push ax
			mov ax,20
			push ax
			mov ax, 620
			push ax
			mov ax,20
			push ax
			call line
			
			; Mensagens - Linha vertical esquerda externa
			mov ax, 205               
			push ax
			mov ax, 15
			push ax
			mov ax, 205
			push ax
			mov ax, 75
			push ax
			call line
			
			; Mensagens - Linha vertical direita externa
			mov ax, 625              
			push ax
			mov ax, 15
			push ax
			mov ax, 625
			push ax
			mov ax, 75
			push ax
			call line
			
			; Mensagens - Linha horizontal superior externa
			mov ax, 205               
			push ax
			mov ax,75
			push ax
			mov ax, 625
			push ax
			mov ax,75
			push ax
			call line
			
			; Mensagens - Linha horizontal inferior externa
			mov ax, 205                
			push ax
			mov ax, 15
			push ax
			mov ax, 625
			push ax
			mov ax, 15
			push ax
			call line	

			; Eixo x grafico
				mov ax, 235                
				push ax
				mov ax, 100
				push ax
				mov ax, 610
				push ax
				mov ax, 100
				push ax
				call line

			; Eixo y grafico
				mov ax, 235                
				push ax
				mov ax, 100
				push ax
				mov ax, 235
				push ax
				mov ax, 440
				push ax
				call line

			; Seta eixo x
				mov ax, 235                
				push ax
				mov ax, 440
				push ax
				mov ax, 240
				push ax
				mov ax, 440
				push ax
				call line
				mov ax, 235                
				push ax
				mov ax, 440
				push ax
				mov ax, 230
				push ax
				mov ax, 440
				push ax
				call line
				mov ax, 240                
				push ax
				mov ax, 440
				push ax
				mov ax, 235
				push ax
				mov ax, 450
				push ax
				call line
				mov ax, 230                
				push ax
				mov ax, 440
				push ax
				mov ax, 235
				push ax
				mov ax, 450
				push ax
				call line

			; Seta eixo x
				mov ax, 610                
				push ax
				mov ax, 100
				push ax
				mov ax, 610
				push ax
				mov ax, 105
				push ax
				call line
				mov ax, 610                
				push ax
				mov ax, 100
				push ax
				mov ax, 610
				push ax
				mov ax, 95
				push ax
				call line
				mov ax, 610                
				push ax
				mov ax, 105
				push ax
				mov ax, 620
				push ax
				mov ax, 100
				push ax
				call line
				mov ax, 610                
				push ax
				mov ax, 95
				push ax
				mov ax, 620
				push ax
				mov ax, 100
				push ax
				call line


			pop di
			pop si
			pop dx
			pop cx
			pop bx
			pop ax
			ret

	
	;***************************************************************
	;                                                              ;
	;   		  	FUNÇÃO DE PLOTAGEM DOS GRÁFICOS                ;
	;                                                              ;
	;***************************************************************

		plota_grafico:
			; Salvando contexto
			pushf
			push ax
			push bx
			push cx
			push dx
			push si
			push di
			push bp

			;mov byte[x_anterior], 0
			;mov byte[y_anterior], 0
			;mov byte[xant], 0
			;mov ax, word[var_p_dec]
			;mov	word[pant], ax
			;xor ax, ax

			mov byte[cor],azul

			mov bx, word[coluna_grafico]
			cmp bx, word[num_count]
				jle coluna_valida
			mov word[coluna_grafico], 0
			mov byte[cor],rosa

			coluna_valida:	
			
			mov bx, 0
			mov cx, 300		

			printar:	
				mov byte[cor],azul
				mov ax, bx
				add ax,236		
				push ax
				mov ah, 0
				mov al, byte[y_anterior]
				add ax,100
				push ax			
				inc bx
				mov ax, bx
				add ax,236
				mov byte[x_anterior], bl
				push ax	
				push bx			
				mov bx, word[coluna_grafico]
				mov dh, 0
				mov dl, byte[decimal+bx]
				inc bx
				mov word[coluna_grafico], bx			
				pop bx
				mov byte[y_anterior], dl
				mov ax,dx
				add ax,100
				push ax
				call line

				mov byte[cor],vermelho
				dec bx
				mov ax, bx
				add ax,236		
				push ax
				xor ax,ax
				mov ax, word[xant]
				add ax,100
				push ax	

				inc bx
				mov ax, bx
				add ax,236
				push ax
				
				call faz_conta

				xor ax,ax
				mov ax, word[xant]
				add ax,100
				push ax
				call line

				inc byte[tique]

				esperar:
				cmp	byte[tique], 1
				je esperar		

			loop printar

				
			mov byte[cor],branco_intenso		

			; Recuperando contexto
			pop		bp
			pop		di
			pop		si
			pop		dx
			pop		cx
			pop		bx
			pop		ax
			popf
			ret

		faz_conta:    
			pushf
			push ax
			push bx
			push cx
			push dx
			push si
			push di
			push bp

			; xant(i-1) = word[xant]
			; pant(i-1) = word[pant]
			; xprox(i) = word[xprox]
			; Qw = word[var_qw_dec]
			; Qv = word[var_qv_dec]

			xor ax,ax
			mov ax,[xant] 		;xprox = xant
			mov [xprox],ax
			mov ax,[var_qw_dec] ; pprox = pant + var_qw_dec
			add ax,[pant]
			mov [pprox],ax
			mov bx,[pprox] 		; pprox + var_qv_dec
			add bx,[var_qv_dec]
			mov ax,[pprox]
			xor dx,dx
			mov dl,[y_anterior]
			mul dx
			div bx
			push ax 			; pprox*y_anterior / (pprox+var_qv_dec)
			mov ax,[pprox]
			mul word[xprox]  	;pprox*xprox
			div bx 				;pprox*xprox/(pprox+var_qv_dec)
			mov dx,ax
			pop ax
			add ax,word[xprox]
			sub ax,dx 			; xprox - pprox*xprox/(pprox+var_qv_dec)
			mov [xant],ax
			mov ax,[pprox]
			mul word[pprox]
			div bx
			mov dx,[pprox]
			sub dx,ax
			mov [pant],dx

			pop		bp
			pop		di
			pop		si
			pop		dx
			pop		cx
			pop		bx
			pop		ax
			popf
			ret

	;***************************************************************
	;                                                              ;
	;   	     		FUNÇÃO PARA LIMPAR GRÁFICO                 ;
	;                                                              ;
	;***************************************************************
	
		limpa_grafico:    
			push    cx     
			push    ax
			push    dx
			push    bx
			mov word[linha_atual],0
			mov word[coluna_atual],0
			
			mov cx,300      ; Números de linhas do grafico
			
			linhas:
				push cx
				mov cx, 310       ; Números de colunas do grafico
					colunas:
						call plota_pixel   ; Função que plota um pixel na tela
						inc word[coluna_atual]
						loop colunas
				dec word[linha_atual]
				mov word[coluna_atual],0
				pop cx
				loop linhas
			pop   bx
			pop   dx
			pop   ax    
			pop   cx
			ret

		plota_pixel: ; Função que pinta um pixel preta na tela
			push ax
			push bx
			push dx
			mov byte[cor],preto   
			mov bx,[coluna_atual]
			add bx,236 ;x
			push bx       
			mov bx,[linha_atual]
			add bx,400 ;y
			push bx       
			call plot_xy
			pop dx
			pop bx
			pop ax
			ret

	;***************************************************************
	;                                                              ;
	; 				FUNÇÕES PARA ESCRITA DE MENSAGENS              ;
	;                                                              ;
	;***************************************************************
	
		msg_abrir:
			push ax
			push bx
			push cx
			push dx
			mov cx,5      ;número de caracteres
			mov bx,0
			mov dh,2      ;linha 0-29
			mov dl,10      ;coluna 0-79
			loop_abrir:
				call cursor
				mov al,[bx+mens1]
				call  caracter
				inc bx      ;proximo caracter
				inc dl      ;avanca a coluna
				loop loop_abrir
			pop dx 
			pop cx
			pop bx
			pop ax
			ret
			
		msg_executar:
			push ax
			push bx
			push cx
			push dx
			
			; Desenho da seta do botão executar		
			;Linha Vertical
			mov ax, 30                      
			push ax
			mov ax, 345
			push ax
			mov ax, 30
			push ax
			mov ax, 370
			push ax
			call line
			
			;Parte de Cima
			mov ax, 30                      
			push ax
			mov ax,345
			push ax
			mov ax, 110
			push ax
			mov ax,345
			push ax
			call line
			
			;Parte de Baixo
			mov ax, 30                      
			push ax
			mov ax,370
			push ax
			mov ax, 110
			push ax
			mov ax,370
			push ax
			call line
			
			;Linha Vertical Superior
			mov ax, 110                      
			push ax
			mov ax,370
			push ax
			mov ax, 110
			push ax
			mov ax,380
			push ax
			call line
			
			;Linha Vertical Inferior
			mov ax, 110                      
			push ax
			mov ax, 345
			push ax
			mov ax, 110
			push ax
			mov ax, 335
			push ax
			call line
			
			;Ponta da Seta Superior
			mov ax, 110                      
			push ax
			mov ax, 380
			push ax
			mov ax, 160
			push ax
			mov ax, 360
			push ax
			call line
			
			;Ponta da Seta Inferior
			mov ax, 110                      
			push ax
			mov ax, 335
			push ax
			mov ax, 160
			push ax
			mov ax, 360
			push ax
			call line
			
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
			mov cx,4      ;número de caracteres
			mov bx,0
			mov dh,27            ;linha 0-29
			mov dl,10     ;coluna 0-79
			loop_sair:
				call cursor
				mov al,[bx+mens2]
				call caracter
				inc bx      ;proximo caracter
				inc dl      ;avanca a coluna
				loop loop_sair
			pop dx 
			pop cx
			pop bx
			pop ax
			ret
		  
		msg_qw:
			push ax
			push bx
			push cx
			push dx
			mov cx,5     ;número de caracteres
			mov bx,0
			mov dh,12           ;linha 0-29
			mov dl,10     ;coluna 0-79
			loop_qw:
				call cursor
				mov al,[bx+mens3]
				call caracter
				inc bx              ;proximo caracter
				inc dl              ;avanca a coluna
				loop loop_qw
			mov cx,3     			;número de caracteres
			mov bx,0
			mov dh,12           	;linha 0-29
			mov dl,15     			;coluna 0-79
			loop_qw_var:
				call cursor		
				mov al,[bx+var_qw]
				call caracter
				inc bx              ;proximo caracter
				inc dl              ;avanca a coluna
				loop loop_qw_var	
			pop dx 
			pop cx
			pop bx
			pop ax
			ret 
		  
		msg_p:
			push ax
			push bx
			push cx
			push dx
			mov cx,4     			;número de caracteres
			mov bx,0
			mov dh,17           	;linha 0-29
			mov dl,10     			;coluna 0-79
			loop_p:
				call cursor
				mov al,[bx+mens4]
				call caracter
				inc bx              ;proximo caracter
				inc dl              ;avanca a coluna
				loop loop_p	
			mov cx,3     			;número de caracteres
			mov bx,0
			mov dh,17           	;linha 0-29
			mov dl,15     			;coluna 0-79
			loop_p_var:
				call cursor		
				mov al,[bx+var_p]
				call caracter
				inc bx              ;proximo caracter
				inc dl              ;avanca a coluna
				loop loop_p_var	
			pop dx 
			pop cx
			pop bx
			pop ax
			ret 
		  
		msg_qv:
			push ax
			push bx
			push cx
			push dx
			mov cx,5      			;número de caracteres
			mov bx,0
			mov dh,22           	;linha 0-29
			mov dl,10     			;coluna 0-79
			loop_qv:
				call cursor
				mov al,[bx+mens5]
				call caracter
				inc bx              ;proximo caracter
				inc dl              ;avanca a coluna
			loop loop_qv
			mov cx,3     			;número de caracteres
			mov bx,0
			mov dh,22           	;linha 0-29
			mov dl,15     			;coluna 0-79
			loop_qv_var:
				call cursor		
				mov al,[bx+var_qv]
				call caracter
				inc bx              ;proximo caracter
				inc dl              ;avanca a coluna
				loop loop_qv_var
			pop dx 
			pop cx
			pop bx
			pop ax
			ret 
		  
		msg_parametros:
			push ax
			push bx
			push cx
			push dx
			mov cx,49     			;número de caracteres
			mov bx,0
			mov dh,26     			;linha 0-29
			mov dl,28     			;coluna 0-79
			loop_parametros_1:
				call cursor
				mov al,[bx+mens6]
				call caracter
				inc bx              ;proximo caracter
				inc dl              ;avanca a coluna
				cmp byte[bx+mens6], '$'
				jz terminou_msg_parametros ; Fim loop
				loop loop_parametros_1
			mov cx,49     			;número de caracteres
			mov bx,49
			mov dh,27     			;linha 0-29
			mov dl,28     			;coluna 0-79
			loop_identificacao_2:
				call cursor
				mov al,[bx+mens6]
				call caracter
				inc bx              ;proximo caracter
				inc dl              ;avanca a coluna			
				cmp byte[bx+mens6], '$'
				jz terminou_msg_parametros ; Fim loop
				loop loop_identificacao_2
			terminou_msg_parametros:
			pop dx 
			pop cx
			pop bx
			pop ax	
			ret
			
		msg_saturou_qw:
			push ax
			push bx
			push cx
			push dx
			mov cx,49     			;número de caracteres
			mov bx,0
			mov dh,26     			;linha 0-29
			mov dl,28     			;coluna 0-79
			loop_parametros_1_saturou_qw:
				call cursor
				mov al,[bx+mens11]
				call caracter
				inc bx              ;proximo caracter
				inc dl              ;avanca a coluna
				cmp byte[bx+mens11], '$'
				jz terminou_msg_parametros_saturou_qw ; Fim loop
				loop loop_parametros_1_saturou_qw
			mov cx,49     			;número de caracteres
			mov bx,49
			mov dh,27     			;linha 0-29
			mov dl,28     			;coluna 0-79
			loop_identificacao_2_saturou_qw:
				call cursor
				mov al,[bx+mens11]
				call caracter
				inc bx              ;proximo caracter
				inc dl              ;avanca a coluna			
				cmp byte[bx+mens11], '$'
				jz terminou_msg_parametros_saturou_qw ; Fim loop
				loop loop_identificacao_2_saturou_qw
			terminou_msg_parametros_saturou_qw:
			pop dx 
			pop cx
			pop bx
			pop ax	
			ret
			
		msg_saturou_qw_2:
			push ax
			push bx
			push cx
			push dx
			mov cx,49     			;número de caracteres
			mov bx,0
			mov dh,26     			;linha 0-29
			mov dl,28     			;coluna 0-79
			loop_parametros_1_saturou_qw_2:
				call cursor
				mov al,[bx+mens12]
				call caracter
				inc bx              ;proximo caracter
				inc dl              ;avanca a coluna
				cmp byte[bx+mens12], '$'
				jz terminou_msg_parametros_saturou_qw_2 ; Fim loop
				loop loop_parametros_1_saturou_qw_2
			mov cx,49     			;número de caracteres
			mov bx,49
			mov dh,27     			;linha 0-29
			mov dl,28     			;coluna 0-79
			loop_identificacao_2_saturou_qw_2:
				call cursor
				mov al,[bx+mens12]
				call caracter
				inc bx              ;proximo caracter
				inc dl              ;avanca a coluna			
				cmp byte[bx+mens12], '$'
				jz terminou_msg_parametros_saturou_qw_2 ; Fim loop
				loop loop_identificacao_2_saturou_qw_2
			terminou_msg_parametros_saturou_qw_2:
			pop dx 
			pop cx
			pop bx
			pop ax	
			ret	
			
		msg_saturou_p:
			push ax
			push bx
			push cx
			push dx
			mov cx,49     			;número de caracteres
			mov bx,0
			mov dh,26     			;linha 0-29
			mov dl,28     			;coluna 0-79
			loop_parametros_1_saturou_p:
				call cursor
				mov al,[bx+mens9]
				call caracter
				inc bx              ;proximo caracter
				inc dl              ;avanca a coluna
				cmp byte[bx+mens9], '$'
				jz terminou_msg_parametros_saturou_p ; Fim loop
				loop loop_parametros_1_saturou_p
			mov cx,49     			;número de caracteres
			mov bx,49
			mov dh,27     			;linha 0-29
			mov dl,28     			;coluna 0-79
			loop_identificacao_2_saturou_p:
				call cursor
				mov al,[bx+mens9]
				call caracter
				inc bx              ;proximo caracter
				inc dl              ;avanca a coluna			
				cmp byte[bx+mens9], '$'
				jz terminou_msg_parametros_saturou_p ; Fim loop
				loop loop_identificacao_2_saturou_p
			terminou_msg_parametros_saturou_p:
			pop dx 
			pop cx
			pop bx
			pop ax	
			ret
			
		msg_saturou_p_2:
			push ax
			push bx
			push cx
			push dx
			mov cx,49     			;número de caracteres
			mov bx,0
			mov dh,26     			;linha 0-29
			mov dl,28     			;coluna 0-79
			loop_parametros_1_saturou_p_2:
				call cursor
				mov al,[bx+mens10]
				call caracter
				inc bx              ;proximo caracter
				inc dl              ;avanca a coluna
				cmp byte[bx+mens10], '$'
				jz terminou_msg_parametros_saturou_p_2 ; Fim loop
				loop loop_parametros_1_saturou_p_2
			mov cx,49     			;número de caracteres
			mov bx,49
			mov dh,27     			;linha 0-29
			mov dl,28     			;coluna 0-79
			loop_identificacao_2_saturou_p_2:
				call cursor
				mov al,[bx+mens10]
				call caracter
				inc bx              ;proximo caracter
				inc dl              ;avanca a coluna			
				cmp byte[bx+mens10], '$'
				jz terminou_msg_parametros_saturou_p_2 ; Fim loop
				loop loop_identificacao_2_saturou_p_2
			terminou_msg_parametros_saturou_p_2:
			pop dx 
			pop cx
			pop bx
			pop ax	
			ret	
			
		msg_saturou_qv:
			push ax
			push bx
			push cx
			push dx
			mov cx,49     			;número de caracteres
			mov bx,0
			mov dh,26     			;linha 0-29
			mov dl,28     			;coluna 0-79
			loop_parametros_1_saturou_qv:
				call cursor
				mov al,[bx+mens7]
				call caracter
				inc bx              ;proximo caracter
				inc dl              ;avanca a coluna
				cmp byte[bx+mens7], '$'
				jz terminou_msg_parametros_saturou_qv ; Fim loop
				loop loop_parametros_1_saturou_qv
			mov cx,49     			;número de caracteres
			mov bx,49
			mov dh,27     			;linha 0-29
			mov dl,28     			;coluna 0-79
			loop_identificacao_2_saturou_qv:
				call cursor
				mov al,[bx+mens7]
				call caracter
				inc bx              ;proximo caracter
				inc dl              ;avanca a coluna			
				cmp byte[bx+mens7], '$'
				jz terminou_msg_parametros_saturou_qv ; Fim loop
				loop loop_identificacao_2_saturou_qv
			terminou_msg_parametros_saturou_qv:
			pop dx 
			pop cx
			pop bx
			pop ax	
			ret
			
		msg_saturou_qv_2:
			push ax
			push bx
			push cx
			push dx
			mov cx,49     			;número de caracteres
			mov bx,0
			mov dh,26     			;linha 0-29
			mov dl,28     			;coluna 0-79
			loop_parametros_1_saturou_qv_2:
				call cursor
				mov al,[bx+mens8]
				call caracter
				inc bx              ;proximo caracter
				inc dl              ;avanca a coluna
				cmp byte[bx+mens8], '$'
				jz terminou_msg_parametros_saturou_qv_2 ; Fim loop
				loop loop_parametros_1_saturou_qv_2
			mov cx,49     			;número de caracteres
			mov bx,49
			mov dh,27     			;linha 0-29
			mov dl,28     			;coluna 0-79
			loop_identificacao_2_saturou_qv_2:
				call cursor
				mov al,[bx+mens8]
				call caracter
				inc bx              ;proximo caracter
				inc dl              ;avanca a coluna			
				cmp byte[bx+mens8], '$'
				jz terminou_msg_parametros_saturou_qv_2 ; Fim loop
				loop loop_identificacao_2_saturou_qv_2
			terminou_msg_parametros_saturou_qv_2:
			pop dx 
			pop cx
			pop bx
			pop ax	
			ret

		msg_abrindo_arquivo:
			push ax
			push bx
			push cx
			push dx
			mov cx,49     			;número de caracteres
			mov bx,0
			mov dh,26     			;linha 0-29
			mov dl,28     			;coluna 0-79
			loop_msg_botao_abrindo:
				call cursor
				mov al,[bx+mens14]
				call caracter
				inc bx              ;proximo caracter
				inc dl              ;avanca a coluna
				cmp byte[bx+mens14], '$'
				jz terminou_msg_botao_abrindo ; Fim loop
				loop loop_msg_botao_abrindo
			mov cx,49     			;número de caracteres
			mov bx,49
			mov dh,27     			;linha 0-29
			mov dl,28     			;coluna 0-79
			loop_msg_botao_abrindo_2:
				call cursor
				mov al,[bx+mens14]
				call caracter
				inc bx              ;proximo caracter
				inc dl              ;avanca a coluna			
				cmp byte[bx+mens14], '$'
				jz terminou_msg_botao_abrindo ; Fim loop
				loop loop_msg_botao_abrindo_2
			terminou_msg_botao_abrindo:
			pop dx 
			pop cx
			pop bx
			pop ax	
			ret	
			
		msg_arquivo_aberto:
			push ax
			push bx
			push cx
			push dx
			mov cx,49     			;número de caracteres
			mov bx,0
			mov dh,26     			;linha 0-29
			mov dl,28     			;coluna 0-79
			loop_msg_botao_aberto:
				call cursor
				mov al,[bx+mens13]
				call caracter
				inc bx              ;proximo caracter
				inc dl              ;avanca a coluna
				cmp byte[bx+mens13], '$'
				jz terminou_msg_botao_aberto ; Fim loop
				loop loop_msg_botao_aberto
			mov cx,49     			;número de caracteres
			mov bx,49
			mov dh,27     			;linha 0-29
			mov dl,28     			;coluna 0-79
			loop_msg_botao_aberto_2:
				call cursor
				mov al,[bx+mens13]
				call caracter
				inc bx              ;proximo caracter
				inc dl              ;avanca a coluna			
				cmp byte[bx+mens13], '$'
				jz terminou_msg_botao_aberto ; Fim loop
				loop loop_msg_botao_aberto_2
			terminou_msg_botao_aberto:
			pop dx 
			pop cx
			pop bx
			pop ax	
			ret	
			
		msg_arquivo_nao_aberto:
			push ax
			push bx
			push cx
			push dx
			mov cx,49     			;número de caracteres
			mov bx,0
			mov dh,26     			;linha 0-29
			mov dl,28     			;coluna 0-79
			loop_msg_botao_nao_aberto:
				call cursor
				mov al,[bx+mens15]
				call caracter
				inc bx              ;proximo caracter
				inc dl              ;avanca a coluna
				cmp byte[bx+mens15], '$'
				jz terminou_msg_botao_nao_aberto ; Fim loop
				loop loop_msg_botao_nao_aberto
			mov cx,49     			;número de caracteres
			mov bx,49
			mov dh,27     			;linha 0-29
			mov dl,28     			;coluna 0-79
			loop_msg_botao_nao_aberto_2:
				call cursor
				mov al,[bx+mens15]
				call caracter
				inc bx              ;proximo caracter
				inc dl              ;avanca a coluna			
				cmp byte[bx+mens15], '$'
				jz terminou_msg_botao_nao_aberto ; Fim loop
				loop loop_msg_botao_nao_aberto_2
			terminou_msg_botao_nao_aberto:
			pop dx 
			pop cx
			pop bx
			pop ax	
			ret	
			
			


	;***************************************************************
	;                                                              ;
	; 						FUNÇÕES AUXILIARES                     ;
	;	 														   ;
	;***************************************************************
	; Função que plota um ponto
		
		plot_xy:
			push bp
			mov bp,sp
			pushf
			push ax
			push bx
			push cx
			push dx
			push si
			push di
			mov ah,0ch
			mov al,[cor]
			mov bh,0
			mov dx,479
			sub dx,[bp+4]
			mov cx,[bp+6]
			int 10h
			pop di
			pop si
			pop dx
			pop cx
			pop bx
			pop ax
			popf
			pop bp
			ret 4

	;*************************************************************** 
  	;	 														   ;	 
  	; Função que desenha linhas								   ;
  	;	 														   ;
	;***************************************************************

		line:
			push bp
			mov bp,sp
			pushf                        ;coloca os flags na pilha
			push ax
			push bx
			push cx
			push dx
			push si
			push di
			mov ax,[bp+10]   ; resgata os valores das coordenadas
			mov bx,[bp+8]    ; resgata os valores das coordenadas
			mov cx,[bp+6]    ; resgata os valores das coordenadas
			mov dx,[bp+4]    ; resgata os valores das coordenadas
			cmp ax,cx
			je line2
			jb line1
			xchg ax,cx
			xchg bx,dx
			jmp line1
		  
		line2:    ; deltax=0
			cmp bx,dx  ;subtrai dx de bx
			jb line3
			xchg bx,dx        ;troca os valores de bx e dx entre eles
		  
		line3:  ; dx > bx
			push ax
			push bx
			call plot_xy
			cmp bx,dx
			jne line31
			jmp fim_line
			 
		line31: 
			inc bx
			jmp line3
			;deltax <>0
		 
		line1:
			; comparar módulos de deltax e deltay sabendo que cx>ax
			; cx > ax
			push cx
			sub cx,ax
			mov [deltax],cx
			pop cx
			push dx
			sub dx,bx
			ja line32
			neg dx
		
		line32:   
			mov [deltay],dx
			pop dx
			push ax
			mov ax,[deltax]
			cmp ax,[deltay]
			pop ax
			jb line5
			
			; cx > ax e deltax>deltay
			push cx
			sub cx,ax
			mov [deltax],cx
			pop cx
			push dx
			sub dx,bx
			mov [deltay],dx
			pop dx
			mov si,ax
		 
		line4:
			push ax
			push dx
			push si
			sub si,ax ;(x-x1)
			mov ax,[deltay]
			imul si
			mov si,[deltax]   ;arredondar
			shr si,1
			; se numerador (DX)>0 soma se <0 subtrai
			cmp dx,0
			jl ar1
			add ax,si
			adc dx,0
			jmp arc1
		
		ar1:
			sub ax,si
			sbb dx,0
		
		arc1:
			idiv word [deltax]
			add ax,bx
			pop si
			push si
			push ax
			call plot_xy
			pop dx
			pop ax
			cmp si,cx
			je  fim_line
			inc si
			jmp line4
		
		line5:    
			cmp bx,dx
			jb  line7
			xchg ax,cx
			xchg bx,dx
		
		line7:
			push cx
			sub cx,ax
			mov [deltax],cx
			pop cx
			push dx
			sub dx,bx
			mov [deltay],dx
			pop dx
			mov si,bx
		 
		line6:
			push dx
			push si
			push ax
			sub si,bx ;(y-y1)
			mov ax,[deltax]
			imul si
			mov si,[deltay]   ;arredondar
			shr si,1
			; se numerador (DX)>0 soma se <0 subtrai
			cmp dx,0
			jl ar2
			add ax,si
			adc dx,0
			jmp arc2
		  
		ar2:    
			sub ax,si
			sbb dx,0
		
		arc2:
			idiv word [deltay]
			mov di,ax
			pop ax
			add di,ax
			pop si
			push di
			push si
			call plot_xy
			pop dx
			cmp si,dx
			je fim_line
			inc si
			jmp line6
		 
		fim_line:
			pop di
			pop si
			pop dx
			pop cx
			pop bx
			pop ax
			popf
			pop bp
			ret 8 
	 
	;***************************************************************  
	; Função Cursor
	; dh = linha (0-29) e  dl=coluna  (0-79)
		
		cursor:
			pushf
			push ax
			push bx
			push cx
			push dx
			push si
			push di
			push bp
			mov ah,2
			mov bh,0
			int 10h
			pop bp
			pop di
			pop si
			pop dx
			pop cx
			pop bx
			pop ax
			popf
			ret
		
	;***************************************************************
	; Função Caracter
	; al= caracter a ser escrito
	; cor definida na variavel cor
		
		caracter:
			pushf
			push ax
			push bx
			push cx
			push dx
			push si
			push di
			push bp
			mov ah,9
			mov bh,0
			mov cx,1
			mov bl,[cor]
			int 10h
			pop bp
			pop di
			pop si
			pop dx
			pop cx
			pop bx
			pop ax
			popf
			ret 
	  
	;***************************************************************
	;															   ;
	; 						 SAÍDA DO PROGRAMA                     ;
	;															   ;
	;***************************************************************
	  
		sair:

			mov ah,0                ; set video mode
			mov al,[modo_anterior]    ; modo anterior
			int 10h

			xor     ax, ax
		    mov     es, ax
		    mov     ax, [cs_dos]
		    mov     [es:intr*4+2], ax
		    mov     ax, [offset_dos]
		    mov     [es:intr*4], ax 
			sti


			mov ax,4c00h
			int 21h

	;***************************************************************
	;                                                              ;
	;                        SEGMENTO DE DADOS                     ;
	;															   ;
	;***************************************************************  
	  
	segment data

	; Constantes de cores utilizadas
	cor           db    branco_intenso	  

	; I R G B COR
	; 0 0 0 0 preto
	; 0 0 0 1 azul
	; 0 0 1 0 verde
	; 0 0 1 1 cyan
	; 0 1 0 0 vermelho
	; 0 1 0 1 magenta
	; 0 1 1 0 marrom
	; 0 1 1 1 branco
	; 1 0 0 0 cinza
	; 1 0 0 1 azul claro
	; 1 0 1 0 verde claro
	; 1 0 1 1 cyan claro
	; 1 1 0 0 rosa
	; 1 1 0 1 magenta claro
	; 1 1 1 0 amarelo
	; 1 1 1 1 branco intenso

	preto			equ   0
	azul			equ   1
	verde			equ   2
	cyan      		equ   3
	vermelho    	equ   4
	magenta     	equ   5
	marrom      	equ   6
	branco      	equ   7
	cinza     		equ   8
	azul_claro    	equ   9
	verde_claro   	equ   10
	cyan_claro    	equ   11
	rosa      		equ   12
	magenta_claro 	equ   13
	amarelo     	equ   14
	branco_intenso  equ   15
	
	
	modo_anterior 	db    0
	; Variaveis utilizadas na função line
	deltax      	dw    0
	deltay      	dw    0
	  

	; Mensagens do Menu de Funções
	mens1			db    	'Abrir'
	mens2			db      'Sair'
	mens3         	db      'Qw = '
	mens4         	db      'P = '
	mens5         	db      'Qv = '
	mens6         	db      'Aluno: Bruno Bonela                              Sistemas Embarcados - 2018/02                 $'
	mens7         	db      'O valor de Qv chegou ao seu limite de 500!$'
	mens8         	db      'O valor de Qv chegou ao seu valor minimo de 000!$'
	mens9         	db      'O valor de P chegou ao seu limite de 500!$'
	mens10         	db      'O valor de P chegou ao seu valor minimo de 000!$'
	mens11         	db      'O valor de Qw chegou ao seu limite de 500!$'
	mens12         	db      'O valor de Qw chegou ao seu valor minimo de 000!$'
	mens13         	db      'O arquivo "sinais.txt" foi carregado!$'
	mens14         	db      'Carregando o arquivo "sinais.txt"...             Aguarde por favor...$'
	mens15         	db      'Arquivo ainda nao aberto.                        Clique em abrir para ler o arquivo "sinal.txt"$'
	
	var_qw         	db      '010'
	var_p        	db      '040'
	var_qv         	db      '010'
	
	var_inc_dec     		db      '020'
	var_inc_dec_10     		db      '010'
	var_limite_max_qv_qw	db		'490'
	var_limite_min_qv_qw	db		'010'
	var_limite_max_p		db		'500'
	var_limite_min_p		db		'000'


	var_qw_dec 		dw 		010
	var_p_dec 		dw 		040
	var_qv_dec 		dw 		010
	
	  
	; Variáveis para leitura e abertura de arquivo, e processamento dos dados
	file_name		db		'sinalep.txt',0
	file_handle   	dw      0
	aberto        	db    	0
	ascii			db		0
	buffer        	resb  	10
	unidade			db    	0
	dezena			db    	0
	centena			db    	0
	count			dw		0
	deslocamento    db		0
	num_count		dw		0
	decimal			resb	8500	

	; Variaveis plotagem do grafico
	coluna_grafico	dw      0
	x_anterior		db		00
	y_anterior		db		00
	ponto 			db		00
	xant			db		00
	xant1			db		00
	pant			dw		0000
	pprox		 	dw 		0000
	xprox 			dw 		0000

	; Variaveis de limpeza do grafico
	linha_atual   	dw    	0
	coluna_atual  	dw    	0

	; Variaveis de relogio
	eoi     	equ 20h
    intr	   	equ 08h
	char		db	0
	offset_dos	dw	0
	cs_dos		dw	0
	tique		db  0

	;**************************************************************
	
	segment stack stack
	resb    512
	stacktop:

	;**************************************************************  
