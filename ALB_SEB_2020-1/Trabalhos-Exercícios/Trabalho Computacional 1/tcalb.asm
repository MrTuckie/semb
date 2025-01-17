; Código feito por Arthur Lorencini Bergamaschi - 2016101335
; Turma 06.3 - Sistemas Embarcados I
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
	

start:
	mov ah,0bh
	int 21h ; Le buffer de teclado
	cmp al,0 ; Se AL =0 nada foi digitado. Se AL =255 então há algum caracter na STDIN
	jne adelante
	jmp segue ; se AL = 0 então nada foi digitado e a animação do jogo deve continuar
adelante:
	mov ah, 08H ;Ler caracter da STDIN
	int 21H
	cmp al, 's' ;Verifica se foi 's'. Se foi, finaliza o programa
	jne segue
	jmp sai
segue:

continue:

	borders:
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
		
	circles: 
		; A ideia aqui é fazer o círculo preencher e apagar, dando a impressão de movimento.
		mov		byte[cor],vermelho
		mov		ax,[xPos]
		push	ax
		mov		ax,[yPos]
		push	ax
		mov		ax,[raio]
		push	ax
		call	full_circle

		push 	cx
		call 	delay
		pop 	cx

		mov		byte[cor],preto
		mov		ax,[xPos]
		push	ax
		mov		ax,[yPos]
		push	ax
		mov		ax,[raio]
		push	ax
		call	full_circle
	

; Explicando como a bolinha "anda"
; Dependendo do valor da posição (x ou y), ele vai comparar com seus respectivos limites e a partir daí,
; vai escolher o que fazer com as variáveis da posição (se incrementa ou não)

; É mais fácil pensar nela indo pra direita e pra esquerda primeiro, depois adicionar o mesmo sentido só que
; para cima e para baixo. A soma dos dois movimentos dá a impressão de andar na diagonal.

xMovement:

		cmp word[xPos],rightLimit
		jae left
		cmp word[xPos],leftLimit
		jle right
		jmp xMove
		
	left:
		mov word[xStep],-step
		jmp xMove

	right:
		mov word[xStep],step
		jmp xMove
		
	xMove:
		mov ax,word[xStep]
		add word[xPos],ax 

yMovement:

	cmp word[yPos],upLimit
	jae down
	cmp word[yPos],downLimit
	jle up
	jmp continuaY

	down:
		mov word[yStep],-step
		jmp continuaY

	up:
		mov word[yStep],step
		jmp continuaY

	continuaY:
		mov ax,word[yStep]
		add word[yPos],ax 	

jmp start


delay: 
	mov cx, word [velocidade] ; Carrega “velocidade” em cx (contador para loop)
del2:
	push cx ; Coloca cx na pilha para usa-lo em outro loop
	mov cx, 0800h ; Teste modificando este valor
del1:
	loop del1 ; No loop del1, cx é decrementado até que volte a ser zero
	pop cx ; Recupera cx da pilha
	loop del2 ; No loop del2, cx é decrementado até que seja zero
ret


sai:
	mov ah,0 ; set video mode
	mov al,[modo_anterior] ; recupera o modo anterior
	int 10h
	mov ax,4c00h
	int 21h

; Comentário para o professor:
; Adicionei essa label "functions" só para poder "contrair" no meu editor de texto.
functions:

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

; Minhas variáveis

xPos			dw		12
yPos			dw		468
raio			dw		10

; Comentário para o professor:
; Começar no que seria o (0,0) está dando problemas na
; hora de desenhar a bola, o senhor pode testar se quiser.
; Resolvi colocar o mais próximo possível do canto superior esquerdo.

velocidade		dw		20
yStep			dw		2
xStep			dw		2
step			equ		10
rightLimit		equ		630
leftLimit		equ		12
upLimit			equ		470
downLimit		equ		10
;*************************************************************************
segment stack stack
    		resb 		512
stacktop:


