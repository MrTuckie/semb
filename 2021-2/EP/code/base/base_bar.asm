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
    cmp   dx, 115                                   
        jb    localiza_clique
    jmp   checa_clique

localiza_clique:

    mov al,[aberto]
    cmp al,1
        je localiza_clique_2
    cmp cx,64
        jb botao_abrir
    cmp cx,128
        jb faz_nada
    cmp cx,192
        jb faz_nada
    cmp cx,256
        jb faz_nada
    cmp cx,320
        jb botao_sair

faz_nada:
    jmp checa_clique

localiza_clique_2:
    cmp cx,64
        jb botao_abrir_rec
    cmp cx,128
        jb faz_nada
    cmp cx,192
        jb botao_hist
    cmp cx,256
        jb faz_nada
    cmp cx,320
        jb botao_sair
    jmp checa_clique

botao_abrir:
    jmp botao_abrir2
botao_sair:
    jmp botao_sair2

botao_hist:
    jmp botao_hist_2
botao_abrir_rec:
    jmp botao_abrir_rec2

botao_abrir2:
    mov byte[cor],amarelo
    call msg_abrir
    mov byte[cor],branco_intenso
    call msg_sair

    mov ax,2h
    int 33h

    mov al,byte[aberto]     
    cmp al,0
        je  vai_abrir       
    call limpa_grafico

    mov bx,[arquivo_img_handle]
    mov ah,3eh
    mov al,00h
    int 21h

vai_abrir:
    call abre_arquivo
    mov byte[cor],branco_intenso
    call msg_abrir
    mov ax,1h
    int 33h 
    jmp checa_clique

botao_abrir_rec2:
    mov byte[aberto], 0
    mov word[y_anterior],364
    mov word[x_anterior_2],320
    mov word[y_anterior_2],	0
    mov byte[x_anterior], 0 
    mov word[coluna_grafico], 0
    mov ah,0   
    mov al,[modo_anterior] 
    int 10h
    jmp ..start

botao_sair2:
    mov byte[cor],amarelo
    call msg_sair
    mov byte[cor],branco_intenso
    call msg_abrir
    call msg_hist
    mov ax,1h
    int 33h 
    jmp sair

botao_hist_2:
    mov byte[cor],amarelo
    call msg_hist
    mov byte[cor],branco_intenso
    call msg_hist
    call msg_abrir
    call plota_grafico
    mov ax,1h
    int 33h 
    jmp checa_clique

abre_arquivo:
    pushf
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp

    mov	word[num_count],0

    mov ah,3dh        
    mov al,00h
    mov dx,arquivo_img
    int 21h
    mov [arquivo_img_handle],ax
    lahf                
    and ah,01           
    cmp ah,01           
        jne abriu_corretamente          
    pop	bp
    pop	di
    pop	si
    pop	dx
    pop	cx
    pop	bx
    pop	ax
    popf
ret

abriu_corretamente:
    mov byte[aberto],1
proximo_byte:
    mov bx,[arquivo_img_handle]
    mov dx,buffer
    mov cx,1
    mov ah,3Fh
    int 21h
    cmp ax,cx
        jne final_arquivo

    mov al,byte[buffer] 
    mov byte[ascii],al  

    cmp al, 48 ; compara se é maior doq '0'
        jae continua_lendo
    call junta_digitos
    call printa_foto
    mov	byte[count],0
    jmp proximo_byte
    continua_lendo:
        call 	ascii2decimal          
        inc		byte[count]
        jmp 	proximo_byte    
    final_arquivo:
        mov bx,[arquivo_img_handle]
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
    mov 	bl,byte[count]	

    cmp bl, 3
        je numero_3	
    cmp bl, 2
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

        mov 	al,byte[dezena]
        mov 	bl,10
        mul 	bl
        mov 	cx,ax	

        xor 	ah,ah
        mov 	al,byte[unidade]
        add 	cx,ax	

        jmp final_juncao

    numero_1:

        mov 	al,byte[unidade]
        xor 	ah,ah
        mov 	cx,ax	

    final_juncao:	
        mov		bx, word[num_count]
        mov 	byte[v_decimal+bx],cl
        mov 	byte[decimal],cl 
        push    bx
        mov     bx,cx
        add     bx,bx
        add		word[eixo_x+bx],1
        pop     bx
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
    call msg_hist
ret 

cria_divisorias:
    push ax       
    push bx       
    push cx       
    push dx       
    push si       
    push di   

    mov byte[cor],branco_intenso

    mov ax,320                        
    push ax
    mov ax,0
    push ax
    mov ax,320
    push ax
    mov ax,479
    push ax
    call line

    mov ax,64                        
    push ax
    mov ax,364
    push ax
    mov ax,64
    push ax
    mov ax,479
    push ax
    call line

    mov ax,128                        
    push ax
    mov ax,364
    push ax
    mov ax,128
    push ax
    mov ax,479
    push ax
    call line

    mov ax,192                        
    push ax
    mov ax,364
    push ax
    mov ax,192
    push ax
    mov ax,479
    push ax
    call line

    mov ax,256                        
    push ax
    mov ax,364
    push ax
    mov ax,256
    push ax
    mov ax,479
    push ax
    call line

    mov ax,320                        
    push ax
    mov ax,229
    push ax
    mov ax,639
    push ax
    mov ax,229
    push ax
    call line

    mov ax,0                       
    push ax
    mov ax,114
    push ax
    mov ax,320
    push ax
    mov ax,114
    push ax
    call line

    mov ax,0                       
    push ax
    mov ax,364
    push ax
    mov ax,320
    push ax
    mov ax,364
    push ax
    call line   

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax

ret   

printa_foto:    
    push    cx     
    push    ax
    push    dx
    push    bx
    mov bx, word[x_anterior]
    cmp bx, 250
        jne n_reseta_x
    mov word[x_anterior], 0
    mov bx, word[x_anterior]
    dec word[y_anterior]
    n_reseta_x:
        push bx
        inc word[x_anterior]
        mov ax, word[y_anterior]
        push ax
        ; mov dl,16
        ; mov al,byte[decimal]
        ; xor ah,ah
        ; div dl   
        ; mov byte[cor],al

        xor ax,ax
        mov al,byte[decimal]
        cmp ax,63
            jbe eh_preto
        cmp ax,127
            jbe eh_cinza
        cmp ax,191
            jbe eh_branco
        cmp ax,255
            jbe eh_branco_2

        eh_preto:
            mov byte[cor],preto
            jmp plota_no_xy
        eh_cinza:
            mov byte[cor],cinza
            jmp plota_no_xy
        eh_branco:
            mov byte[cor],branco
            jmp plota_no_xy
        eh_branco_2:
            mov byte[cor],branco_intenso
            jmp plota_no_xy
        plota_no_xy:
        call plot_xy
    pop   bx
    pop   dx
    pop   ax    
    pop   cx
ret

limpa_grafico:    
    push    cx     
    push    ax
    push    dx
    push    bx
    mov word[linha_atual],0
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
    ; mov bx, word[coluna_grafico]
    ; cmp bx, word[num_count]
    ; jle coluna_valida
    mov word[coluna_grafico], 0
    ; garantindo que o primeiro valor do histograma vai ser o primeiro valor do vetor
    ; garantindo q o primeiro vai ser devidamente escalado
    mov dx,word[eixo_x]

    mov ax,dx
    div byte[escala]  
    xor ah,ah
    mov word[y_anterior_2], ax

    coluna_valida:	
        mov bx, 320
        mov cx, 256	
    printar:
        ; x1
        ; x1 começa em 321, na meiuca do gráfico
        mov ax, bx
        add ax,1	
        push ax

        ; y1
        ; y1 começa pegando o primeiro valor no eixo, mas ele precisa sofrer uma escala tbm
        mov ax, 1
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
        mov dx, word[eixo_x+bx]
        add bx,2
        mov word[coluna_grafico], bx			
        pop bx

        mov ax,dx
        xor dx,dx
        div word[escala] 
        mov word[y_anterior_2], ax
        push ax

        call line    
    loop printar 
    pop		bp
    pop		di
    pop		si
    pop		dx
    pop		cx
    pop		bx
    pop		ax
    popf
ret

msg_abrir:

    push ax
    push bx
    push cx
    push dx
    mov cx,5      
    mov bx,0
    mov dh,2     
    mov dl,1      
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
    mov dh,2      
    mov dl,34      
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

msg_hist:

    push ax
    push bx
    push cx
    push dx
    mov cx,4      
    mov bx,0
    mov dh,2      
    mov dl,18     
    loop_msg_hist:
        call cursor
        mov al,[bx+mens3]
        call  caracter
        inc bx      
        inc dl     
    loop loop_msg_hist
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
    mens3			db    	'Hist'
    arquivo_img		db		'farol.txt',0
    arquivo_img_handle   	dw      0
    aberto        	db    	0
    ascii			db		0
    buffer        	resb  	10
    unidade			db    	0
    dezena			db    	0
    centena			db    	0
    count			dw		0
    deslocamento    db		0
    num_count		dw		0
    decimal			db		0
    v_decimal		resb 	62500
    coluna_grafico	    dw      0
    x_anterior		    dw		0
    y_anterior		    dw		364
    x_anterior_2	    dw		320
    y_anterior_2	    dw		1
    eixo_x			resw	255 ; pode ir de 0 256**2 -1
    linha_atual   	dw    	0
    coluna_atual  	dw    	0
    escala			dw		3

segment stack stack
resb    512
stacktop: