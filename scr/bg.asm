.model tiny

.code
org 100h

start:
	mov bx, 0b800h
	mov es, bx

	xor di, di
	xor ax, ax				; даем пользователю возможность запустить кнопкой
	int 16h

	mov cx, 14d				; сколько будет разных картинок
	mov dx, 0d				; текущий индекс цвета рамки
							; AX - основной цвет заливки [передастся в след функцию]
	call animation

	; endian
	xor ax, ax
	int 16h	
	mov ax, 4c00h
	int 21h



animation:
	xor di, di
	xor ax, ax				; проверка задержки
	int 16h

	mov bx, offset userFrame
	push di 
	mov di, dx
	mov ax, [bx + di]		; выбираем цвет в ax
	pop di

	;mov es:[di], ax
	;add di, 2d
	add dx, 2d 				; делаем предпосылку на следующий цвет
	push cx					;													1
	push dx					; - сбрасываем данные в стек (славься стек)			2
			
	mov cx, 24d				; счетчик строк в вертикальном цикле
	call verticleLoop


	pop dx					;													1
	pop cx					;													2

	sub cx, 2d
	cmp cx, 0d
	ja animation
	ret


verticleLoop:
	sub cx, 1d    			; считаем строки

	push cx					;													1
	mov cx, 80d
	call drowLine
	pop cx					;													1

	cmp cx, 0d
	ja verticleLoop
	ret


drowLine proc
	sub cx, 1d
	mov es:[di], ax
	add di, 2d

	cmp cx, 0d 
	ja drowLine
	ret
endp

.data
userFrame:
	dw 00000h
	dw 01000h 
	dw 02000h
	dw 03000h
	dw 04000h
	dw 05000h
	dw 06000h
	dw 07000h

end start