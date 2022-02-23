.model tiny

.code
org 100h

EXIT_CONST = 04C00H
VIDEO_PTR  = 0B800H
SCR_LENGH  =    80D
LINE_NUMB  =    24D


start:
	call setVideo
	call setMemory
	call pause

	mov cx, 4d
	call openAnimation
	;call addInfo

	call pause

	call closeAnimation
	call exit

; #========================================================
; #brief |Add instruction about window
; #use:  |{ax, bx, dx, di}[with save], 
; #dest. |
addInfo proc

	push dx
	push ax
	push bx
	push di
	; #-------------------- saving & prepare data

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

	; #----------------------------- return data
	final:
	pop di
	pop bx
	pop ax
	pop dx

	ret
endp
; #--------------------------------------------------------

message db 'Version 0.1 Copyleft (c) 3022', 0

; #========================================================
; #brief |starts the function of drawing a frame with
; #      |different attributes
;
; #use:  |{strAttr array, bx, ax}
; #dest. |{strAttr}
closeAnimation proc
	
	mov bx, offset strAttr
	mov cx, LINE_NUMB
	mov ax, [bx + 2d]
	sub cx, ax
	mov ax, [bx + 6d]
	sub cx, ax

	push bx
	push ax
	xor ax, ax
	; #---------------------------------------------

	nextCloseFrame:
	push cx
	call drowFrame
	mov bx, offset strAttr
	mov ax, 1d
	add [bx + 0d], ax
	add [bx + 2d], ax
	add [bx + 4d], ax
	pop cx

	push cx
	xor ax, ax
	mov cx, 1h
	mov ah, 86h
	int 15h
	pop cx

	sub cx, 1d
	xor di, di
	cmp cx, 0d 
	ja nextCloseFrame

	; #---------------------------------------------
	pop ax
	pop bx
	ret
endp
; #--------------------------------------------------------


; #========================================================
; #brief |starts the function of drawing a frame with
; #      |different attributes
;
; #use:  |{strAttr array, bx, ax}
; #dest. |{strAttr}
openAnimation proc
	
	push bx
	push ax
	xor ax, ax
	; #---------------------------------------------

	mov bx, offset strAttr
	add [bx + 0d], cx
	add [bx + 2d], cx
	add [bx + 4d], cx
	add [bx + 6d], cx

	nextOpenFrame:
	push cx
	call drowFrame
	mov bx, offset strAttr
	mov ax, 1d
	sub [bx + 0d], ax
	sub [bx + 2d], ax
	sub [bx + 4d], ax
	sub [bx + 6d], ax
	pop cx

	push cx
	xor ax, ax
	mov cx, 3h
	mov ah, 86h
	int 15h
	pop cx

	sub cx, 1d
	xor di, di
	cmp cx, 0d 
	ja nextOpenFrame
	call drowFrame
	

	; #---------------------------------------------
	pop ax
	pop bx
	ret
endp
; #--------------------------------------------------------


; #========================================================
; #brief |draws the entire frame
;
; #use:  |{strAttr array, bx, cx, bp, cx, ax}
; #dest. |{di, bp}
drowFrame proc

	mov bx, offset strAttr
	push [bx + 2d]   	; #vertical attrs
	push [bx + 6d]		;

	push [bx + 0d]		; #horizontal attrs
	push [bx + 4d] 		;
	mov bx, offset colors1
	; #---------------------------------------------

	mov bp, sp
	mov cx, [bp + 6d]
	emptyLines:
	call EmptyLine
	loop emptyLines

	call UpLine

	mov bx, offset strAttr
	mov cx, LINE_NUMB
	mov ax, [bx + 2d]
	sub cx, ax
	mov ax, [bx + 6d]
	sub cx, ax
	mov bx, offset colors1

	windowLines:
	call WindowLine
	loop windowLines

	call DownLine

	mov bx, offset strAttr
	mov cx, [bx + 6d]
	mov bx, offset colors1
	emptyDownLines:
	call EmptyLine
	loop emptyDownLines

	; #---------------------------------------------
	pop ax
	pop ax
	pop ax
	pop ax

	ret
endp
; #--------------------------------------------------------


; #========================================================
UpLine proc
	
	push cx
	push ax
	push bx

	mov bp, sp
	mov cx, 80d
	; #---------------------------------------------

	push [bx + 10d]
	push [bx +  4d]
	push [bx +  8d]
	push [bx +  0d]
	mov bx, offset LineSymbols
	pop  [bx + 0d]
	pop  [bx + 2d]
	pop  [bx + 4d]
	pop  [bx + 6d]
	call line

	; #---------------------------------------------
	pop bx
	pop ax
	pop cx

	ret
endp
; #--------------------------------------------------------


; #========================================================
DownLine proc
	
	push cx
	push ax
	push bx

	mov bp, sp
	mov cx, 80d
	; #---------------------------------------------

	push [bx + 12d]
	push [bx +  4d]
	push [bx + 14d]
	push [bx +  0d]
	mov bx, offset LineSymbols
	pop  [bx + 0d]
	pop  [bx + 2d]
	pop  [bx + 4d]
	pop  [bx + 6d]
	call line

	; #---------------------------------------------
	pop bx
	pop ax
	pop cx

	ret
endp
; #--------------------------------------------------------


; #========================================================
EmptyLine proc
	
	push cx
	push ax
	push bx

	mov bp, sp
	mov cx, 80d
	; #---------------------------------------------

	push [bx + 0d]
	push [bx + 0d]
	push [bx + 0d]
	push [bx + 0d]
	mov bx, offset LineSymbols
	pop  [bx + 0d]
	pop  [bx + 2d]
	pop  [bx + 4d]
	pop  [bx + 6d]
	call line

	; #---------------------------------------------
	pop bx
	pop ax
	pop cx

	ret
endp
; #--------------------------------------------------------


; #========================================================
WindowLine proc
	
	push cx
	push ax
	push bx

	mov bp, sp
	mov cx, 80d
	; #---------------------------------------------

	push [bx + 6d]
	push [bx + 2d]
	push [bx + 6d]
	push [bx + 0d]
	mov bx, offset LineSymbols
	pop  [bx + 0d]
	pop  [bx + 2d]
	pop  [bx + 4d]
	pop  [bx + 6d]
	call line

	; #---------------------------------------------
	pop bx
	pop ax
	pop cx

	ret
endp
; #--------------------------------------------------------


; #========================================================
; #brief |fill one string in screen by symbols
; #      |which placed in {di, di+2, di+4} pos.
;
; #use:  |config ptr
; #dest. |{di}
line proc

	mov ax, [bx + 0d] 		; # _ _ _ _I######I_ _ _ _ _
	mov cx, [bp + 10d]		; #   ^~~~~  
	rep stosw               ; #    this part of str

	mov ax, [bx + 2d]       ; # _ _ _ _ I######I _ _ _ _ _
	mov es:[di], ax         ; #         ^~~~~  
	add di, 2d

	mov cx, SCR_LENGH       ; # _ _ _ _ I######I _ _ _ _ _
	sub cx, [bp + 10d]      ; #         ~~~~^  
	sub cx, [bp + 8d]       
	sub cx, 2d 				; #sub 2d for borders
	mov ax, [bx + 4d]
	rep stosw

	mov ax, [bx + 6d]       ; # _ _ _ _ I######I _ _ _ _ _
	mov es:[di], ax         ; #            ~~~~^  
	add di, 2d

	mov ax, [bx + 0d]       ; # _ _ _ _ I######I _ _ _ _ _
	mov cx, [bp + 8d]       ; #                  ~~~~^  
	rep stosw
	ret
endp
; #--------------------------------------------------------


; #========================================================
; #brief |set ptt of config to bx
; #use:  |config ptr
; #dest  |{bx}
setMemory proc
	mov bx, offset colors1
	ret
endp
; #--------------------------------------------------------


; #========================================================
; #brief |pause process
; #use:  |pauseConst code & 16h interrupt
; #dest  |{ax}
pause proc
	xor ax, ax
	int 16h
	ret
endp
; #--------------------------------------------------------


; #========================================================
; #brief: |set to es ptr of videosegment
; #use:   |es
; #dest:  |{ax}
setVideo proc
	
	push ax
	; #---------------------------------------------

	mov ax, VIDEO_PTR
	mov es, ax

	; #---------------------------------------------
	pop ax

	ret
endp
; #--------------------------------------------------------


; #========================================================
; #brief |kill program
; #use:  |exit code & 21h interrupt
; #dest  |Program) and ax
exit proc
	mov ax, EXIT_CONST
	int 21h
	ret
endp
; #--------------------------------------------------------


; #colors config №2
colors2:
	dw 00000h 	; #01 black background		[+ 0d] # BRUSHES
	dw 00f00h 	; #02 window background		[+ 2d]
	dw 00fcdh 	; #03 horisontal border		[+ 4d]
	dw 00fbah 	; #04 vertical border		[+ 6d]
	dw 00Fc9h 	; #05 left upper corner		[+ 8d] # CORNERS
	dw 00fbbh 	; #06 right upper corner	[+10d]
	dw 00fbch 	; #07 right down corner		[+12d]
	dw 00fc8h 	; #08 left down corner		[+14d]


; #colors config №1
colors1:
	dw 00000h 	; #01 black background		[+ 0d] # BRUSHES
	dw 01f00h 	; #02 window background		[+ 2d]
	dw 01fcdh 	; #03 horisontal border		[+ 4d]
	dw 01fbah 	; #04 vertical border		[+ 6d]
	dw 01Fc9h 	; #05 left upper corner		[+ 8d] # CORNERS
	dw 01fbbh 	; #06 right upper corner	[+10d]
	dw 01fbch 	; #07 right down corner		[+12d]
	dw 01fc8h 	; #08 left down corner		[+14d]

; #string part length attributes
strAttr:
	dw 00012h	; #09 skip of left pixels	[+ 0d]
	dw 00006h	; #10 skip top pixels 		[+ 2d]
	dw 00012h	; #11 skip right pixels 	[+ 4d]
	dw 00006h	; #12 skip down pixels  	[+ 6d] 
	dw 00000h   ; #13 animation frame       [+ 8d]

; #characters that are used when drawing the current line
LineSymbols:
	dw 00000h	; #0 empty background		[+16d]
	dw 01fbah	; #1 vertical symbol 1 		[+18d]
	dw 01f00h	; #2 window brush 			[+20d]
	dw 01fbah	; #3 vertical symbol 1 		[+22d] 

end start