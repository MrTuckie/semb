localiza_clique_2:
    cmp cx,64
        jb botao_abrir_rec
    cmp cx,128
        jb botao_lbp
    cmp cx,192
        jb botao_hist
    cmp cx,256
        jb botao_hist_lbp
    cmp cx,320
        jb botao_sair
    jmp checa_clique

botao_lbp:
    jmp botao_lbp_2
botao_hist_lbp:
    jmp botao_hist_lbp_2


faz_interface:     
    call cria_divisorias
    call mnome
    call msg_abrir
    call msg_sair
    call msg_hist
    call msg_lbp
    call msg_hist_lbp
ret 


msg_hist_lbp:

    push ax
    push bx
    push cx
    push dx
    mov cx,4      
    mov bx,0
    mov dh,2      
    mov dl,26     
    loop_msg_hist_lbp:
        call cursor
        mov al,[bx+mens3]
        call  caracter
        inc bx      
        inc dl     
    loop loop_msg_hist_lbp

    mov cx,3      
    mov bx,0
    mov dh,3      
    mov dl,26     
    loop_msg_hist_lbp_2:
        call cursor
        mov al,[bx+mens3_2]
        call  caracter
        inc bx      
        inc dl     
    loop loop_msg_hist_lbp_2
    pop dx 
    pop cx
    pop bx
    pop ax
ret

msg_lbp:

    push ax
    push bx
    push cx
    push dx
    mov cx,3      
    mov bx,0
    mov dh,2      
    mov dl,10     
    loop_msg_lbp:
        call cursor
        mov al,[bx+mens3_2]
        call  caracter
        inc bx      
        inc dl     
    loop loop_msg_lbp
    pop dx 
    pop cx
    pop bx
    pop ax
ret

botao_hist_2:

    mov bl,byte[hist_ativo]
        cmp bl,1
            jne sem_hist_2
        call limpa_hist
    sem_hist_2:
    mov byte[hist_ativo],1
    mov byte[cor],amarelo
    call msg_hist
    mov byte[cor],branco_intenso
    call msg_abrir
    call plota_grafico
    mov byte[cor],branco_intenso 
    call msg_hist
    mov ax,1h
    int 33h 
    jmp checa_clique



botao_lbp_2:
    mov byte[cor],amarelo
    call msg_lbp
    mov byte[cor],branco_intenso
    mov word[y_anterior_3],	478
    mov word[x_anterior_3], 321 
    call msg_abrir
    call msg_hist
    call lbp
    call printa_lbp
    mov byte[cor],branco_intenso
    call msg_lbp
    
    mov ax,1h
    int 33h 
    jmp checa_clique

botao_hist_lbp_2:
    mov bl,byte[hist_ativo]
        cmp bl,1
            jne sem_hist
        call limpa_hist
    sem_hist:
    mov byte[hist_ativo],1
    mov byte[cor],amarelo
    call msg_hist_lbp
    mov byte[cor],branco_intenso
    call msg_abrir
    call msg_hist
    call plota_lbp
    mov byte[cor],branco_intenso 
    call msg_hist_lbp
    mov ax,1h
    int 33h 
    jmp checa_clique


limpa_hist:
    push    cx     
    push    ax
    push    dx
    push    bx
    mov word[linha_atual],0
    mov word[coluna_atual],639
    mov cx,220
    linhas_2:
        push cx
        mov cx, 639         
    colunas_2:
        call plota_pixel    
        dec word[coluna_atual]
        cmp cx, 320
            je colunas_2_out
        loop colunas_2
        colunas_2_out:
        inc word[linha_atual]
        mov word[coluna_atual],639
        pop cx
        loop linhas_2
    pop   bx
    pop   dx
    pop   ax    
    pop   cx
ret


plota_lbp:

    pushf
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp
    mov byte[cor],branco_intenso
    mov word[coluna_grafico], 0
    ; garantindo que o primeiro valor do histograma vai ser o primeiro valor do vetor
    ; garantindo q o primeiro vai ser devidamente escalado
    mov dx,word[hist_lbp]

    mov ax,dx
    div byte[escala_2]  
    xor ah,ah
    mov word[y_anterior_2], ax
    mov bx, 320
    mov cx, 256	
    printar_2:
        ; x1
        ; x1 começa em 321, na meiuca do gráfico
        mov ax, bx
        add ax,1	
        push ax

        ; y1
        ; y1 começa pegando o primeiro valor no eixo, mas ele precisa sofrer uma escala tbm
        mov ax, word[y_anterior_2]
        push ax

        inc bx
        mov ax, bx
        add ax,1
        mov word[x_anterior_2], bx
        push ax

        ; y2
        ; movendo a parte do auxiliar que anda no eixo_x
        ; dx é a variável que contém o valor em eix_x
        push bx			
        mov bx, word[coluna_grafico]
        mov dx, word[hist_lbp+bx]
        add bx,2
        mov word[coluna_grafico], bx			
        pop bx

        mov ax,dx
        xor dx,dx
        div word[escala_2] 
        mov word[y_anterior_2], ax
        push ax

        call line    
    loop printar_2 
    pop		bp
    pop		di
    pop		si
    pop		dx
    pop		cx
    pop		bx
    pop		ax
    popf
ret


lbp:
    pushf
    push 	ax
    push 	bx
    push	cx
    push	dx
    push	si
    push	di
    push	bp


;; nota para o arthur do futuro: organizar melhor como vai funcionar o loop
; não deve ser difícil

    mov cx,0 ; vai fazer lbp_y repetir 258^2 vezes
    mov word[y_anterior_4],1 ; pois x varia de 1 até 248
    mov word[x_anterior_4],1 ; pois y varia de 1 até 248, mas é multiplicado de 250.
    ;mov word[pos_2],0
    lbp_y:
        mov byte[val],0
        mov ax,word[y_anterior_4]
        mov bx,word[x_anterior_4]
        cmp bx,249 ; compara o valor de x
            jne n_reseta_lbp
        ; se x passar de 248, reinicia a variável, aumenta a de y
        mov word[x_anterior_4],1
        inc word[y_anterior_4]
        mov bx,word[x_anterior_4]
        mov ax,word[y_anterior_4]
        n_reseta_lbp:
        ; aritmética para fazer pos = x + y*250
        mov dx,250
        mul dx ; ax = al * 250, ou seja, y*250
        add ax,bx ; ax = x + y*250
        
        mov bx,ax ; bx contem a 'pos'; 251 inicialmente
        xor dx,dx
        mov dl,byte[v_decimal+bx]
        mov byte[n],dl; n contém o valor do que está naquela 'pos' do vetor decimal, inicialmente em v_decimal+251

        ; O maior bit será o que está na posição pos - 1;
        ; 7 : pos - 1
        ; 6 : pos + 250 - 1
        ; 5 : pos + 250
        ; 4 : pos + 250 + 1
        ; 3 : pos + 1
        ; 2 : pos - 250 + 1
        ; 1 : pos - 250
        ; 0 : pos - 250 - 1


        sub bx,251 ; bx é o pos - 250 - 1; inicialmente, vai ser 0
        mov dl,byte[v_decimal+bx] ; inicialmente dl é o valor que está em v_decimal+0
        cmp byte[n],dl ; compara se o 'n' é maior que o 1º byte a ser analisado
            jl pulo_1 ; se 'n' não for maior ou igual, deixa o pau quebrar
            add byte[val],1 
        pulo_1:
        inc bx ;pos - 250
        mov dl,byte[v_decimal+bx]
        cmp byte[n],dl
            jl pulo_2
            add byte[val],2 
        pulo_2:
        inc bx ; pos - 250 + 1
        mov dl,byte[v_decimal+bx]
        cmp byte[n],dl
            jl pulo_3
            add byte[val],4 
        pulo_3:
        add bx,250 ; pos + 1        
        mov dl,byte[v_decimal+bx]
        cmp byte[n],dl
            jl pulo_4
            add byte[val],8 
        pulo_4:
        add bx,250; pos + 250 + 1
        mov dl,byte[v_decimal+bx]
        cmp byte[n],dl
            jl pulo_5
            add byte[val],16 
        pulo_5:
        dec bx ; pos + 250 
        mov dl,byte[v_decimal+bx]
        cmp byte[n],dl
            jl pulo_6
            add byte[val],32 
        pulo_6:
        dec bx ; pos + 250 -1
        mov dl,byte[v_decimal+bx]
        cmp byte[n],dl
            jl pulo_7
            add byte[val],64 
        pulo_7:
        sub bx,250 ; pos - 1
        mov dl,byte[v_decimal+bx]
        cmp byte[n],dl 
            jl pulo_8
            add byte[val],128 
        pulo_8:

        ; pop cx ; lembrando que ax é a variável da posição do byte analisado que eu salvei em pilha
        mov bx,cx ; bx vai ser a posição do vetor a partir do contador
        xor dx,dx
        mov dl,byte[val] ; pega o valor que foi calculado pelo lbp
        mov byte[v_decimal+bx],dl ; inicialmente, insere na posição 0 o valor calculado do lbp na posição 0
        mov bx,dx
        add bx,bx
        add word[hist_lbp+bx], 1
        ; anda com x pela direita
        inc word[x_anterior_4]
        inc cx ; aumenta o valor de cx
        ; saindo do loop
        cmp cx,61504
            je lbp_y_out
        jmp lbp_y ; retornando ao inicio do loop

    lbp_y_out:
    pop		bp
    pop		di
    pop		si
    pop		dx
    pop		cx
    pop		bx
    pop		ax
    popf
ret

printa_lbp:    
    push    cx     
    push    ax
    push    dx
    push    bx
    mov cx, 61504 ; quantidade de vezes que ele vai rodar, tecnicamente seria 248x248 = 61504
    mov word[pos],0 ; posição para andar no vetor decimal, vai até 61504, por aí
    mov word[x_anterior_3],321
    mov word[y_anterior_3],478
    andando_lbp:
        mov bx, word[x_anterior_3] ; bx 321 no inicio
        cmp bx, 569 ; 321 + 248
            jne n_reseta_x_2
        ; resetando as variáveis
        mov word[x_anterior_3], 321
        mov bx, word[x_anterior_3]
        dec word[y_anterior_3] ; 478, 477, ..., 230, por aí
        n_reseta_x_2:
            push bx ; enviar o valor de x
            mov ax, word[y_anterior_3] ; 478 de início
            push ax ; envia o valor de y
            xor ax,ax
            xor bx,bx
            mov bx,word[pos] ; coloca o valor da posição em bx, começa em zero e vai crescendo
            mov al,byte[v_decimal+bx] ; pega o valor que está no lbp para definir cor
            xor ah,ah
            cmp ax,63
                jbe eh_preto_2
            cmp ax,127
                jbe eh_cinza_2
            cmp ax,191
                jbe eh_branco_3
            cmp ax,255
                jbe eh_branco_3_2

        eh_preto_2:
            mov byte[cor],preto
            jmp plota_no_xy_2
        eh_cinza_2:
            mov byte[cor],cinza
            jmp plota_no_xy_2
        eh_branco_3:
            mov byte[cor],branco
            jmp plota_no_xy_2
        eh_branco_3_2:
            mov byte[cor],branco_intenso
            jmp plota_no_xy_2
        plota_no_xy_2:
        call plot_xy

        inc word[x_anterior_3] ;322, 323, 324, ...,  569, por aí
        inc word[pos]
    loop andando_lbp
    pop   bx
    pop   dx
    pop   ax    
    pop   cx
ret

    coluna_grafico	    dw      0
    x_anterior		    dw		0   ; algum gráfico
    x_anterior_2	    dw		321 ; porra nenhuma
    x_anterior_3		dw		321 ; print lbp
    x_anterior_4        dw      0   ; lbp
    y_anterior		    dw		364 ;  foto principal
    y_anterior_2	    dw		1   ; printa qualquer histograma
    y_anterior_3		dw		478 ; print lbp
    y_anterior_4        dw      0   ; lbp
    espacamento_2   resw    10
    eixo_x			resw	260 ; pode ir de 0 256**2 -1
    espacamento     resw    10
    hist_lbp        resw	260
    linha_atual   	dw    	0
    coluna_atual  	dw    	0
    escala			dw		3
    escala_2        dw      50
    val             db      0
    n               db      0
    pos             dw      0
    pos_2           dw      0
    reinicia db 0
    hist_ativo db 0
    