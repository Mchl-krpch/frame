locals
.186
.model tiny

.code
org 100h

EXIT_CONST = 04C00H
VIDEO_PTR  = 0B800H
SCR_LENGH  =    80D
LINE_NUMB  =    24D


start:
	CALL	setVideo
	CALL	setMemory
	CALL	pause

	MOV	cx, 8d
	CALL	openAnimation
	CALL	adDInfo

	CALL	pause
	CALL	inputWriting

	CALL	closeAnimation
	CALL	exit

; #=============================================#
; #brief |input of one user symbol in frame
; #use:  |{DX, DI, AX}[with save], 
; #dest. |
inputWriting proc

	PUSH	DX
	PUSH	DI

	PUSH	DX
	PUSH	AX
	PUSH	BX
	MOV 	BX,offset strAttr
	MOV 	DX,[BX + 2d]
	ADD 	DX,1d

	MOV 	[BX + 12d],DX

	MOV 	AX,80d
	mul 	DX
	MOV 	DX,[BX]
	ADD 	DX,2d

	MOV 	[BX + 10d],DX

	ADD 	AX,DX
	SHL 	AX,1
	MOV 	DI,AX


	POP 	BX
	POP 	AX
	POP 	DX
	xor 	AX,AX
	; #-------------------- saving & prepare data

	CALL 	nextChar

	; #----------------------------- RETurn data
	POP 	DI
	POP 	DX

	RET
endp
; #---------------------------------------------#


checkOffset proc
	PUSH	DX
	PUSH	AX
	PUSH	BX
	MOV 	BX,offset strAttr
	MOV 	AX,[BX + 10d]
	ADD 	AX,2d
	MOV 	[BX + 10d],AX
	MOV 	DX,SCR_LENGH
	sub 	DX,[BX + 4d]
	sub 	DX,[BX]
	sub 	DX,4d
	SHL 	DX,1d
	cmp 	AX,DX

	jb		@@doNothing

	MOV 	AX,es:[DI - 2d]		; #delete flash-effect for input char
	sub 	ah,80h
	MOV 	es:[DI - 2d],AX

	MOV 	AX,[BX + 10d]
	xor 	AX,AX
	MOV 	[BX + 10d],AX

	MOV 	AX,80d
	MOV 	DX,[BX + 12d]
	ADD 	DX,2d
	MOV 	[BX + 12d],DX
	mul 	DX

	MOV 	DX,[BX]
	ADD 	DX,2d
	ADD 	AX,DX
	SHL 	AX,1

	MOV 	DI,AX
	MOV 	al,001h
	MOV 	es:[DI],al

@@doNothing:
	POP 	BX
	POP 	AX
	POP 	DX
	RET
endp


; #=============================================#
; #brief |input of one user symbol in frame
; #use:  |DI, AX[with save], 
; #dest. |{DI}
nextChar proc

	PUSH 	AX
	; #-------------------- saving & prepare data

@@repeatInput:
	; #ADD flash effect to cursor
	MOV 	AX,es:[DI]
	or 		ah,80h
	MOV 	es:[DI],AX

	xor 	AX,AX
	MOV 	al,05fh
	MOV 	es:[DI],al
	; #------------------------------------------

	xor 	AX,AX
	int 	16h

	cmp 	al,08h
	je 		eraseSymbol

	cmp 	al,0Dh
	je 		@@endWriting

	MOV 	es:[DI],al
	ADD 	DI,2d
	; #------------------------------------------

	CALL 	checkOffset
	
	; #------------------------------------------

	MOV 	AX,es:[DI - 2d]		; #delete flash-effect for input char
	sub 	ah,80h
	MOV 	es:[DI - 2d],AX
	; #------------------------------------------

	backToChar:
	cmp 	al,0Dh
	jne 	@@repeatInput
@@endWriting:

	; #------------------------------ RETurn data
	POP 	AX
	RET
endp
; #---------------------------------------------#


; #=============================================#
; #brief |delete last user symbol
; #use:  |DI, AX[with save], 
; #dest. |{DI}
eraseSymbol proc

	PUSH	AX
	PUSH	BX
	; #---------------

	MOV 	AX,[BX + 2d]
	MOV 	es:[DI],AX
	sub 	DI,2d
	MOV 	es:[DI],AX

	MOV 	BX,offset strAttr
	MOV 	AX,[BX + 10d]
	sub 	AX,2d
	MOV 	[BX + 10d],AX

	; #----------------
	POP 	BX
	POP 	AX
	jmp 	backToChar

	RET
endp
; #---------------------------------------------#



; #========================================================
; #brief |ADD instruction about window
; #use:  |{AX, BX, DX, DI}[with save], 
; #dest. |
adDInfo proc

	PUSH 	DX
	PUSH 	AX
	PUSH 	BX
	PUSH 	DI
	; #-------------------- saving & prepare data

	MOV 	DI,(21d * 80d + 10d) * 2d

	MOV 	AX,[BX + 2d]
	MOV 	BX,offset message
	MOV 	al,[BX]
	cld

@@symbol:
	cmp 	al, 0
	je 		@@final

	stosw
	inc 	BX
	MOV 	al, [BX]
	jmp 	@@symbol

	; #----------------------------- RETurn data
@@final:
	POP 	DI
	POP 	BX
	POP 	AX
	POP 	DX

	RET
endp
; #--------------------------------------------------------


; #========================================================
; #brief |starts the function of drawing a frame with
; #      |DIfferent attributes
;
; #use:  |{strAttr array, BX, AX}
; #dest. |{strAttr}
closeAnimation proc
	
	MOV 	BX,offset strAttr
	MOV 	cx,LINE_NUMB
	MOV 	AX,[BX + 2d]
	sub 	cx,AX
	MOV 	AX,[BX + 6d]
	sub 	cx,AX

	PUSH 	BX
	PUSH 	AX
	xor 	AX,AX
	; #---------------------------------------------

@@nextCloseFrame:
	PUSH 	cx
	CALL 	drowFrame
	MOV 	BX,offset strAttr
	MOV 	AX, 1d
	ADD 	[BX + 0d],AX
	ADD 	[BX + 2d],AX
	ADD 	[BX + 4d],AX
	POP 	cx

	PUSH 	cx
	xor 	AX,AX
	MOV 	cx,1h
	MOV 	ah,86h
	int 	15h
	POP 	cx

	sub 	cx,1d
	xor 	DI,DI
	cmp 	cx,0d 
	ja 		@@nextCloseFrame

	; #---------------------------------------------
	POP 	AX
	POP 	BX
	RET
endp
; #--------------------------------------------------------


; #========================================================
; #brief |starts the function of drawing a frame with
; #      |DIfferent attributes
;
; #use:  |{strAttr array, BX, AX}
; #dest. |{strAttr}
openAnimation proc
	
	PUSH 	BX
	PUSH 	AX
	xor 	AX,AX
	; #---------------------------------------------

	MOV 	BX,offset strAttr
	ADD 	[BX + 0d],cx
	ADD 	[BX + 2d],cx
	ADD 	[BX + 4d],cx
	ADD 	[BX + 6d],cx

@@nextOpenFrame:
	PUSH 	cx
	CALL 	drowFrame
	MOV 	BX,offset strAttr
	MOV 	AX, 1d
	sub 	[BX + 0d],AX
	sub 	[BX + 2d],AX
	sub 	[BX + 4d],AX
	sub 	[BX + 6d],AX
	POP 	cx

	PUSH 	cx
	xor 	AX,AX
	MOV 	cx,1h
	MOV 	ah,86h
	int 	15h
	POP 	cx

	sub 	cx,1d
	xor 	DI,DI
	cmp 	cx,0d 
	ja 		@@nextOpenFrame
	CALL 	drowFrame

	; #---------------------------------------------
	POP 	AX
	POP 	BX
	RET
endp
; #--------------------------------------------------------


; #========================================================
; #brief |draws the entire frame
;
; #use:  |{strAttr array, BX, cx, bp, cx, AX}
; #dest. |{DI, bp}
drowFrame proc

	MOV 	BX,offset strAttr
	PUSH	[BX + 2d]   	; #vertical attrs
	PUSH	[BX + 6d]		;

	PUSH	[BX + 0d]		; #horizontal attrs
	PUSH	[BX + 4d] 		;
	MOV 	BX,offset colors1
	; #---------------------------------------------

	MOV 	bp,sp
	MOV 	cx,[bp + 6d]
@@emptyLines:
	CALL	EmptyLine
	loop	@@emptyLines

	CALL 	UpLine

	MOV 	BX,offset strAttr
	MOV 	cx,LINE_NUMB
	MOV 	AX,[BX + 2d]
	sub 	cx,AX
	MOV 	AX,[BX + 6d]
	sub 	cx,AX
	MOV 	BX,offset colors1

@@windowLines:
	CALL	WindowLine
	loop	@@windowLines

	CALL	DownLine

	MOV		BX,offset strAttr
	MOV		cx,[BX + 6d]
	MOV		BX,offset colors1
@@emptyDownLines:
	CALL 	EmptyLine
	loop 	@@emptyDownLines

	; #---------------------------------------------
	POP 	AX
	POP 	AX
	POP 	AX
	POP 	AX

	RET
endp
; #--------------------------------------------------------


; #========================================================
UpLine proc
	
	PUSH	cx
	PUSH	AX
	PUSH	BX

	MOV 	bp,sp
	MOV 	cx,80d
	; #---------------------------------------------

	PUSH	[BX + 10d]
	PUSH	[BX +  4d]
	PUSH	[BX +  8d]
	PUSH	[BX +  0d]
	MOV 	BX,offset LineSymbols
	POP 	[BX + 0d]
	POP 	[BX + 2d]
	POP 	[BX + 4d]
	POP 	[BX + 6d]
	CALL 	line

	; #---------------------------------------------
	POP 	BX
	POP 	AX
	POP 	cx
	RET
endp
; #--------------------------------------------------------


; #========================================================
DownLine proc
	
	PUSH	cx
	PUSH	AX
	PUSH	BX

	MOV		bp,sp
	MOV		cx,80d
	; #---------------------------------------------

	PUSH 	[BX + 12d]
	PUSH 	[BX +  4d]
	PUSH 	[BX + 14d]
	PUSH 	[BX +  0d]
	MOV 	BX,offset LineSymbols
	POP  	[BX + 0d]
	POP  	[BX + 2d]
	POP  	[BX + 4d]
	POP  	[BX + 6d]
	CALL 	line

	; #---------------------------------------------
	POP 	BX
	POP 	AX
	POP 	cx
	RET
endp
; #--------------------------------------------------------


; #========================================================
EmptyLine proc
	
	PUSH 	cx
	PUSH 	AX
	PUSH 	BX

	MOV 	bp,sp
	MOV 	cx,80d
	; #---------------------------------------------

	PUSH	[BX + 0d]
	PUSH	[BX + 0d]
	PUSH	[BX + 0d]
	PUSH	[BX + 0d]
	MOV 	BX,offset LineSymbols
	POP  	[BX + 0d]
	POP  	[BX + 2d]
	POP  	[BX + 4d]
	POP  	[BX + 6d]
	CALL 	line

	; #---------------------------------------------
	POP 	BX
	POP 	AX
	POP 	cx
	RET
endp
; #--------------------------------------------------------


; #========================================================
WindowLine proc
	
	PUSH	cx
	PUSH	AX
	PUSH	BX

	MOV 	bp,sp
	MOV 	cx,80d
	; #---------------------------------------------

	PUSH	[BX + 6d]
	PUSH	[BX + 2d]
	PUSH	[BX + 6d]
	PUSH	[BX + 0d]
	MOV 	BX,offset LineSymbols
	POP  	[BX + 0d]
	POP  	[BX + 2d]
	POP  	[BX + 4d]
	POP  	[BX + 6d]
	CALL 	line

	; #---------------------------------------------
	POP 	BX
	POP 	AX
	POP 	cx
	RET
endp
; #--------------------------------------------------------


; #========================================================
; #brief |fill one string in screen by symbols
; #      |which placed in {DI, DI+2, DI+4} pos.
;
; #use:  |config ptr
; #dest. |{DI}
line proc

	MOV 	AX,[BX + 0d] 		; # _ _ _ _I######I_ _ _ _ _
	MOV 	cx,[bp + 10d]		; #   ^~~~~  
	rep 	stosw               ; #    this part of str

	MOV 	AX,[BX + 2d]       ; # _ _ _ _ I######I _ _ _ _ _
	MOV 	es:[DI],AX         ; #         ^~~~~  
	ADD 	DI,2d

	MOV 	cx,SCR_LENGH       ; # _ _ _ _ I######I _ _ _ _ _
	sub 	cx,[bp + 10d]      ; #         ~~~~^  
	sub 	cx,[bp + 8d]       
	sub 	cx,2d 				; #sub 2d for borders
	MOV 	AX,[BX + 4d]
	rep 	stosw

	MOV 	AX,[BX + 6d]       ; # _ _ _ _ I######I _ _ _ _ _
	MOV 	es:[DI],AX         ; #            ~~~~^  
	ADD 	DI,2d

	MOV 	AX,[BX + 0d]       ; # _ _ _ _ I######I _ _ _ _ _
	MOV 	cx,[bp + 8d]       ; #                  ~~~~^  
	rep 	stosw
	RET
endp
; #--------------------------------------------------------


; #========================================================
; #brief |set ptt of config to BX
; #use:  |config ptr
; #dest  |{BX}
setMemory proc
	MOV 	BX,offset colors1
	RET
endp
; #--------------------------------------------------------


; #========================================================
; #brief |pause process
; #use:  |pauseConst code & 16h interrupt
; #dest  |{AX}
pause proc
	xor 	AX,AX
	int 	16h
	RET
endp
; #--------------------------------------------------------


; #========================================================
; #brief: |set to es ptr of videosegment
; #use:   |es
; #dest:  |{AX}
setVideo proc
	
	PUSH 	AX
	; #---------------------------------------------

	MOV 	AX,VIDEO_PTR
	MOV 	es,AX

	; #---------------------------------------------
	POP 	AX

	RET
endp
; #--------------------------------------------------------


; #========================================================
; #brief |kill program
; #use:  |exit code & 21h interrupt
; #dest  |Program) and AX
exit proc
	MOV 	AX,EXIT_CONST
	int 	21h
	RET
endp
; #--------------------------------------------------------

colors2:; #colors config №2
	dw 00000h 	; #01 black background		[+ 0d] # BRUSHES
	dw 00f00h 	; #02 window background		[+ 2d]
	dw 00fcdh 	; #03 horisontal border		[+ 4d]
	dw 00fbah 	; #04 vertical border		[+ 6d]
	dw 00Fc9h 	; #05 left upper corner		[+ 8d] # CORNERS
	dw 00fbbh 	; #06 right upper corner	[+10d]
	dw 00fbch 	; #07 right down corner		[+12d]
	dw 00fc8h 	; #08 left down corner		[+14d]

colors1:; #colors config №1
	dw 00000h 	; #01 black background		[+ 0d] # BRUSHES
	dw 01f00h 	; #02 window background		[+ 2d]
	dw 01fcdh 	; #03 horisontal border		[+ 4d]
	dw 01fbah 	; #04 vertical border		[+ 6d]
	dw 01Fc9h 	; #05 left upper corner		[+ 8d] # CORNERS
	dw 01fbbh 	; #06 right upper corner	[+10d]
	dw 01fbch 	; #07 right down corner		[+12d]
	dw 01fc8h 	; #08 left down corner		[+14d]

strAttr:; #string part length attributes
	dw 00008h	; #09 skip of left pixels	[+ 0d]
	dw 00003h	; #10 skip top pixels 		[+ 2d]
	dw 00008h	; #11 skip right pixels 	[+ 4d]
	dw 00003h	; #12 skip down pixels  	[+ 6d] 
	dw 00000h   	; #13 animation frame       	[+ 8d]
	dw 00000h	; #14 current pos in line 	[+ 10d]
	dw 00000h 	; #15 current line in frame 	[+ 12d]

LineSymbols:; #characters that are used when drawing the current line
	dw 00000h	; #0 empty background		[+16d]
	dw 01fbah	; #1 vertical symbol 1 		[+18d]
	dw 01f00h	; #2 window brush 		[+20d]
	dw 01fbah	; #3 vertical symbol 1 		[+22d] 


message db 'Version 0.2 Copyleft (c) 3022', 0

end start