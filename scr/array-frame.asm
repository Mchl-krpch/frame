.model tiny

.code
org 100h

videoPtr 	= 0b800h
scrLen   	= 80d
strNum   	= 24d
kokConst 	= 4C00h
margin		= 4d

start:
	call setVideo
	call pause
	call setMemory
	mov ax, 6d 					; #number of screen
	mov ax, [bx + 38d]			; #(for zoom)	

	call drowScreen
	call abort








; #=============================================#
; #brief |drow 24 strings in videosegment
; #use:  |CX
; #dest. |
drowScreen proc
	push cx
	mov cx, strNum

	repeat:
	sub cx, 1d
	call chooseLine
	cmp cx, 0d
	ja repeat

	pop cx
	ret
endp
; #---------------------------------------------#


; #=============================================#
; #brief |choose needed string depend cx value
; #use:  |CX
; #dest. |
chooseLine proc
	push dx
	push cx
	; #------------------ saving & prepare data
	mov dx, cx

	cmp dx, margin
	jb black
	je down
	jae upper

	a3:

	call drowLine

	; #--------------------------- return data
	pop cx
	pop dx
	ret
endp
; #---------------------------------------------#


down:
call setDownBorder
jmp a3

up:
call setUpBorder
jmp a3

black:
call setBlackSymbols
jmp a3

upper:
cmp cx, [bx + 16d]
ja black
je up
jb window
jmp a3

window:
call setWindowSymbols
jmp a3


; #=============================================#
; #brief |sets symbols of frame
; #use:  |ax and array-memory
; #dest  |
setUpBorder proc
	push ax
	; #left				; SET USER'S SYMBOLS
	mov ax, [bx + 00d]	;
	mov [bx + 28d], ax	;
	; #left UP corner 	;
	mov ax, [bx + 8d]	;
	mov [bx + 30d], ax	;
	; #window bg 		;
	mov ax, [bx + 4d]	;
	mov [bx + 32d], ax	;
	; #right border		;
	mov ax, [bx + 10d]	;
	mov [bx + 34d], ax	;
	pop ax
	ret
endp


setDownBorder proc
	push ax
	; #left				; SET USER'S SYMBOLS
	mov ax, [bx + 00d]	;
	mov [bx + 28d], ax	;
	; #left down corner ;
	mov ax, [bx + 14d]	;
	mov [bx + 30d], ax	;
	; #window bg 		;
	mov ax, [bx + 4d]	;
	mov [bx + 32d], ax	;
	; #right border		;
	mov ax, [bx + 12d]	;
	mov [bx + 34d], ax	;
	pop ax
	ret
endp


setWindowSymbols proc
	push ax
	; #left				; SET USER'S SYMBOLS
	mov ax, [bx + 00d]	;
	mov [bx + 28d], ax	;
	; #left border		;
	mov ax, [bx + 6d]	;
	mov [bx + 30d], ax	;
	; #window bg 		;
	mov ax, [bx + 2d]	;
	mov [bx + 32d], ax	;
	; #right border		;
	mov ax, [bx + 6d]	;
	mov [bx + 34d], ax	;
	pop ax
	ret
endp


setBlackSymbols proc
	push ax
	; #left				; SET USER'S SYMBOLS
	mov ax, [bx + 0d]	;
	mov [bx + 28d], ax	;
	; #left border		;
	mov ax, [bx + 0d]	;
	mov [bx + 30d], ax	;
	; #window bg 		;
	mov ax, [bx + 0d]	;
	mov [bx + 32d], ax	;
	; #right border		;
	mov ax, [bx + 0d]	;
	mov [bx + 34d], ax	;
	pop ax
	ret
endp



; #=============================================#
; #brief |fill one string in screen by symbols
; #      |which placed in {di, di+2, di+4} pos.
;
; #use:  |config ptr
; #dest. |{DI}
drowLine proc

	push di
	xor di, di
	mov di, (2 * 80d)
	push cx
	xor cx, cx
	push ax

	; #------------------ saving & prepare data

	mov di, [bx + 24d]
	sub di, 4d
	mov cx, [bx + 22d]
	mov ax, [bx + 28d]
	rep stosw			; # fill line
	mov ax, [bx + 30d]	;
	mov cx, 1
	repe stosw			; #after that set 
						; #last symbol

	mov cx, scrLen
	sub cx, [bx + 18d]
	sub cx, [bx + 22d]
	mov ax, [bx + 32d]
	rep stosw			; #fill line
	mov ax, [bx + 34d]	;
	mov cx, 1
	repe stosw			; #after that set 
						; #last symbol


	mov cx, [bx + 18d]
	mov ax, [bx + 28d]
	rep stosw

	; #--------------------------- return data
	mov [bx + 24d], di
	pop ax
	pop cx
	pop di

	ret
endp
; #---------------------------------------------#


; #=============================================#
; #brief |set ptt of config to bx
; #use:  |config ptr
; #dest  |{BX}
setMemory proc
	mov bx, offset config
	ret
endp
; #---------------------------------------------#


; #=============================================#
; #brief |pause process
; #use:  |pauseConst code & 16h interrupt
; #dest  |{AX}
pause proc
	xor ax, ax
	int 16h
	ret
endp
; #---------------------------------------------#


; #=============================================#
; #brief |kill program
; #use:  |abort code & 21h interrupt
; #dest  |Program) and ax
abort proc
	mov ax, kokConst
	int 21h
	ret
endp
; #---------------------------------------------#


; #=============================================
; #brief: |set to es ptr of videosegment
; #use:   |es
; #dest:  |{AX}
setVideo proc
	mov ax, videoPtr
	mov es, ax
	xor ax, ax
	ret
endp
; #---------------------------------------------#

config:
	dw 00000h 	; #01 black background		[+ 0d] # BRUSHES
	dw 01000h 	; #02 window background		[+ 2d]
	dw 01fcdh 	; #03 horisontal border		[+ 4d]
	dw 01fbah 	; #04 vertical border		[+ 6d]
	dw 01Fc9h 	; #05 left upper corner		[+ 8d] # CORNERS
	dw 01fbbh 	; #06 right upper corner	[+10d]
	dw 01fbch 	; #07 right down corner		[+12d]
	dw 01fc8h 	; #08 left down corner		[+14d]

	dw 00016d	; #09 skip of top pixels 	[+16d] # SKIPS
	dw 00016h	; #10 skip right pixels		[+18d]
	dw 00007h	; #11 skip down pixels 		[+20d]
	dw 00016d	; #12 skip left pixels 		[+22d]

	dw 00000h	; #13 current videosegpos	[+24d] # COORDS
	dw 00000h	; #14 current Y-ccordinate  [+26d] [free bytes]

	dw 00000h	; #15 free pos to data		[+28d]
	dw 00000h	; #16 free pos to data 		[+32d]
	dw 00000h	; #16 free pos to data 		[+34d]
	dw 00000h	; #16 free pos to data 		[+36d]

	dw 00000h	; #17 current scr (in anim)	[+38d]

end start