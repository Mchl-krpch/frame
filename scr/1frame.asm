.model tiny

.code
org 100h

scrLen      = 80d
scrHigh     = 24d
marginTop   =  5d
marginDown  =  4d
marginLeft  =  7d
marginRight =  7d

start:
mov bx, 0b800h
mov es, bx

xor di, di
xor bx, bx
call verticleLoop

endian:
xor ax, ax
int 16h	
mov ax, 4c00h
int 21h

verticleLoop:					; #cycle for drow
xor cx, cx
add bx, 1
cmp bx, scrHigh + 1
jb chooseString
call endian


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; #brief 
; set one string in videosegment as up-border
;
; #input 
; ax - color
; bx - string-index in video segment
; cx - counter
; es - ptr to video segment
; di - index in string (in video segment)
;
; #destroy list
; ax, bx, cx, es, di
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

upString proc
cmp cx, scrLen - marginRight
ja setBlack
je setRUcorner

cmp cx, marginLeft
ja horizontalBorder
je leftUpCorner
jb setBlack

backUp:

mov es:[di], ax
add di, 2d
add cx, 1
cmp cx, scrLen
jb upString
call verticleLoop
endp

setBlack:
mov ax, styleStr[0d]
call backUp

horizontalBorder:
mov ax, styleStr[4h]
call backUp

leftUpCorner:
mov ax, styleStr[8d]
call backUp

chooseString:					; control window's content
cmp bx, scrHigh - marginDown
ja emptyString
je downString

cmp bx, marginTop
ja windowSting
je upString
jb emptyString

emptyString proc
mov ax, styleStr[0d]
mov es:[di], ax
add di, 2d
add cx, 1
cmp cx, scrLen
jb emptyString
call verticleLoop
endp

setRUcorner:
mov ax, styleStr[10d]
call backDown

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; #brief 
; set one string in videosegment as down-border
;
; #input 
; ax - color
; bx - string-index in video segment
; cx - counter
; es - ptr to video segment
; di - index in string (in video segment)
;
; #destroy list
; ax, bx, cx, es, di
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

downString proc
cmp cx, scrLen - marginRight
ja setBlackD
je setRDcorner

cmp cx, marginLeft
ja setHborderD
je setLDcorner
jb setBlackD

backDown:

mov es:[di], ax
add di, 2d
add cx, 1
cmp cx, scrLen
jb downString
call verticleLoop
endp

setHborderD:
mov ax, styleStr[4h]
call backDown

setLDcorner:
mov ax, styleStr[14d]
call backDown

setRDcorner:
mov ax, styleStr[12d]
call backUp

setBlackD:
mov ax, styleStr[0d]
call backDown


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; #brief 
; set one string in videosegment as window-string
;
; #input 
; ax - color
; bx - string-index in video segment
; cx - counter
; es - ptr to video segment
; di - index in string (in video segment)
;
; #destroy list
; ax, bx, cx, es, di
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

windowSting proc
mov ax, styleStr[2d]
cmp cx, scrLen - marginRight
ja setBlackW
je verticalBorder

cmp cx, marginLeft
ja setWindow
je verticalBorder
jb setBlackW

backWindow:

mov es:[di], ax
add di, 2d
add cx, 1
cmp cx, scrLen
jb windowSting
call verticleLoop
endp

verticalBorder:
mov ax, styleStr[6d]
call backWindow

setWindow:
mov ax, styleStr[2d]
call backWindow

setBlackW:
mov ax, styleStr[0d]
call backWindow

.data
styleStr dw 00000h, 01000h, 01fcdh, 01fbah, 01Fc9h, 01fbbh, 01fbch, 01fc8h
; #1 black background
; #2 window background
; #3 horisontal border
; #4 vertical border
; #5 left upper corner
; #6 right upper corner
; #7 right down corner
; #8 left down corner

end start