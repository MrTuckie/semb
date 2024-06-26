
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
call faz_interface

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


; localizando o clique, mas checando se o arquivo está aberto
; Se estiver aberto -> chama a localiza_clique_2
; Se não -> chama as únicas funções que podem funcionar: abrir ou sair
localiza_clique:

    mov al,byte[aberto]
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

; função para fazer o tratamento do clique
localiza_clique_2:

    cmp dx,80
        jb botao_abrir_rec ; rec é de recomeçar, pelo visto
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


; Função para extender os pulos
botao_abrir:
    jmp botao_abrir2
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
botao_abrir_rec:
    jmp botao_abrir_rec3


botao_abrir2:
    mov byte[cor],amarelo
    call msg_abrir
    mov byte[cor],branco_intenso
    call msg_sair
    call msg_seta
    mov byte[aux_seta],0
    mov word[y_anterior],360
    mov word[y_anterior_2],120
    mov word[filtrado_aux],0
    mov word[x_anterior],0
    mov word[x_anterior_2],0
    mov word[file_handle],0
    mov word[coluna_grafico],0
    mov word[coluna_grafico_2],0
    mov word[y_anterior],360
    mov word[y_anterior_2],120
    mov word[linha_atual],0
    mov word[coluna_atual],0
    mov word[n],0
    mov word[k_ant],0

    mov byte[ascii],0
    mov byte[buffer],0
    mov byte[unidade],0
    mov byte[dezena],0
    mov byte[centena],0
    mov byte[count],0
    mov byte[deslocamento],0
    mov byte[num_count],0
    mov byte[num_count_2],0
    mov byte[decimal],0
    mov byte[negativo],0
    ; desaparece com o mouse
    ; vi na documentação
    mov ax,2h
    int 33h

    ; lida com o arquivo
    mov al,byte[aberto]     
    cmp al,0
        je  vai_abrir       
    call limpa_grafico

    ;Fechando arquivo
    mov bx,[file_handle]
    mov ah,3eh
    mov al,00h
    int 21h

    ; Abre o arquivo
    vai_abrir:
        call abre_arquivo
        call plota_grafico

        mov byte[cor],branco_intenso
        call msg_abrir

        ; Mostra mouse
        mov ax,1h
        int 33h 
        jmp checa_clique
        
botao_abrir_rec2: ; implementacao 1
    ; reinicia os dados sensiveis e volta pro inicio
    mov byte[cor],amarelo
    call msg_abrir
    mov byte[aberto], 0
    mov word[y_anterior], 360
    mov word[y_anterior_2], 120
    mov byte[x_anterior], 0 
    mov word[coluna_grafico], 0 
    mov byte[x_anterior_2], 0 
    mov word[coluna_grafico_2], 0
    mov byte[se_filtro_selec], 0
    mov word[num_count],0
    mov word[num_count_2],0
    ; limpar [decimal] aqui
    mov ah,0                ; set video mode
    mov al,[modo_anterior]    ; modo anterior
    int 10h
    jmp ..start

botao_abrir_rec3: ; implementacao 2
    ; reinicia os dados sensiveis, pinta a tela de
    ; preto mas nao reinicia a interface
    mov byte[cor],amarelo
    call msg_abrir
    mov byte[aberto], 0
    ; mov word[y_anterior], 360

    ; zerando um monte de coisas pra evitar problemas
    mov byte[x_anterior], 0 
    mov word[coluna_grafico], 0
    mov byte[x_anterior_2], 0 
    mov word[coluna_grafico_2], 0
    mov byte[se_filtro_selec], 0
    mov word[num_count],0
    mov word[num_count_2],0
    mov word[k_ant], 0
    mov word[n], 0
    mov byte[buffer],0
    
    ; limpar [decimal] aqui                 *************************
    ; https://stackoverflow.com/questions/39154103/how-to-clear-a-buffer-in-assembly
    ; http://www.posix.nl/linuxassembly/nasmdochtml/nasmdoc3.html
    call limpa_vetor
    call limpa_grafico
    call faz_interface
    jmp checa_clique

botao_seta2: 
    ; parte para não imprimir lixo depois de 8 vezes
    ; 3586/510 = 7.02 -> 8 vezes a seta vai ser apertada
    inc byte[aux_seta]
    xor ax,ax
    mov al,byte[aux_seta]
    cmp al,9
        jge faz_nada_seta
    mov byte[cor],amarelo
    call msg_seta
    mov byte[cor],branco_intenso
    call msg_abrir
    call msg_sair	

    call limpa_grafico
    call faz_interface
    call plota_grafico
    call plota_grafico_2
    faz_nada_seta:
    mov ax,1h
    int 33h 
    jmp checa_clique


botao_sair2:
    mov byte[cor],amarelo
    call msg_sair
    mov byte[cor],branco_intenso
    call msg_abrir
    call msg_seta

    mov ax,1h
    int 33h 

    jmp sair

botao_fir1_2:
    ; verifica se ha um filtro aberto
    cmp byte[se_filtro_selec], 1
        je faz_nada_seta
    mov byte[cor],amarelo
    call msg_fir1
    mov byte[cor],branco_intenso
    call msg_abrir
    call msg_seta
	call msg_fir2
	call msg_fir3

    call filtra_1
    ; ajusta a escala do filtro
    push bx
    mov bl, byte[escala_fir1]
    mov byte[escala_filtrado], bl
    pop bx
    call plota_grafico_2

    mov byte[cor],branco_intenso
    call msg_fir1
    ; seta a flag de filtro ativo
    mov byte[se_filtro_selec], 1

    mov byte[cor],branco_intenso
    call msg_fir1

    mov ax,1h
    int 33h 

    jmp checa_clique

botao_fir2_2:
    ; verifica se ha um filtro aberto
    cmp byte[se_filtro_selec], 1
        je faz_nada_filtro
    mov byte[cor],amarelo
    call msg_fir2
    mov byte[cor],branco_intenso
    call msg_abrir
    call msg_seta
	call msg_fir1
	call msg_fir3

    call filtra_2
    ; ajusta a escala do filtro
    push bx
    mov bl, byte[escala_fir2]
    mov byte[escala_filtrado], bl
    pop bx
    call plota_grafico_2

    mov byte[cor],branco_intenso
    call msg_fir2
    ; seta a flag de filtro ativo
    mov byte[se_filtro_selec], 1
    mov byte[cor],branco_intenso
    call msg_fir2

    mov ax,1h
    int 33h 

    jmp checa_clique

faz_nada_filtro:
    mov ax,1h
    int 33h 

    jmp checa_clique

botao_fir3_2:
    ; verifica se ha um filtro aberto
    cmp byte[se_filtro_selec], 1
        je faz_nada_filtro
    mov byte[cor],amarelo
    call msg_fir3
    mov byte[cor],branco_intenso
    call msg_abrir
    call msg_seta
	call msg_fir1
	call msg_fir2

    call filtra_3

    ; ajusta a escala do filtro
    push bx
    mov bl, byte[escala_fir3]
    mov byte[escala_filtrado], bl
    pop bx
    call plota_grafico_2

    mov byte[cor],branco_intenso
    call msg_fir3

    ; seta a flag de filtro ativo
    mov byte[se_filtro_selec], 1
    mov byte[cor],branco_intenso
    call msg_fir3

    mov ax,1h
    int 33h 

    jmp checa_clique


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
        
        mov bl, byte[count] ; contador de algarismos
        
        ; comparando o texto

        cmp al, '-' 
            je is_neg
        jmp is_not_neg
            is_neg:
                mov byte[negativo],1
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
        
        ; pulando três vezes para tirar a parte que não importa.

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

            call 	ascii2decimal
            
            inc		bl
            mov		byte[count],bl

            jmp 	proximo_byte
                    
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

			 
			xor 	cx,cx
			
			 
			 
			mov 	al,[ascii]
			sub 	al,30h
			mov 	cl,byte[unidade] 
			mov 	ch,byte[dezena]
			 
			 
			 
			 
			mov 	byte[unidade],al
			mov 	byte[dezena],cl
			mov 	byte[centena],ch

			 
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

                mov 	al,byte[centena]
                mov 	bl,10
                mul 	bl
                mov 	cx,ax	
                
                xor 	ah,ah
                mov 	al,byte[dezena]
                add 	cx,ax	
                
                jmp final_juncao
                
                numero_1:
                
                mov 	al,byte[centena]
                mov 	cx,ax	
                
                final_juncao:	

                xor ax,ax
                mov al,byte[negativo]
                cmp al, 1
                    je add_offset
                    jmp no_offset
                    add_offset:
                    or cl,128
                    
                no_offset:

                mov byte[negativo],0

                mov		bx, word[num_count]
                
                mov 	byte[decimal+bx],cl

                inc 	bx
                mov		word[num_count],bx		

                mov 	byte[unidade],0
                mov 	byte[dezena],0
                mov 	byte[centena],0
                
                 
                pop		bp
                pop		di
                pop		si
                pop		dx
                pop		cx
                pop		bx
                pop		ax
                popf
                ret

	
		faz_interface:     
			call cria_divisorias
			call msg_abrir
			call msg_sair
			call msg_seta
			call msg_fir1
			call msg_fir2
			call msg_fir3
			ret 
	  
	 
	 
	
         
    cria_divisorias:
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

        mov byte[cor],vermelho
        ; debug
        mov ax,0                 
        push ax
        mov ax,120
        push ax
        mov ax,639
        push ax
        mov ax,120
        push ax
        call line
        ; debug
        mov ax,0                 
        push ax
        mov ax,296
        push ax
        mov ax,639
        push ax
        mov ax,296
        push ax
        call line
        ; debug
        mov ax,0                 
        push ax
        mov ax,360
        push ax
        mov ax,639
        push ax
        mov ax,360
        push ax
        call line
        mov byte[cor],branco_intenso

        ; ; debug
        ; mov ax,320                        
        ; push ax
        ; mov ax,0
        ; push ax
        ; mov ax,320
        ; push ax
        ; mov ax,479
        ; push ax
        ; call line

        ; ; debug
        ; mov ax,90                        
        ; push ax
        ; mov ax,0
        ; push ax
        ; mov ax,90
        ; push ax
        ; mov ax,479
        ; push ax
        ; call line


        ; ; debug
        ; mov ax,100                        
        ; push ax
        ; mov ax,0
        ; push ax
        ; mov ax,100
        ; push ax
        ; mov ax,479
        ; push ax
        ; call line

        ; ; debug
        ; mov ax,128                        
        ; push ax
        ; mov ax,0
        ; push ax
        ; mov ax,128
        ; push ax
        ; mov ax,479
        ; push ax
        ; call line

        ;         ; debug
        ; mov ax,256                        
        ; push ax
        ; mov ax,0
        ; push ax
        ; mov ax,256
        ; push ax
        ; mov ax,479
        ; push ax
        ; call line

        mov byte[cor],branco_intenso
         
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


		plota_grafico:
			 
			pushf
			push ax
			push bx
			push cx
			push dx
			push si
			push di
			push bp
			mov byte[cor],branco_intenso
			mov bx, word[coluna_grafico]
			cmp bx, word[num_count]
				jle coluna_valida
			mov word[coluna_grafico], 0

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

                        ; Pegando o valor que está em decimal e jogando para dl
                        push bx			
                        mov bx, word[coluna_grafico]
                        mov dh, 0
                        mov dl, byte[decimal+bx]
                        inc bx
                        mov word[coluna_grafico], bx			
                        pop bx

                        ; Desconversão do valor que estava em decimal                     
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
                            div byte[escala]  
                            mov dl,al  
                                
                            ; jogando para baixo    
                            mov ax,360
                            sub ax,dx
                            jmp conv_final

                        conv_positivo:

                            mov ax,dx
                            idiv byte[escala]
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; As funcoes de filtro sao copias umas das outras,
; exceto pelas tags que devem ser unicas

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
            mov word[k_ant],0
            mov word[n],0
            mov word[num_count_2],0


            ; aqui vai ficar a parte de escolher qual fir_vetor vai ser usado, vou usar o primeiro para ficar mais
            ; simples de proceder

            loop_anda_n_a: ; vai rodar 4096 vezes

                push cx ; salva cx colocar o outro contador
                mov cx, tamanho_h ; de início, vai rodar 9 vezes, mas sai se !(n>=k) 
                
                loop_anda_k_a:

                    ; funciona essas 4 linhas
                    mov bx,word[k_ant]          ; bx vai ser k
                    mov al, byte[fir1_vetor+bx] ; al é o h[k], podendo ser negativo. 8 bit
                    mov bx,word[n]              ; bx se torna n
                    sub bx, word[k_ant]         ; bx se torna n-k

                    ; funciona pegar de decimal (com sinal corrigido)
                    mov dx, 0                   ; dx = 0
                    mov dl, byte[decimal+bx]    ; dl = x[n-k], podendo ser negativo depois da conversão. 8 bit
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
                    inc word[k_ant]             ; k+=1
                    mov dx,word[k_ant]
                    mov bx, word[n]             ; joga o valor de n de volta no bx   

                    cmp bx,dx ; se !(n>=k)
                        jnge out_loop_anda_k_a ; sai do loop

                loop loop_anda_k_a

                out_loop_anda_k_a:

                mov word[k_ant],0 ; reseta o k_ant
                inc word[n] ; n+=1
                pop cx ; pega o cx de volta para o outro loop

                ; inserção dos dados
                ; essas 5 linhas estão ok
                mov     ax, word[filtrado_aux]
                mov		bx, word[num_count_2]   ; pega o valor do auxiliar para andar no vetor filtrado
                mov 	word[filtrado+bx],ax    ; joga o valor de ax no vetor na posição certa
                inc     bx
                inc 	bx                      ; incrementa o valor do reg auxiliar
                mov		word[num_count_2],bx	    ; salva ele na variável auxiliar
                mov word[filtrado_aux], 0

                ; essa parte aqui está funcionando q é uma beleza, mas é só para exemplo
                ; ela serve para testar o printar_filtro
                    ; mov		bx, word[num_count_2]   ; pega o valor do auxiliar para andar no vetor filtrado
                    ; mov		ax, word[num_count_2]
                    ; neg     ax
                    ; mov 	word[filtrado+bx],ax    ; joga o valor de ax no vetor na posição certa
                    ; inc     bx
                    ; inc 	bx                      ; incrementa o valor do reg auxiliar
                    ; mov		word[num_count_2],bx	    ; salva ele na variável auxiliar   

            loop loop_anda_n_a
            out_loop_anda_n_a:
            
            ;mov word[num_count_2], 0 ; reseta o contador


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
            mov word[k_ant],0
            mov word[n],0
            mov word[num_count_2],0


            ; aqui vai ficar a parte de escolher qual fir_vetor vai ser usado, vou usar o primeiro para ficar mais
            ; simples de proceder

            loop_anda_n_b: ; vai rodar 4096 vezes

                push cx ; salva cx colocar o outro contador
                mov cx, tamanho_h ; de início, vai rodar 9 vezes, mas sai se !(n>=k) 
                
                loop_anda_k_b:

                    ; funciona essas 4 linhas
                    mov bx,word[k_ant]          ; bx vai ser k
                    mov al, byte[fir2_vetor+bx] ; al é o h[k], podendo ser negativo. 8 bit
                    mov bx,word[n]              ; bx se torna n
                    sub bx, word[k_ant]         ; bx se torna n-k

                    ; funciona pegar de decimal (com sinal corrigido)
                    mov dx, 0                   ; dx = 0
                    mov dl, byte[decimal+bx]    ; dl = x[n-k], podendo ser negativo depois da conversão. 8 bit
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
                    inc word[k_ant]             ; k+=1
                    mov dx,word[k_ant]
                    mov bx, word[n]             ; joga o valor de n de volta no bx   

                    cmp bx,dx ; se !(n>=k)
                        jnge out_loop_anda_k_b ; sai do loop

                loop loop_anda_k_b

                out_loop_anda_k_b:

                mov word[k_ant],0 ; reseta o k_ant
                inc word[n] ; n+=1
                pop cx ; pega o cx de volta para o outro loop

                ; inserção dos dados
                ; essas 5 linhas estão ok
                mov     ax, word[filtrado_aux]
                mov		bx, word[num_count_2]   ; pega o valor do auxiliar para andar no vetor filtrado
                mov 	word[filtrado+bx],ax    ; joga o valor de ax no vetor na posição certa
                inc     bx
                inc 	bx                      ; incrementa o valor do reg auxiliar
                mov		word[num_count_2],bx	    ; salva ele na variável auxiliar
                mov word[filtrado_aux], 0

                ; essa parte aqui está funcionando q é uma beleza, mas é só para exemplo
                ; ela serve para testar o printar_filtro
                    ; mov		bx, word[num_count_2]   ; pega o valor do auxiliar para andar no vetor filtrado
                    ; mov		ax, word[num_count_2]
                    ; neg     ax
                    ; mov 	word[filtrado+bx],ax    ; joga o valor de ax no vetor na posição certa
                    ; inc     bx
                    ; inc 	bx                      ; incrementa o valor do reg auxiliar
                    ; mov		word[num_count_2],bx	    ; salva ele na variável auxiliar   

            loop loop_anda_n_b
            out_loop_anda_n_b:
            
            ;mov word[num_count_2], 0 ; reseta o contador


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
            mov word[k_ant],0
            mov word[n],0
            mov word[num_count_2],0


            ; aqui vai ficar a parte de escolher qual fir_vetor vai ser usado, vou usar o primeiro para ficar mais
            ; simples de proceder

            loop_anda_n_c: ; vai rodar 4096 vezes

                push cx ; salva cx colocar o outro contador
                mov cx, tamanho_h ; de início, vai rodar 9 vezes, mas sai se !(n>=k) 
                
                loop_anda_k_c:

                    ; funciona essas 4 linhas
                    mov bx,word[k_ant]          ; bx vai ser k
                    mov al, byte[fir3_vetor+bx] ; al é o h[k], podendo ser negativo. 8 bit
                    mov bx,word[n]              ; bx se torna n
                    sub bx, word[k_ant]         ; bx se torna n-k

                    ; funciona pegar de decimal (com sinal corrigido)
                    mov dx, 0                   ; dx = 0
                    mov dl, byte[decimal+bx]    ; dl = x[n-k], podendo ser negativo depois da conversão. 8 bit
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
                    inc word[k_ant]             ; k+=1
                    mov dx,word[k_ant]
                    mov bx, word[n]             ; joga o valor de n de volta no bx   

                    cmp bx,dx ; se !(n>=k)
                        jnge out_loop_anda_k_c ; sai do loop

                loop loop_anda_k_c

                out_loop_anda_k_c:

                mov word[k_ant],0 ; reseta o k_ant
                inc word[n] ; n+=1
                pop cx ; pega o cx de volta para o outro loop

                ; inserção dos dados
                ; essas 5 linhas estão ok
                mov     ax, word[filtrado_aux]
                mov		bx, word[num_count_2]   ; pega o valor do auxiliar para andar no vetor filtrado
                mov 	word[filtrado+bx],0    ; joga o valor de ax no vetor na posição certa
                mov 	word[filtrado+bx],ax    ; joga o valor de ax no vetor na posição certa
                inc     bx
                inc 	bx                      ; incrementa o valor do reg auxiliar
                mov		word[num_count_2],bx	    ; salva ele na variável auxiliar
                mov word[filtrado_aux], 0

                ; essa parte aqui está funcionando q é uma beleza, mas é só para exemplo
                ; ela serve para testar o printar_filtro
                    ; mov		bx, word[num_count_2]   ; pega o valor do auxiliar para andar no vetor filtrado
                    ; mov		ax, word[num_count_2]
                    ; neg     ax
                    ; mov 	word[filtrado+bx],ax    ; joga o valor de ax no vetor na posição certa
                    ; inc     bx
                    ; inc 	bx                      ; incrementa o valor do reg auxiliar
                    ; mov		word[num_count_2],bx	    ; salva ele na variável auxiliar   

            loop loop_anda_n_c
            out_loop_anda_n_c:
            
            ;mov word[num_count_2], 0 ; reseta o contador


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
            mov word[num_count_2],0
            loop_limpa_vetor:
            mov		bx, word[num_count_2]   ; pega o valor do auxiliar para andar no vetor filtrado
            mov 	byte[decimal+bx],0    ; joga o valor de ax no vetor na posição certa
            inc     bx
            mov		word[num_count_2],bx	    ; salva ele na variável auxiliar
            loop loop_limpa_vetor
            mov word[num_count_2],0
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

            plota_grafico_2:
			 
			pushf
			push ax
			push bx
			push cx
			push dx
			push si
			push di
			push bp
			mov byte[cor],verde
			mov bx, word[coluna_grafico_2]
			cmp bx, word[num_count_2]
				jle coluna_valida_2
			mov word[coluna_grafico_2], 0

			coluna_valida_2:	
                
                mov bx, -1
                mov cx, 512	
                mov byte[cor],verde

                printar_filtro:

                    mov byte[cor],verde
                    ; cmp cx,510
                    ;     je reseta_eixo_x
                    ; jmp segue_sem_resetar
                    ; reseta_eixo_x:
                    ; xor bx,bx 
                    ; sub word[y_anterior], 240

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

                        ; Pegando o valor que está em decimal e jogando para dl
                        push bx			
                        mov bx, word[coluna_grafico_2]
                        mov dx, word[filtrado+bx]
                        add bx,2
                        mov word[coluna_grafico_2], bx			
                        pop bx

                        ; these 6 lines here work like a charm
                        mov ax,dx
                        xor dx,dx
                        idiv byte[escala_filtrado]
                        xor ah,ah
                        test al,al
                        jns sou_positivo
                        ;jmp sou_fim

                        sou_negativo:
                        neg al
                        mov dl,120
                        sub dl,al
                        mov al,dl
                        ;mov byte[cor],vermelho
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
                mov word[linha_atual],1
                mov word[coluna_atual],0
                
                mov cx,477       
                
                linhas:

                    push cx
                    mov cx, 511        
                        colunas:
                            call plota_pixel    
                            inc word[coluna_atual]
                            loop colunas
                    inc word[linha_atual]

                    mov ax, word[linha_atual]
                    cmp ax,240
                        je dec_linha
                        jmp segue_linha
                        dec_linha:
                        inc word[linha_atual]
                    segue_linha:
                    
                    mov word[coluna_atual],0
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
	
		  
        msg_abrir:
             
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
                mov al,[bx+mens1]
                call  caracter
                inc bx      
                inc dl     
            loop loop_abrir
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
            mov cx,4      
            mov bx,0
            mov dh,12      
            mov dl,70      
            loop_sair:
                call cursor
                mov al,[bx+mens2]
                call caracter
                inc bx       
                inc dl       
            loop loop_sair
            pop dx 
            pop cx
            pop bx
            pop ax
            ret
        
        msg_seta:
            push ax
            push bx
            push cx
            push dx

            ;  		x	,	y
            ;a - 	528 ,   365
            ;b -	576 ,   365
            ;c -	576 ,   375
            ;d -	592 ,   360
            ;e -	576 ,   345
            ;f -	576 ,   355
            ;g -	528 ,   355

            ;Linha GA
            mov ax, 528                      
            push ax
            mov ax, 355
            push ax
            mov ax, 528  
            push ax
            mov ax, 365
            push ax
            call line

            ;Linha FG
            mov ax, 576                      
            push ax
            mov ax, 355
            push ax
            mov ax, 528  
            push ax
            mov ax, 355
            push ax
            call line

            ;Linha EF
            mov ax, 576                      
            push ax
            mov ax, 345
            push ax
            mov ax, 576  
            push ax
            mov ax, 355
            push ax
            call line

            ;Linha DE
            mov ax, 592                      
            push ax
            mov ax, 360
            push ax
            mov ax, 576  
            push ax
            mov ax, 345
            push ax
            call line

            ;Linha CD
            mov ax, 576                      
            push ax
            mov ax, 375
            push ax
            mov ax, 592  
            push ax
            mov ax, 360
            push ax
            call line

            ;Linha AB
            mov ax, 528                      
            push ax
            mov ax, 365
            push ax
            mov ax, 576  
            push ax
            mov ax, 365
            push ax
            call line

            ;Linha BC
            mov ax, 576                      
            push ax
            mov ax, 365
            push ax
            mov ax, 576  
            push ax
            mov ax, 375
            push ax
            call line
            
            pop dx 
            pop cx
            pop bx
            pop ax
            ret

        msg_fir1:
             
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
                mov al,[bx+mens3]
                call  caracter
                inc bx      
                inc dl     
            loop loop_msg_fir1
            pop dx 
            pop cx
            pop bx
            pop ax
            ret

        msg_fir2:
             
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
                mov al,[bx+mens4]
                call  caracter
                inc bx      
                inc dl     
            loop loop_msg_fir2
            pop dx 
            pop cx
            pop bx
            pop ax
            ret

        msg_fir3:
             
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
                mov al,[bx+mens5]
                call  caracter
                inc bx      
                inc dl     
            loop loop_msg_fir3
            pop dx 
            pop cx
            pop bx
            pop ax
            ret

	 
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
	  
	
	mens1			db    	'Abrir'
	mens2			db      'Sair'
	mens3			db    	'FIR 1'
	mens4			db      'FIR 2'
	mens5			db    	'FIR 3'
  
	
	file_name		db		'sinaltc.txt',0
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
    espacamento_0   resb    30
	decimal			resb	4096
    espacamento_1   resb    512     ; para evitar imprimir alem do permitido
    tamanho         equ     4096
    filtrado        resw    4104
    espacamento_2   resw    512     ; para evitar imprimir alem do permitido
    filtrado_aux    dw      0
    tamanho_f        equ    4104
    num_count_2		dw		0
    tamanho_h       equ     9

    negativo		db		0	
    escala          db      2

	coluna_grafico	    dw      0
    coluna_grafico_2	dw      0
	x_anterior		    db		00
    x_anterior_2        db      00
	y_anterior		    dw		360
    y_anterior_2		dw		120

	linha_atual   	dw    	0
	coluna_atual  	dw    	0

    fir1_vetor      db      -1,-5,1,30,49,30,1,-5,-1
    fir2_vetor      db      4,-6,-24,6,41,6,-24,-6,4
    fir3_vetor      db      1,5,-1,-30,52,-30,-1,5,1

    ; lembrar de fazer diferentes valores de escala para cada gráfico,visto que o max e o min alteram
    escala_fir1      db      117
    escala_fir2      db      61
    escala_fir3      db      25
    escala_filtrado  resb    1
    se_filtro_selec  db      0

    ; contador da seta
    aux_seta        db      0

    ; auxiliares do fir
    n               dw      0
    k_ant           dw      0

	segment stack stack
	resb    512
	stacktop: