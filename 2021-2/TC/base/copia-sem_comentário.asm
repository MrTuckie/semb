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
    
    mov dx,word[hist_lbp]

    mov ax,dx
    div byte[escala_2]  
    xor ah,ah
    mov word[y_anterior_2], ax
    mov bx, 320
    mov cx, 256	
    printar_2:
        
        mov ax, bx
        add ax,1	
        push ax

        mov ax, word[y_anterior_2]
        push ax

        inc bx
        mov ax, bx
        add ax,1
        mov word[x_anterior_2], bx
        push ax

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

    mov cx,0 
    mov word[y_anterior_4],1 
    mov word[x_anterior_4],1 
    
    lbp_y:
        mov byte[val],0
        mov ax,word[y_anterior_4]
        mov bx,word[x_anterior_4]
        cmp bx,249 
            jne n_reseta_lbp
        
        mov word[x_anterior_4],1
        inc word[y_anterior_4]
        mov bx,word[x_anterior_4]
        mov ax,word[y_anterior_4]
        n_reseta_lbp:
        
        mov dx,250
        mul dx 
        add ax,bx 
        
        mov bx,ax 
        xor dx,dx
        mov dl,byte[v_decimal+bx]
        mov byte[n],dl

        sub bx,251 
        mov dl,byte[v_decimal+bx] 
        cmp byte[n],dl 
            jl pulo_1 
            add byte[val],1 
        pulo_1:
        inc bx 
        mov dl,byte[v_decimal+bx]
        cmp byte[n],dl
            jl pulo_2
            add byte[val],2 
        pulo_2:
        inc bx 
        mov dl,byte[v_decimal+bx]
        cmp byte[n],dl
            jl pulo_3
            add byte[val],4 
        pulo_3:
        add bx,250 
        mov dl,byte[v_decimal+bx]
        cmp byte[n],dl
            jl pulo_4
            add byte[val],8 
        pulo_4:
        add bx,250
        mov dl,byte[v_decimal+bx]
        cmp byte[n],dl
            jl pulo_5
            add byte[val],16 
        pulo_5:
        dec bx 
        mov dl,byte[v_decimal+bx]
        cmp byte[n],dl
            jl pulo_6
            add byte[val],32 
        pulo_6:
        dec bx 
        mov dl,byte[v_decimal+bx]
        cmp byte[n],dl
            jl pulo_7
            add byte[val],64 
        pulo_7:
        sub bx,250 
        mov dl,byte[v_decimal+bx]
        cmp byte[n],dl 
            jl pulo_8
            add byte[val],128 
        pulo_8:

        
        mov bx,cx 
        xor dx,dx
        mov dl,byte[val] 
        mov byte[v_decimal+bx],dl 
        mov bx,dx
        add bx,bx
        add word[hist_lbp+bx], 1
        
        inc word[x_anterior_4]
        inc cx 
        
        cmp cx,61504
            je lbp_y_out
        jmp lbp_y 

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
    mov cx, 61504 
    mov word[pos],0 
    mov word[x_anterior_3],321
    mov word[y_anterior_3],478
    andando_lbp:
        mov bx, word[x_anterior_3] 
        cmp bx, 569 
            jne n_reseta_x_2
        
        mov word[x_anterior_3], 321
        mov bx, word[x_anterior_3]
        dec word[y_anterior_3] 
        n_reseta_x_2:
            push bx 
            mov ax, word[y_anterior_3] 
            push ax 
            xor ax,ax
            xor bx,bx
            mov bx,word[pos] 
            mov al,byte[v_decimal+bx] 
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

        inc word[x_anterior_3] 
        inc word[pos]
    loop andando_lbp
    pop   bx
    pop   dx
    pop   ax    
    pop   cx
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

mnome:
push ax
push bx
push cx
push dx
mov cx,size     
mov bx,0
mov dh,26           
mov dl,14     
loopnome:
    call cursor
    mov al,[bx+mensnome]
    call caracter
    inc bx              
    inc dl              
loop loopnome
pop dx 
pop cx
pop bx
pop ax
ret 


    mens3_2         db      'LBP'
    mensnome       	db      'Lucas Bernabe 6.1'
    size            equ 17

    coluna_grafico	    dw      0
    x_anterior		    dw		0   
    x_anterior_2	    dw		321 
    x_anterior_3		dw		321 
    x_anterior_4        dw      0   
    y_anterior		    dw		364 
    y_anterior_2	    dw		1   
    y_anterior_3		dw		478 
    y_anterior_4        dw      0   
    espacamento_2   resw    10
    eixo_x			resw	260 
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
    