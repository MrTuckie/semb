; Código do "hello world" da matéria

segment code
..start:
; iniciar os registros de segmento DS e SS e o ponteiro de pilha SP
	mov ax,data
	mov ds,ax
	mov ax,stack
	mov ss,ax
	mov sp,stacktop

    mov ax, 10
    mov bh, -5
	idiv bh
	neg al ; ver o que acontece quando se faz o neg -> Se a = -2, ele realmente volta pra 2
	test al,al
	jns unsigned

	signed:
    mov ah,9
	mov dx,mensagem
	int 21h
	jmp exit

	unsigned:
    mov ah,9
	mov dx,mensagem2
	int 21h
	jmp exit

; Terminar o programa e voltar para o sistema operacional
exit:
	mov ah,4ch
	int 21h
segment data
CR	equ	0dh
LF	equ 0ah
mensagem db 'sou negativo',CR,LF,'$'
mensagem2 db 'sou positivo',CR,LF,'$'
segment stack stack
	resb 256
stacktop: