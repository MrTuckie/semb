; Pedro Gabriel Gambert da Silva
; Turma 1 de
; Sistemas Embarcados

segment code
..start:
        
mov ax,data
mov ds,ax
mov ax,stack
mov ss,ax
mov sp,stacktop


mov ah,0Fh                            
int 10h
mov [modo_anterior],al   

mov al,12h                           
mov ah,0
int 10h
    

mov byte[cor],branco_intenso 
call menu_inicial

jmp inicializa_mouse

inicializa_mouse:
mov ax,0
int 33h
mov ax,1
int 33h 
checa_clique:
mov ax,5              
mov bx,0
int 33h               
cmp bx,0              
jne trata_clique
jmp checa_clique	
trata_clique:
cmp   cx, 512                                   
jg    localiza_clique
jmp   checa_clique
localiza_clique:
mov al,byte[status_arq]
cmp al,1
je localiza_clique_2
cmp dx,80
jb botao_abrir
cmp dx,160
jb faz_nada
cmp dx,240
jb botao_sair
faz_nada:
jmp checa_clique

localiza_clique_2:

cmp dx,80
jb botao_abrir_rec
cmp dx,160
jb botao_seta
cmp dx,240
jb botao_sair
cmp dx,320
jb botao_fir1
cmp dx,400
jb botao_fir2
cmp dx,480
jb botao_fir3

jmp checa_clique



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; PARTE DOS BOTÕES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; Aumentando o alcance do pulos que são limitados para -128 e 127
botao_abrir:
jmp botao_abrir2
botao_abrir_rec:
jmp botao_abrir_rec2
botao_sair:
jmp botao_sair2
botao_seta:
jmp botao_seta2
botao_fir1:
jmp botao_fir1_2
botao_fir2:
jmp botao_fir2_2
botao_fir3:
jmp botao_fir3_2

botao_abrir2:
    mov byte[cor],amarelo
    call escreve_abrir
    mov byte[cor],branco_intenso
    call escreve_sair
    call imagem_seta

    ; Garantindo que as variáveis estarão devidamente resetadas para
    ; os valores iniciais
    mov byte[auxiliar_seta],0
    mov word[y_anterior],360
    mov word[y_anterior_2],120
    mov word[filtrado_aux],0
    mov word[x_anterior],0
    mov word[x_anterior_2],0
    mov word[auxiliar_arq],0
    mov word[auxiliar_vetor_1],0
    mov word[auxiliar_vetor_2],0
    mov word[y_anterior],360
    mov word[y_anterior_2],120
    mov word[limpa_linha],0
    mov word[limpa_coluna],0
    mov word[anda_em_n],0
    mov word[anda_em_k],0

    mov byte[ascii],0
    mov byte[leitura],0
    mov byte[primeiro_dig],0
    mov byte[segundo_dig],0
    mov byte[terceiro_dig],0
    mov byte[cont_dig],0
    mov byte[deslocamento],0
    mov byte[aux_numero],0
    mov byte[aux_numero_2],0
    mov byte[vetor_de_cima],0
    mov byte[eh_negativo],0
  
    ; Essa parte de abrir o arquivo parece que trava, mas está indo... 
    mov ax,2h
    int 33h
    mov al,byte[status_arq]     
    cmp al,0
        je  abrindo       
    call limpa_grafico

    mov bx,[auxiliar_arq]
    mov ah,3eh
    mov al,00h
    int 21h

    abrindo:
        call abre_arquivo
        call plota_em_cima
        mov byte[cor],branco_intenso
        call escreve_abrir

        ; Mostra mouse
        mov ax,1h
        int 33h 
        jmp checa_clique
        

botao_abrir_rec2: 

    mov byte[cor],amarelo
    call escreve_abrir
    mov byte[status_arq], 0

    ; Vou reinicar as variáveis para evitar qualquer problema
    mov byte[x_anterior], 0 
    mov word[auxiliar_vetor_1], 0
    mov byte[x_anterior_2], 0 
    mov word[auxiliar_vetor_2], 0
    mov byte[auxiliar_escolhe], 0
    mov word[aux_numero],0
    mov word[aux_numero_2],0
    mov word[anda_em_k], 0
    mov word[anda_em_n], 0
    mov byte[leitura],0
    

    call limpa_vetor
    call limpa_grafico
    call menu_inicial
    jmp checa_clique

botao_seta2: 
    inc byte[auxiliar_seta]
    xor ax,ax
    mov al,byte[auxiliar_seta]
    cmp al,9
        jge faz_nada_seta
    mov byte[cor],amarelo
    call imagem_seta
    mov byte[cor],branco_intenso
    call escreve_abrir
    call escreve_sair	

    call limpa_grafico
    call menu_inicial
    call plota_em_cima
    call plota_em_baixo
    faz_nada_seta:
    mov ax,1h
    int 33h 
    jmp checa_clique


botao_sair2:
    mov byte[cor],amarelo
    call escreve_sair
    mov byte[cor],branco_intenso
    call escreve_abrir
    call imagem_seta

    mov ax,1h
    int 33h 

    jmp sair

botao_fir1_2:
    ; verifica se ha um filtro aberto
    cmp byte[auxiliar_escolhe], 1
        je faz_nada_seta
    mov byte[cor],amarelo
    call escreve_fir_1
    mov byte[cor],branco_intenso
    call escreve_abrir
    call imagem_seta
	call escreve_fir_2
	call escreve_fir_3

    call filtra_1
    ; ajusta a escala do filtro
    push bx
    mov bl, byte[fator_pbaixa]
    mov byte[fator_f_geral], bl
    pop bx
    call plota_em_baixo

    mov byte[cor],branco_intenso
    call escreve_fir_1
    ; seta a flag de filtro ativo
    mov byte[auxiliar_escolhe], 1

    mov byte[cor],branco_intenso
    call escreve_fir_1

    mov ax,1h
    int 33h 

    jmp checa_clique

botao_fir2_2:
    ; verifica se ha um filtro aberto
    cmp byte[auxiliar_escolhe], 1
        je faz_nada_filtro
    mov byte[cor],amarelo
    call escreve_fir_2
    mov byte[cor],branco_intenso
    call escreve_abrir
    call imagem_seta
	call escreve_fir_1
	call escreve_fir_3

    call filtra_2
    ; ajusta a escala do filtro
    push bx
    mov bl, byte[fator_pbanda]
    mov byte[fator_f_geral], bl
    pop bx
    call plota_em_baixo

    mov byte[cor],branco_intenso
    call escreve_fir_2
    ; seta a flag de filtro ativo
    mov byte[auxiliar_escolhe], 1
    mov byte[cor],branco_intenso
    call escreve_fir_2

    mov ax,1h
    int 33h 

    jmp checa_clique

faz_nada_filtro:
    mov ax,1h
    int 33h 

    jmp checa_clique

botao_fir3_2:
    ; verifica se ha um filtro aberto
    cmp byte[auxiliar_escolhe], 1
        je faz_nada_filtro
    mov byte[cor],amarelo
    call escreve_fir_3
    mov byte[cor],branco_intenso
    call escreve_abrir
    call imagem_seta
	call escreve_fir_1
	call escreve_fir_2

    call filtra_3

    ; ajusta a escala do filtro
    push bx
    mov bl, byte[fator_palta]
    mov byte[fator_f_geral], bl
    pop bx
    call plota_em_baixo

    mov byte[cor],branco_intenso
    call escreve_fir_3

    ; seta a flag de filtro ativo
    mov byte[auxiliar_escolhe], 1
    mov byte[cor],branco_intenso
    call escreve_fir_3

    mov ax,1h
    int 33h 

    jmp checa_clique

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FIM DA PARTE DOS BOTÕES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; PARTE DE ABRIR O ARQUIVO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CONVERTER E SALVAR E ETC ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    abre_arquivo:
        
        pushf
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push bp
        
        ; Zera o contador de numeros lidos
        mov	word[aux_numero],0
        
        ; Abrir arquivo somente para leitura
        mov ah,3dh        
        mov al,00h
        mov dx,nome_arquivo
        int 21h
        mov [auxiliar_arq],ax
        
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
			
; Deu certo, aparentemente
abriu_corretamente:

    mov byte[status_arq],1

    proximo_byte:
        ; Lendo o dígito do texto
        mov bx,[auxiliar_arq]
        mov dx,leitura
        mov cx,1
        mov ah,3Fh
        int 21h
        cmp ax,cx
            jne final_arquivo
        ; Variável salva
        mov al,byte[leitura] 
        mov byte[ascii],al  
        mov bl, byte[cont_dig]
        
        ; push al
        ; mov al,byte[leitura] 
        ; mov byte[ascii],al  
        ; mov bl, byte[cont_dig]  
        ; pop al

        cmp al, '-' 
            je is_neg
        jmp is_not_neg
            is_neg:
                mov byte[eh_negativo],1
                jmp proximo_byte
        is_not_neg:
            cmp al, 32 
                je proximo_byte
            cmp al, '.'
                je proximo_byte
            cmp bl, 3 
                jne continua_lendo
            cmp al, 'e'
                jne proximo_byte
        
        ; Andando pelo texto para pegar a parte importante

        mov bx,[auxiliar_arq]
        mov dx,leitura
        mov cx,1
        mov ah,3Fh
        int 21h
        mov bx,[auxiliar_arq]
        mov dx,leitura
        mov cx,1
        mov ah,3Fh
        int 21h
        mov bx,[auxiliar_arq]
        mov dx,leitura
        mov cx,1
        mov ah,3Fh
        int 21h

        mov al,byte[leitura] 
        mov byte[deslocamento],al 
        call junta_digitos
        mov	byte[cont_dig],0
        jmp proximo_byte
    
        ; Continua lendo o arquivo
        continua_lendo:
            ; converte
            call 	ascii2decimal
            inc		bl
            mov		byte[cont_dig],bl
            jmp 	proximo_byte
                    
        ; Fechando
        final_arquivo:
            mov bx,[auxiliar_arq]
            mov ah,3eh
            mov al,00h
            int 21h
            
        pop		bp
        pop		di
        pop		si
        pop		dx
        pop		cx
        pop		bx
        pop		ax
        popf
        ret

    ; Conversão usando o material do lab
		ascii2decimal:
			pushf
			push 	ax
			push 	bx
			push	cx
			push	dx
			push	si
			push	di
			push	bp
			
			xor 	cx,cx
			mov 	al,[ascii]
			sub 	al,30h  ; deslocando o valor da tabela ascii
			mov 	cl,byte[primeiro_dig] 
			mov 	ch,byte[segundo_dig]
			mov 	byte[primeiro_dig],al
			mov 	byte[segundo_dig],cl
			mov 	byte[terceiro_dig],ch

			pop		bp
			pop		di
			pop		si
			pop		dx
			pop		cx
			pop		bx
			pop		ax
			popf
			ret
	
            junta_digitos:  
            
                pushf
                push 	ax
                push 	bx
                push	cx
                push	dx
                push	si
                push	di
                push	bp
                
                xor		ax,ax
                xor		bx,bx
                xor		cx,cx
                xor		dx,dx	
                xor 	ah,ah
                xor 	ch,ch
                
                mov 	bl,byte[deslocamento]	
                
                cmp bl, '2'
                    je numero_3	
                cmp bl, '1'
                    je numero_2	
                jmp	numero_1
                    
                numero_3:

                mov 	al,byte[terceiro_dig]
                mov 	bl,100
                mul 	bl		
                mov 	cx,ax	
                
                xor 	ah,ah
                mov 	al,byte[segundo_dig]
                mov 	bl,10
                mul 	bl	
                add 	cx,ax	
                
                xor 	ah,ah
                mov 	al,[primeiro_dig]
                add 	cx,ax 
                
                jmp final_juncao
                
                numero_2:

                mov 	al,byte[terceiro_dig]
                mov 	bl,10
                mul 	bl
                mov 	cx,ax	
                
                xor 	ah,ah
                mov 	al,byte[segundo_dig]
                add 	cx,ax	
                
                jmp final_juncao
                
                numero_1:
                
                mov 	al,byte[terceiro_dig]
                mov 	cx,ax	
                
                final_juncao:	

                xor ax,ax
                mov al,byte[eh_negativo]
                cmp al, 1
                    je add_offset
                    jmp no_offset
                    add_offset:
                    or cl,128
                    
                no_offset:

                mov byte[eh_negativo],0

                mov		bx, word[aux_numero]
                
                mov 	byte[vetor_de_cima+bx],cl

                inc 	bx
                mov		word[aux_numero],bx		

                mov 	byte[primeiro_dig],0
                mov 	byte[segundo_dig],0
                mov 	byte[terceiro_dig],0
                
                 
                pop		bp
                pop		di
                pop		si
                pop		dx
                pop		cx
                pop		bx
                pop		ax
                popf
                ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FIM PARTE DE ABRIR O ARQUIVO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; PARTE GRÁFICA DO MENU ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

menu_inicial:     
    call desenha_menu
    call cria_mensagens
    ret 
cria_mensagens:
    call escreve_abrir
    call escreve_sair
    call imagem_seta
    call escreve_fir_1
    call escreve_fir_2
    call escreve_fir_3
    ret
	 
         
    desenha_menu:
        push ax       
        push bx       
        push cx       
        push dx       
        push si       
        push di   

        mov byte[cor],branco_intenso

         
        mov ax,0                        
        push ax
        mov ax,240
        push ax
        mov ax,639
        push ax
        mov ax,240
        push ax
        call line
         
        mov ax,0                        
        push ax
        mov ax,479
        push ax
        mov ax,639
        push ax
        mov ax,479
        push ax
        call line

        
         
        mov ax,639             
        push ax
        mov ax,0
        push ax
        mov ax,639
        push ax
        mov ax,479
        push ax
        call line
            
         
        mov ax,0             
        push ax
        mov ax,0
        push ax
        mov ax,639
        push ax
        mov ax,0
        push ax
        call line

                
         
        mov ax,0              
        push ax
        mov ax,0
        push ax
        mov ax,0
        push ax
        mov ax,479
        push ax
        call line
                
         
        mov ax, 512                      
        push ax
        mov ax,639
        push ax
        mov ax, 512
        push ax
        mov ax,0
        push ax
        call line
            
         
        mov ax, 512                     
        push ax
        mov ax,80
        push ax
        mov ax, 639
        push ax
        mov ax,80
        push ax
        call line
        
         
        mov ax, 512                      
        push ax
        mov ax,160
        push ax
        mov ax, 640
        push ax
        mov ax,160
        push ax
        call line
        
         
        mov ax, 512                
        push ax
        mov ax,400
        push ax
        mov ax, 640
        push ax
        mov ax,400
        push ax
        call line
            
         
        mov ax, 512                      
        push ax
        mov ax,320
        push ax
        mov ax, 640
        push ax
        mov ax,320
        push ax
        call line
        
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax

        ret   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FIM DA PARTE GRÁFICA DO MENU ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; PARTE GRÁFICA DO SINAL ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		plota_em_cima:
			 
			pushf
			push ax
			push bx
			push cx
			push dx
			push si
			push di
			push bp
			mov byte[cor],branco_intenso
			mov bx, word[auxiliar_vetor_1]
			cmp bx, word[aux_numero]
				jle coluna_valida
			mov word[auxiliar_vetor_1], 0

			coluna_valida:	
                
                mov bx, -1
                mov cx, 512	
                mov byte[cor],branco_intenso

                printar:

                     
                    ; cmp cx,510
                    ;     je reseta_eixo_x
                    ; jmp segue_sem_resetar
                    ; reseta_eixo_x:
                    ; xor bx,bx 
                    ; sub word[y_anterior], 240

                    segue_sem_resetar:

                        ; x1
                        mov ax, bx
                        add ax,1	
                        push ax
                        
                        ; y1
                        mov ah, 0
                        mov ax, word[y_anterior]
                        push ax

                        ; x2
                        inc bx
                        mov ax, bx
                        ;add ax,1
                        mov byte[x_anterior], bl ; tá de enfeite
                        push ax

                        ; Pegando o valor que está em vetor_de_cima e jogando para dl
                        push bx			
                        mov bx, word[auxiliar_vetor_1]
                        mov dh, 0
                        mov dl, byte[vetor_de_cima+bx]
                        inc bx
                        mov word[auxiliar_vetor_1], bx			
                        pop bx

                        ; Desconversão do valor que estava em vetor_de_cima                     
                        cmp dl,127 
                            ja conv_negativo  
                        jmp conv_positivo      

                        conv_negativo:
                            and dx,127   
                        cmp dx,0     
                            je add_one
                        jmp no_add_one
                            add_one:
                                or dx, 128
                        no_add_one:	
                             
                            ; escalando o gráfico
                            mov ax,dx
                            xor dx,dx
                            div byte[fator_de_cima]  
                            mov dl,al  
                                
                            ; jogando para baixo    
                            mov ax,360
                            sub ax,dx
                            jmp conv_final

                        conv_positivo:

                            mov ax,dx
                            idiv byte[fator_de_cima]
                            xor ah,ah   
                            add ax,360  

                        conv_final:
                            
                            ; enviando y2
                            mov word[y_anterior], ax 
                            push ax
                            call line    

                            dec cx
                            cmp cx,0
                                jne printar_2
                            jmp out_printar

                    printar_2:
                        jmp printar
                    out_printar:
				
			mov byte[cor],branco_intenso		

			 
			pop		bp
			pop		di
			pop		si
			pop		dx
			pop		cx
			pop		bx
			pop		ax
			popf
			ret

            filtra_1:

            pushf
			push ax
			push bx
			push cx
			push dx
			push si
			push di
			push bp

            xor ax,ax
            xor bx,bx
            xor cx,cx
            xor dx,dx

            ; Setup das variáveis
            ; achei engraçado q se eu colocar 512 para 4104, ele não funciona...
            mov cx, 4104 
            mov word[anda_em_k],0
            mov word[anda_em_n],0
            mov word[aux_numero_2],0


            ; aqui vai ficar a parte de escolher qual fir_vetor vai ser usado, vou usar o primeiro para ficar mais
            ; simples de proceder

            loop_anda_n_a: ; vai rodar 4096 vezes

                push cx ; salva cx colocar o outro contador
                mov cx, 9 ; de início, vai rodar 9 vezes, mas sai se !(n>=k) 
                
                loop_anda_k_a:

                    ; funciona essas 4 linhas
                    mov bx,word[anda_em_k]          ; bx vai ser k
                    mov al, byte[passa_baixa+bx] ; al é o h[k], podendo ser negativo. 8 bit
                    mov bx,word[anda_em_n]              ; bx se torna n
                    sub bx, word[anda_em_k]         ; bx se torna n-k

                    ; funciona pegar de vetor_de_cima (com sinal corrigido)
                    mov dx, 0                   ; dx = 0
                    mov dl, byte[vetor_de_cima+bx]    ; dl = x[n-k], podendo ser negativo depois da conversão. 8 bit
                    cmp dl,127 
                        ja conv_negativo_2_a  
                    jmp no_add_one_2_a      

                    conv_negativo_2_a:
                        and dl,127
                        neg dl                  ; um jeito de converter mais facilmente      
                    cmp dl,0     
                        je add_one_2_a
                    jmp no_add_one_2_a
                        add_one_2_a:
                            or dl, 128
                    no_add_one_2_a:

                    ; parte da multiplicação

                    imul dl	                    ; dl = x[n-k], al = h[k] -> ax = h[k]*x[n-k]
                    add word[filtrado_aux],ax
                    
                    ; parte da comparação
                    inc word[anda_em_k]             ; k+=1
                    mov dx,word[anda_em_k]
                    mov bx, word[anda_em_n]             ; joga o valor de n de volta no bx   

                    cmp bx,dx ; se !(n>=k)
                        jnge out_loop_anda_k_a ; sai do loop

                loop loop_anda_k_a

                out_loop_anda_k_a:

                mov word[anda_em_k],0 ; reseta o anda_em_k
                inc word[anda_em_n] ; n+=1
                pop cx ; pega o cx de volta para o outro loop

                ; inserção dos dados
                ; essas 5 linhas estão ok
                mov     ax, word[filtrado_aux]
                mov		bx, word[aux_numero_2]   ; pega o valor do auxiliar para andar no vetor filtrado
                mov 	word[filtrado+bx],ax    ; joga o valor de ax no vetor na posição certa
                inc     bx
                inc 	bx                      ; incrementa o valor do reg auxiliar
                mov		word[aux_numero_2],bx	    ; salva ele na variável auxiliar
                mov word[filtrado_aux], 0

                ; essa parte aqui está funcionando q é uma beleza, mas é só para exemplo
                ; ela serve para testar o printar_filtro
                    ; mov		bx, word[aux_numero_2]   ; pega o valor do auxiliar para andar no vetor filtrado
                    ; mov		ax, word[aux_numero_2]
                    ; neg     ax
                    ; mov 	word[filtrado+bx],ax    ; joga o valor de ax no vetor na posição certa
                    ; inc     bx
                    ; inc 	bx                      ; incrementa o valor do reg auxiliar
                    ; mov		word[aux_numero_2],bx	    ; salva ele na variável auxiliar   

            loop loop_anda_n_a
            out_loop_anda_n_a:
            
            ;mov word[aux_numero_2], 0 ; reseta o contador


            pop		bp
			pop		di
			pop		si
			pop		dx
			pop		cx
			pop		bx
			pop		ax
			popf
			ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        filtra_2:

            pushf
			push ax
			push bx
			push cx
			push dx
			push si
			push di
			push bp

            xor ax,ax
            xor bx,bx
            xor cx,cx
            xor dx,dx

            ; Setup das variáveis
            ; achei engraçado q se eu colocar 512 para 4104, ele não funciona...
            mov cx, 4104 
            mov word[anda_em_k],0
            mov word[anda_em_n],0
            mov word[aux_numero_2],0


            ; aqui vai ficar a parte de escolher qual fir_vetor vai ser usado, vou usar o primeiro para ficar mais
            ; simples de proceder

            loop_anda_n_b: ; vai rodar 4096 vezes

                push cx ; salva cx colocar o outro contador
                mov cx, 9 ; de início, vai rodar 9 vezes, mas sai se !(n>=k) 
                
                loop_anda_k_b:

                    ; funciona essas 4 linhas
                    mov bx,word[anda_em_k]          ; bx vai ser k
                    mov al, byte[passa_banda+bx] ; al é o h[k], podendo ser negativo. 8 bit
                    mov bx,word[anda_em_n]              ; bx se torna n
                    sub bx, word[anda_em_k]         ; bx se torna n-k

                    ; funciona pegar de vetor_de_cima (com sinal corrigido)
                    mov dx, 0                   ; dx = 0
                    mov dl, byte[vetor_de_cima+bx]    ; dl = x[n-k], podendo ser negativo depois da conversão. 8 bit
                    cmp dl,127 
                        ja conv_negativo_2_b  
                    jmp no_add_one_2_b      

                    conv_negativo_2_b:
                        and dl,127
                        neg dl                  ; um jeito de converter mais facilmente      
                    cmp dl,0     
                        je add_one_2_b
                    jmp no_add_one_2_b
                        add_one_2_b:
                            or dl, 128
                    no_add_one_2_b:

                    ; parte da multiplicação

                    imul dl	                    ; dl = x[n-k], al = h[k] -> ax = h[k]*x[n-k]
                    add word[filtrado_aux],ax
                    
                    ; parte da comparação
                    inc word[anda_em_k]             ; k+=1
                    mov dx,word[anda_em_k]
                    mov bx, word[anda_em_n]             ; joga o valor de n de volta no bx   

                    cmp bx,dx ; se !(n>=k)
                        jnge out_loop_anda_k_b ; sai do loop

                loop loop_anda_k_b

                out_loop_anda_k_b:

                mov word[anda_em_k],0 ; reseta o anda_em_k
                inc word[anda_em_n] ; n+=1
                pop cx ; pega o cx de volta para o outro loop

                ; inserção dos dados
                ; essas 5 linhas estão ok
                mov     ax, word[filtrado_aux]
                mov		bx, word[aux_numero_2]   ; pega o valor do auxiliar para andar no vetor filtrado
                mov 	word[filtrado+bx],ax    ; joga o valor de ax no vetor na posição certa
                inc     bx
                inc 	bx                      ; incrementa o valor do reg auxiliar
                mov		word[aux_numero_2],bx	    ; salva ele na variável auxiliar
                mov word[filtrado_aux], 0

                ; essa parte aqui está funcionando q é uma beleza, mas é só para exemplo
                ; ela serve para testar o printar_filtro
                    ; mov		bx, word[aux_numero_2]   ; pega o valor do auxiliar para andar no vetor filtrado
                    ; mov		ax, word[aux_numero_2]
                    ; neg     ax
                    ; mov 	word[filtrado+bx],ax    ; joga o valor de ax no vetor na posição certa
                    ; inc     bx
                    ; inc 	bx                      ; incrementa o valor do reg auxiliar
                    ; mov		word[aux_numero_2],bx	    ; salva ele na variável auxiliar   

            loop loop_anda_n_b
            out_loop_anda_n_b:
            
            ;mov word[aux_numero_2], 0 ; reseta o contador


            pop		bp
			pop		di
			pop		si
			pop		dx
			pop		cx
			pop		bx
			pop		ax
			popf
			ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        filtra_3:

            pushf
			push ax
			push bx
			push cx
			push dx
			push si
			push di
			push bp

            xor ax,ax
            xor bx,bx
            xor cx,cx
            xor dx,dx

            ; Setup das variáveis
            ; achei engraçado q se eu colocar 512 para 4104, ele não funciona...
            mov cx, 4104 
            mov word[anda_em_k],0
            mov word[anda_em_n],0
            mov word[aux_numero_2],0


            ; aqui vai ficar a parte de escolher qual fir_vetor vai ser usado, vou usar o primeiro para ficar mais
            ; simples de proceder

            loop_anda_n_c: ; vai rodar 4096 vezes

                push cx ; salva cx colocar o outro contador
                mov cx, 9 ; de início, vai rodar 9 vezes, mas sai se !(n>=k) 
                
                loop_anda_k_c:

                    ; funciona essas 4 linhas
                    mov bx,word[anda_em_k]          ; bx vai ser k
                    mov al, byte[passa_alta+bx] ; al é o h[k], podendo ser negativo. 8 bit
                    mov bx,word[anda_em_n]              ; bx se torna n
                    sub bx, word[anda_em_k]         ; bx se torna n-k

                    ; funciona pegar de vetor_de_cima (com sinal corrigido)
                    mov dx, 0                   ; dx = 0
                    mov dl, byte[vetor_de_cima+bx]    ; dl = x[n-k], podendo ser negativo depois da conversão. 8 bit
                    cmp dl,127 
                        ja conv_negativo_2_c  
                    jmp no_add_one_2_c      

                    conv_negativo_2_c:
                        and dl,127
                        neg dl                  ; um jeito de converter mais facilmente      
                    cmp dl,0     
                        je add_one_2_c
                    jmp no_add_one_2_c
                        add_one_2_c:
                            or dl, 128
                    no_add_one_2_c:

                    ; parte da multiplicação

                    imul dl	                    ; dl = x[n-k], al = h[k] -> ax = h[k]*x[n-k]
                    add word[filtrado_aux],ax
                    
                    ; parte da comparação
                    inc word[anda_em_k]             ; k+=1
                    mov dx,word[anda_em_k]
                    mov bx, word[anda_em_n]             ; joga o valor de n de volta no bx   

                    cmp bx,dx ; se !(n>=k)
                        jnge out_loop_anda_k_c ; sai do loop

                loop loop_anda_k_c

                out_loop_anda_k_c:

                mov word[anda_em_k],0 ; reseta o anda_em_k
                inc word[anda_em_n] ; n+=1
                pop cx ; pega o cx de volta para o outro loop

                ; inserção dos dados
                ; essas 5 linhas estão ok
                mov     ax, word[filtrado_aux]
                mov		bx, word[aux_numero_2]   ; pega o valor do auxiliar para andar no vetor filtrado
                mov 	word[filtrado+bx],0    ; joga o valor de ax no vetor na posição certa
                mov 	word[filtrado+bx],ax    ; joga o valor de ax no vetor na posição certa
                inc     bx
                inc 	bx                      ; incrementa o valor do reg auxiliar
                mov		word[aux_numero_2],bx	    ; salva ele na variável auxiliar
                mov word[filtrado_aux], 0

                ; essa parte aqui está funcionando q é uma beleza, mas é só para exemplo
                ; ela serve para testar o printar_filtro
                    ; mov		bx, word[aux_numero_2]   ; pega o valor do auxiliar para andar no vetor filtrado
                    ; mov		ax, word[aux_numero_2]
                    ; neg     ax
                    ; mov 	word[filtrado+bx],ax    ; joga o valor de ax no vetor na posição certa
                    ; inc     bx
                    ; inc 	bx                      ; incrementa o valor do reg auxiliar
                    ; mov		word[aux_numero_2],bx	    ; salva ele na variável auxiliar   

            loop loop_anda_n_c
            out_loop_anda_n_c:
            
            ;mov word[aux_numero_2], 0 ; reseta o contador


            pop		bp
			pop		di
			pop		si
			pop		dx
			pop		cx
			pop		bx
			pop		ax
			popf
			ret

limpa_vetor:
            pushf
			push ax
			push bx
			push cx
			push dx
			push si
			push di
			push bp

            mov cx,4096
            mov word[aux_numero_2],0
            loop_limpa_vetor:
            mov		bx, word[aux_numero_2]   ; pega o valor do auxiliar para andar no vetor filtrado
            mov 	byte[vetor_de_cima+bx],0    ; joga o valor de ax no vetor na posição certa
            inc     bx
            mov		word[aux_numero_2],bx	    ; salva ele na variável auxiliar
            loop loop_limpa_vetor
            mov word[aux_numero_2],0
            pop		bp
			pop		di
			pop		si
			pop		dx
			pop		cx
			pop		bx
			pop		ax
			popf
			ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;

            plota_em_baixo:
			 
			pushf
			push ax
			push bx
			push cx
			push dx
			push si
			push di
			push bp
			mov byte[cor],branco_intenso
			mov bx, word[auxiliar_vetor_2]
			cmp bx, word[aux_numero_2]
				jle coluna_valida_2
			mov word[auxiliar_vetor_2], 0

			coluna_valida_2:	
                
                mov bx, -1
                mov cx, 512	
                mov byte[cor],branco_intenso

                printar_filtro:

                    mov byte[cor],branco_intenso


                    segue_sem_resetar_2:

                        ; x1
                        mov ax, bx
                        add ax,1	
                        push ax
                        
                        ; y1
                        mov ah, 0
                        mov ax, word[y_anterior_2]
                        push ax

                        ; x2
                        inc bx
                        mov ax, bx
                        ;add ax,1
                        mov byte[x_anterior_2], bl
                        push ax

                        ; Pegando o valor que está em vetor_de_cima e jogando para dl
                        push bx			
                        mov bx, word[auxiliar_vetor_2]
                        mov dx, word[filtrado+bx]
                        add bx,2
                        mov word[auxiliar_vetor_2], bx			
                        pop bx

                        mov ax,dx
                        xor dx,dx
                        idiv byte[fator_f_geral]
                        xor ah,ah
                        test al,al
                        jns sou_positivo
                        ;jmp sou_fim

                        sou_negativo:
                        neg al
                        mov dl,120
                        sub dl,al
                        mov al,dl
                        jmp sou_fim

                        sou_positivo:
                               
                            add ax,120  
                            
                        sou_fim:    
                            ; enviando y2
                            mov word[y_anterior_2], ax 
                            push ax
                            call line    

                            dec cx
                            cmp cx,0
                                jne printar_filtro_2
                            jmp out_printar_2

                    printar_filtro_2:
                        jmp printar_filtro
                    out_printar_2:
				
			mov byte[cor],branco_intenso		

			 
			pop		bp
			pop		di
			pop		si
			pop		dx
			pop		cx
			pop		bx
			pop		ax
			popf
			ret
	
            limpa_grafico:    
                push    cx     
                push    ax
                push    dx
                push    bx
                mov word[limpa_linha],1
                mov word[limpa_coluna],0
                
                mov cx,477       
                
                linhas:

                    push cx
                    mov cx, 511        
                        colunas:
                            call plota_pixel    
                            inc word[limpa_coluna]
                            loop colunas
                    inc word[limpa_linha]

                    mov ax, word[limpa_linha]
                    cmp ax,240
                        je dec_linha
                        jmp segue_linha
                        dec_linha:
                        inc word[limpa_linha]
                    segue_linha:
                    
                    mov word[limpa_coluna],0
                    pop cx
                    loop linhas
                pop   bx
                pop   dx
                pop   ax    
                pop   cx
                ret

            plota_pixel:  
                push ax
                push bx
                push dx
                mov byte[cor],preto   
                mov bx,[limpa_coluna]
                add bx,1
                push bx       
                mov bx,[limpa_linha]
                push bx       
                call plot_xy
                pop dx
                pop bx
                pop ax
                ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FIM DA PARTE GRÁFICA DO SINAL ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; PARTE GRÁFICA DAS PALAVRAS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        escreve_abrir:
             
            push ax
            push bx
            push cx
            push dx
            mov cx,5      
            mov bx,0
            mov dh,2      
            mov dl,70      
            loop_abrir:
                call cursor
                mov al,[bx+palavra1]
                call  caracter
                inc bx      
                inc dl     
            loop loop_abrir
            pop dx 
            pop cx
            pop bx
            pop ax
            ret

        escreve_sair:
            push ax
            push bx
            push cx
            push dx
            mov cx,4      
            mov bx,0
            mov dh,12      
            mov dl,70      
            loop_sair:
                call cursor
                mov al,[bx+palavra2]
                call caracter
                inc bx       
                inc dl       
            loop loop_sair
            pop dx 
            pop cx
            pop bx
            pop ax
            ret
        
        imagem_seta:
            push ax
            push bx
            push cx
            push dx

            mov ax, 555                      
            push ax
            mov ax, 362
            push ax
            mov ax, 621  
            push ax
            mov ax, 362
            push ax
            call line

            mov ax, 621                      
            push ax
            mov ax, 362
            push ax
            mov ax, 621  
            push ax
            mov ax, 372
            push ax
            call line

            mov ax, 621                      
            push ax
            mov ax, 372
            push ax
            mov ax, 627  
            push ax
            mov ax, 357
            push ax
            call line

            mov ax, 627                      
            push ax
            mov ax, 357
            push ax
            mov ax, 621  
            push ax
            mov ax, 342
            push ax
            call line

            mov ax, 621                      
            push ax
            mov ax, 342
            push ax
            mov ax, 621  
            push ax
            mov ax, 352
            push ax
            call line

            mov ax, 621                      
            push ax
            mov ax, 352
            push ax
            mov ax, 555  
            push ax
            mov ax, 352
            push ax
            call line

            mov ax, 555                      
            push ax
            mov ax, 352
            push ax
            mov ax, 555  
            push ax
            mov ax, 362
            push ax
            call line
            
            pop dx 
            pop cx
            pop bx
            pop ax
            ret

        escreve_fir_1:
             
            push ax
            push bx
            push cx
            push dx
            mov cx,5      
            mov bx,0
            mov dh,17      
            mov dl,70     
            loop_msg_fir1:
                call cursor
                mov al,[bx+palavra3]
                call  caracter
                inc bx      
                inc dl     
            loop loop_msg_fir1
            pop dx 
            pop cx
            pop bx
            pop ax
            ret

        escreve_fir_2:
             
            push ax
            push bx
            push cx
            push dx
            mov cx,5      
            mov bx,0
            mov dh,22      
            mov dl,70      
            loop_msg_fir2:
                call cursor
                mov al,[bx+palavra4]
                call  caracter
                inc bx      
                inc dl     
            loop loop_msg_fir2
            pop dx 
            pop cx
            pop bx
            pop ax
            ret

        escreve_fir_3:
             
            push ax
            push bx
            push cx
            push dx
            mov cx,5      
            mov bx,0
            mov dh,27      
            mov dl,70      
            loop_msg_fir3:
                call cursor
                mov al,[bx+palavra5]
                call  caracter
                inc bx      
                inc dl     
            loop loop_msg_fir3
            pop dx 
            pop cx
            pop bx
            pop ax
            ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FIM DA PARTE GRÁFICA DAS PALAVRAS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; linec.asm ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	 
;
;   fun��o cursor
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
;   fun��o caracter escrito na posi��o do cursor
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
;   fun��o plot_xy
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
;    fun��o circle
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
	mov		dx,0  	;dx ser� a vari�vel x. cx � a variavel y
	
;aqui em cima a l�gica foi invertida, 1-r => r-1
;e as compara��es passaram a ser jl => jg, assim garante 
;valores positivos para d

stay:				;loop
	mov		si,di
	cmp		si,0
	jg		inf       ;caso d for menor que 0, seleciona pixel superior (n�o  salta)
	mov		si,dx		;o jl � importante porque trata-se de conta com sinal
	sal		si,1		;multiplica por doi (shift arithmetic left)
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
	call plot_xy		;toma conta do s�timo octante
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
	jb		fim_circle  ;se cx (y) est� abaixo de dx (x), termina     
	jmp		stay		;se cx (y) est� acima de dx (x), continua no loop
	
	
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
;    fun��o full_circle
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
	mov		dx,0  	;dx ser� a vari�vel x. cx � a variavel y
	
;aqui em cima a l�gica foi invertida, 1-r => r-1
;e as compara��es passaram a ser jl => jg, assim garante 
;valores positivos para d

stay_full:				;loop
	mov		si,di
	cmp		si,0
	jg		inf_full       ;caso d for menor que 0, seleciona pixel superior (n�o  salta)
	mov		si,dx		;o jl � importante porque trata-se de conta com sinal
	sal		si,1		;multiplica por doi (shift arithmetic left)
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
	jb		fim_full_circle  ;se cx (y) est� abaixo de dx (x), termina     
	jmp		stay_full		;se cx (y) est� acima de dx (x), continua no loop
	
	
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
;   fun��o line
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
; comparar m�dulos de deltax e deltay sabendo que cx>ax
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
		push	dx
		push	si
		push	ax
		sub		si,bx	;(y-y1)
		mov		ax,[deltax]
		imul	si
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
		idiv	word [deltay]
		mov		di,ax
		pop		ax
		add		di,ax
		pop		si
		push	di
		push	si
		call	plot_xy
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
	  
		sair:

			mov ah,0                ; set video mode
			mov al,[modo_anterior]    ; modo anterior
			int 10h

			mov ax,4c00h
			int 21h

	  
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
	
	deltax      	dw    0
	deltay      	dw    0
	  
	
	palavra1			db    	'Abrir'
	palavra2			db      'Sair'
	palavra3			db    	'FIR 1'
	palavra4			db      'FIR 2'
	palavra5			db    	'FIR 3'
  
	    ; VARIÁVEIS AUXILIARES E DE TESTES
	nome_arquivo	db		'sinaltc.txt',0
	auxiliar_arq   	dw      0
	status_arq      db    	0
	ascii			db		0
	leitura        	resb  	10
	primeiro_dig    db    	0
	segundo_dig		db    	0
	terceiro_dig	db    	0
	cont_dig		dw		0
	deslocamento    db		0
	aux_numero		dw		0
	vetor_de_cima	resb	4096
    fator_de_cima   db      2
    eh_negativo		db		0	
    teste_1         resb    512     
    filtrado        resw    4104
    teste_2         resw    512 
    filtrado_aux    dw      0
    aux_numero_2	dw		0
	auxiliar_vetor_1	dw      0
    auxiliar_vetor_2	dw      0
    limpa_linha   	    dw    	0
	limpa_coluna  	    dw    	0
	x_anterior		    db		0
    x_anterior_2        db      0
    teste_x_ant         db      0
    x_anterior_fir      db      0
	y_anterior		    dw		360
    y_anterior_2		dw		120
    teste_y_ant         db      0
    y_anteiror_fir      dw		0



    ; Variáveis utilizada nos gráficos de baixo
    passa_baixa         db      -1,-5,1,30,49,30,1,-5,-1
    passa_baixa_2       db      -1,-5,1,30,49,30,1,-5,-1
    passa_banda         db      4,-6,-24,6,41,6,-24,-6,4
    passa_banda_2       db      4,-6,-24,6,41,6,-24,-6,4
    passa_alta          db      1,5,-1,-30,52,-30,-1,5,1
    passa_alta_2        db      1,5,-1,-30,52,-30,-1,5,1

    fator_pbaixa     db      120
    fator_pbanda     db      64
    fator_palta      db      28
    fator_f_geral  resb      1
    auxiliar_escolhe  db      0

    ; contador da seta
    auxiliar_seta        db      0

    ; auxiliares do fir
    anda_em_n                   dw      0
    anda_em_k           dw      0

	segment stack stack
	resb    512
	stacktop: