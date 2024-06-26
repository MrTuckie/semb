
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

jmp inicializa_mouse

inicializa_mouse:
    mov ax,0
    int 33h
    mov ax,1
    int 33h 


checa_clique:
    ; Chamada da int 33h para saber onde houve clique do mouse 
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

    cmp dx,80
        jb botao_abrir
    cmp dx,160
        jb botao_seta
    cmp dx,240
        jb botao_sair

    jmp checa_clique

botao_abrir:
    jmp botao_abrir2
botao_sair:
    jmp botao_sair2
botao_seta:
    add word[y_anterior],240
    jmp botao_seta2

botao_abrir2:
    mov byte[cor],amarelo
    call msg_abrir
    mov byte[cor],branco_intenso
    call msg_sair
    call msg_seta

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

        ; Mostra mouse
        mov ax,1h
        int 33h 
        jmp checa_clique

botao_seta2: 
    mov byte[cor],amarelo
    call msg_seta
    mov byte[cor],branco_intenso
    call msg_abrir
    call msg_sair	

    call limpa_grafico
    call faz_interface
    call plota_grafico

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

	
		faz_interface:     
			call cria_divisorias
			call msg_abrir
			call msg_sair
			call msg_seta
			ret 
	  
	; Função para desenho das divisórias dos botões e estruturas : 
	; faz as divisórias e contorno das entruturas da interface a partir da função line
	
        ; criando os quadradinhos
    cria_divisorias:
        push ax       
        push bx       
        push cx       
        push dx       
        push si       
        push di   

        mov byte[cor],branco_intenso

        ; linha central
        mov ax,0                        
        push ax
        mov ax,240
        push ax
        mov ax,639
        push ax
        mov ax,240
        push ax
        call line

        mov byte[cor],branco_intenso
        ; parte de cima
        mov ax,0                        
        push ax
        mov ax,479
        push ax
        mov ax,639
        push ax
        mov ax,479
        push ax
        call line

        
        ; canto direito
        mov ax,639             
        push ax
        mov ax,0
        push ax
        mov ax,639
        push ax
        mov ax,479
        push ax
        call line
            
        ; em baixo
        mov ax,0             
        push ax
        mov ax,0
        push ax
        mov ax,639
        push ax
        mov ax,0
        push ax
        call line

                
        ; canto esquerdo
        mov ax,0              
        push ax
        mov ax,0
        push ax
        mov ax,0
        push ax
        mov ax,479
        push ax
        call line
                
        ; barra 1
        mov ax, 512                      
        push ax
        mov ax,639
        push ax
        mov ax, 512
        push ax
        mov ax,0
        push ax
        call line
            
        ; barra 2      
        mov ax, 512                     
        push ax
        mov ax,80
        push ax
        mov ax, 639
        push ax
        mov ax,80
        push ax
        call line
        
        ; barra 3   
        mov ax, 512                      
        push ax
        mov ax,160
        push ax
        mov ax, 640
        push ax
        mov ax,160
        push ax
        call line
        
        ; barra 4
        mov ax, 512                
        push ax
        mov ax,400
        push ax
        mov ax, 640
        push ax
        mov ax,400
        push ax
        call line
            
        ; barra 5
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
			; Salvando contexto
			pushf
			push ax
			push bx
			push cx
			push dx
			push si
			push di
			push bp

			mov byte[cor],azul

			mov bx, word[coluna_grafico]
			cmp bx, word[num_count]
				jle coluna_valida
			mov word[coluna_grafico], 0
			mov byte[cor],rosa

			coluna_valida:	
                
                mov bx, 0
                mov cx, 1020	
                mov byte[cor],azul

                printar:

                    ; Parte para resetar o eixo na parte de baixo -> OK
                    cmp cx,510
                        je reseta_eixo_x
                    jmp segue_sem_resetar
                    reseta_eixo_x:
                    xor bx,bx
                    ;mov byte[cor],verde
                    sub word[y_anterior], 240

                    segue_sem_resetar:

                        ;x1	
                        
                        mov ax, bx
                        add ax,1	
                        push ax
                        
                        ;y1
                        mov ah, 0
                        mov ax, word[y_anterior]
                        ;add ax,360 ; ok, essa e a de baixo deram certas
                        push ax

                        ;x2
                        inc bx
                        mov ax, bx
                        add ax,1
                        mov byte[x_anterior], bl
                        push ax

                        ;y2
                        ; carregando y2 em dx
                        push bx			
                        mov bx, word[coluna_grafico]
                        mov dh, 0
                        mov dl, byte[decimal+bx]
                        inc bx
                        mov word[coluna_grafico], bx			
                        pop bx

                        ; dl esta em [0,255], sendo que [0,127] tem q ser 360+dl
                        ; e [128,255] tem que ser 360-dl
                        
                        ; Checando o valor do número
                        cmp dl,127 
                            ja conv_negativo ; se for maior q 128, precisamos converter
                        jmp conv_positivo     ; se não for, continua normal

                        conv_negativo:
                            and dx,127  ; fica apenas com a magnitude
                        cmp dx,0    ; vê para o caso -128, a única exceção
                            je add_one
                        jmp no_add_one
                            add_one:
                                or dx, 128
                        no_add_one:	
                            ; esta parte você já tem a magnitude
                            ; falta fazer 360 - dx/escala e armazenar em ax

                            ; Escalando
                            mov ax,dx
                            xor dx,dx
                            div byte[escala] ; o valor escalado em al
                            mov dl,al ; dl contém o valor escalado
                                
                            mov ax,360
                            sub ax,dx
                            jmp conv_final

                        conv_positivo:

                            mov ax,dx
                            div byte[escala]
                            xor ah,ah  ; garantindo q não tem lixo em ah
                            add ax,360 ; o offset vem depois (parte 'dc')

                        conv_final:

                        cmp cx,510 ; 1020-510 -> região de cima, CC: região de baixo
                            jbe negativo_2
                        jmp positivo_2
                        negativo_2:
                            sub ax, 240 ; tira mais 240 pixels pra baixo
                        positivo_2:
                            mov word[y_anterior], ax 
                            push ax
                            call line   ; faz a linha azul

                            ; aumentando a praga do loop
                            dec cx
                            cmp cx,0
                                jne printar_2
                            jmp out_printar

                    printar_2:
                        jmp printar
                    out_printar:
				
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
	
            limpa_grafico:    
                push    cx     
                push    ax
                push    dx
                push    bx
                mov word[linha_atual],1
                mov word[coluna_atual],0
                
                mov cx,477      ; Números de linhas do grafico
                
                linhas:

                    push cx
                    mov cx, 511       ; Números de colunas do grafico
                        colunas:
                            call plota_pixel   ; Função que plota um pixel na tela
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

            plota_pixel: ; Função que pinta um pixel preta na tela
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
	
		 ; escrevendo texto nas caixinhas
        msg_abrir:
            ; seguindo as descrições das funções no linec.asm
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
            mov dh,12     ; posição       
            mov dl,70     ; posição
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
        
        msg_seta:
            push ax
            push bx
            push cx
            push dx

            ;  		y	,	x
            ;a - 	380	, 	544
            ;b -	340	,	544
            ;c -	340	,	576
            ;d -	330	,	576
            ;e -	360	,	608
            ;f -	390	,	576
            ;g -	380	,	576
            
            ; Desenho da seta do botão executar		
            ;Linha AB
            mov ax, 544                      
            push ax
            mov ax, 380
            push ax
            mov ax, 544  
            push ax
            mov ax, 340
            push ax
            call line
            
            ;Linha BC
            mov ax, 544                      
            push ax
            mov ax,340
            push ax
            mov ax, 576
            push ax
            mov ax,340
            push ax
            call line
            
            ;Linha CD
            mov ax, 576                      
            push ax
            mov ax,340
            push ax
            mov ax, 576
            push ax
            mov ax,330
            push ax
            call line
            
            ;Linha DE
            ;d -	330	,	576
            ;e -	360	,	608
            mov ax, 576                      
            push ax
            mov ax,330
            push ax
            mov ax, 608
            push ax
            mov ax,360
            push ax
            call line
            
            ; LINHA EF
            ;e -	360	,	608
            ;f -	390	,	576
            mov ax, 608                      
            push ax
            mov ax, 360
            push ax
            mov ax, 576
            push ax
            mov ax, 390
            push ax
            call line
            
            ;LINHA FG
            ;f -	390	,	576
            ;g -	380	,	576
            mov ax, 576                      
            push ax
            mov ax, 390
            push ax
            mov ax, 576
            push ax
            mov ax, 380
            push ax
            call line
            
            ;LINHA GA
            ;g -	380	,	576
            ;a - 	380	, 	544
            mov ax, 576                      
            push ax
            mov ax, 380
            push ax
            mov ax, 544
            push ax
            mov ax, 380
            push ax
            call line
            
            pop dx 
            pop cx
            pop bx
            pop ax
            ret

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
	; Variaveis utilizadas na função line
	deltax      	dw    0
	deltay      	dw    0
	  
	; Mensagens do Menu de Funções
	mens1			db    	'Abrir'
	mens2			db      'Sair'
  
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
	decimal			resb	17000	
    xant			db		00
    negativo		db		0	
    escala          db      2

	; Variaveis plotagem do grafico
	coluna_grafico	dw      0
	x_anterior		db		00
	y_anterior		dw		360

	; Variaveis de limpeza do grafico
	linha_atual   	dw    	0
	coluna_atual  	dw    	0
	
	segment stack stack
	resb    512
	stacktop: