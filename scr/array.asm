.model tiny

.code
org 100h

start:
	mov bx, 0b800h
	mov es, bx
	xor bx, bx

	mov ax, 01000h
	mov es:[12d * 80d + 40d], ax

	call pauseCatchKey

	mov ah, 020h
	mov al, 000h

	mov es:[12d * 80d + 40d], ax

	call pauseCatchKey

	mov bx, offset array
	mov al, [bx]
	mov ah, 020h

	mov es:[12d * 80d + 40d], ax

	mov ax, 4c00h
	int 21h


; # input  ()
; 
; # need   (ax, bx)
;
; # destroy {ax, bx}
;
pauseCatchKey:
	; #catch key
	xor ax, ax
	int 16h
	mov bx, offset array
	mov [bx], al

	; #destroy {bx, ax}
	xor bx, bx
	xor ax, ax
	ret

array:
	db 000h
	db 000h
	db 000h

.data

end start