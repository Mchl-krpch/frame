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
	mov ax, 12d 					; #number of screen
	mov [bx + 38d], ax			; #(for zoom)


	;#change style of frame
	; ##########################################
	push ax
		mov ax, 00000h
		mov [bx + 0d], ax		; #outside bg

		mov ax, 00f00h
		mov [bx + 2d], ax		; #window bg

		mov ax, 00fcdh
		mov [bx + 4d], ax		; #hor. border
		
		mov ax, 00fbah
		mov [bx + 6d], ax		; #ver. border
		
		mov ax, 00fc9h
		mov [bx + 8d], ax		; #lu corner
		
		mov ax, 00fbbh
		mov [bx + 10d], ax		; #ru corner

		mov ax, 00fbch
		mov [bx + 12d], ax		; #rd corner

		mov ax, 00fc8h
		mov [bx + 14d], ax		; #ld corner

		mov ax, 30d				; #right skip correction
		mov [bx + 18d], ax

		mov ax, 14d				; #down skip correction
		mov [bx + 20d], ax

		mov ax, 30d				; #down skip correction
		mov [bx + 22d], ax
	pop ax
	; ##########################################

	call animation
	call addInfo
	call addInst
	call inputWriting
	call abort





addInfo proc
	push dx
	push ax
	push bx
	push di
	; #=====================
	mov di, (20d * 80d + 18d) * 2d

	mov ax, [bx + 2d]
	mov bx, offset message
	mov al, [bx]
	cld

	symbol:
	cmp al, 0
	je final

	stosw

	inc bx

	mov al, [bx]
	jmp symbol


	; #=====================
	final:
	pop di
	pop bx
	pop ax
	pop dx
	ret
endp

addInst proc
	push dx
	push ax
	push bx
	push di
	; #=====================
	mov di, (19d * 80d + 18d) * 2d

	mov ax, [bx + 2d]
	mov bx, offset instruction
	mov al, [bx]
	cld

	symbolInst:
	cmp al, 0
	je final

	stosw

	inc bx

	mov al, [bx]
	jmp symbolInst


	; #=====================
	finalInst:
	pop di
	pop bx
	pop ax
	pop dx
	ret
endp

instruction db 'type something...', 0
message db 'Version 0.1 Copyleft (c) 3022', 0


; #=============================================#
; #brief |generate animation of frame
; #use:  |{ax, cx, di}[with save], 
; #dest. |
animation proc
	push ax
	push cx
	push di
	; #-------------------- saving & prepare data

	nextFrame:
	xor di, di
	call drowScreen

	mov ax, [bx + 18d]
	sub ax, 1d				; #right skip correction
	mov [bx + 18d], ax

	mov ax, [bx + 20d]
	sub ax, 1d				; #down skip correction
	mov [bx + 20d], ax

	mov ax, [bx + 22d]
	sub ax, 1d				; #down skip correction
	mov [bx + 22d], ax


	mov cx, 3h
	;mov dx, 4050h
	mov ah, 86h
	int 15h

	mov di, 0d
	mov [bx + 24d], di
	call drowScreen
	mov ax, [bx + 38d]
	sub ax, 1d
	mov [bx + 38d], ax
	cmp ax, 0d 
	ja nextFrame

	; #----------------------------- return data
	pop di
	pop cx
	pop ax
	ret
endp
; #---------------------------------------------#


; #=============================================#
; #brief |input of one user symbol in frame
; #use:  |{dx, di, ax}[with save], 
; #dest. |
inputWriting proc
	push dx
	push di
	; #-------------------- saving & prepare data

	mov di, (80d * 8d + 18d) * 2d
	call nextChar

	; #----------------------------- return data
	pop di
	pop dx
	ret
endp
; #---------------------------------------------#


; #=============================================#
; #brief |input of one user symbol in frame
; #use:  |di, ax[with save], 
; #dest. |{di}
nextChar proc

	push ax
	; #-------------------- saving & prepare data

	repeatInput:
	; #add flash effect to cursor
	mov ax, es:[di]
	or ah, 80h
	mov es:[di], ax

	xor ax, ax
	mov al, 0dbh
	mov es:[di], al
	; #------------------------------------------

	xor ax, ax
	int 16h

	cmp al, 08h
	je erraseSymbol

	cmp al, 0Dh
	je endWriting

	mov es:[di], al

	mov es:[di], al
	add di, 2d
	; #delete flash-effect for input char
	mov ax, es:[di - 2d]
	sub ah, 80h
	mov es:[di - 2d], ax
	; #------------------------------------------

	a:
	cmp al, 0Dh
	jne repeatInput
	endWriting:

	; #------------------------------ return data
	pop ax

	ret
endp
; #---------------------------------------------#


; #=============================================#
; #brief |delete last user symbol
; #use:  |di, ax[with save], 
; #dest. |{di}
erraseSymbol proc
	push ax
	; #---------------
	mov ax, [bx + 2d]
	mov es:[di], ax
	sub di, 2d
	mov es:[di], ax
	; #----------------
	;mov al, 00h
	;mov es:[di], al
	;sub di, 2d
	;mov es:[di], al
	pop ax
	jmp a
endp
; #---------------------------------------------#


; #=============================================#
; #brief |drow 24 strings in videosegment
; #use:  |CX
; #dest. |
drowScreen proc
	push cx
	mov cx, strNum
	; #-------------------- saving & prepare data

	repeat:
	sub cx, 1d
	call chooseLine
	cmp cx, 0d
	ja repeat

	; #------------------------------ return data
	pop cx
	ret
endp
; #---------------------------------------------#


; #=============================================#
; #brief |choose needed string depend cx value
; #use:  |CX
; #dest. |
chooseLine proc

	push cx
	; #------------------ saving & prepare data

	cmp cx, [bx + 20d]
	jb black
	je down
	jae upper
	a3:

	call drowLine
	; #--------------------------- return data
	pop cx

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
; #---------------------------------------------#


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
	dw 01f00h 	; #02 window background		[+ 2d]
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