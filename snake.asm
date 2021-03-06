EGG_LOC		EQU	29H
SNAKE_LEN	EQU	30H
SNAKE_DIR	EQU	31H	;0 1 2 3 / UP R DOWN L
SNAKE_TAIL	EQU	32H
GAME_OVER	EQU	2BH

COLGREEN	EQU	0FFC5H	;DISPLAY INIT
COLRED		EQU	0FFC6H
ROW		EQU	0FFC7H
DATAOUT     	EQU	0FFF0H
DATAIN      	EQU	0FFF1H
DLED	EQU	0FFC1H;7-SEGMENT RIGHT
ALED0	EQU	0FFC2H;7-SEGMENT MIDDLE
ALED1	EQU	0FFC3H;7-SEGMENT LEFT

	ORG	8000H

INIT:
; dot matrix initialization
	MOV	R2, #00H	;GREEN DOT OFF
	MOV	R3, #00H
	CALL	DOTCOLR

; game over, snake length, snake direction initialization
	MOV	R0, #GAME_OVER
	MOV	@R0, #0FH
	MOV	R0, #SNAKE_LEN	;INIT LENGTH -> 3
	MOV	@R0, #3
	MOV	SNAKE_DIR, #0	;INIT DIRECTION -> 1
	MOV	R7, #9FH

; snake position array initialization
	MOV	32H, #43H	;0100/0011B, TAIL
	MOV	33H, #44H	;0100/0100B
	MOV	34H, #45H	;0100/0101B, HEAD

; 7-segment initialization
	MOV	DPTR, #DLED
	MOV	A, #00H
	MOVX	@DPTR, A

	MOV	DPTR, #ALED0
	MOV	A, #00H
	MOVX	@DPTR, A

	MOV	DPTR, #ALED1
	MOV	A, #00H
	MOVX	@DPTR, A

; timer initialization
	MOV	TMOD, #02H	;TIMER SET, MODE 02
	MOV	TH0, #00H	;INITIAL VALUE
	MOV	TL0, #00H
	SETB	TCON.TR0	;START

	CALL	SET_EGG
	CALL	PRELOOP

LOOP:
; check game over
	MOV	A, GAME_OVER
	JZ	INIT
; check keypad and store direction
	CALL	SAMPLEKEY
; display snake and egg on dot matrix
	CALL	DISPLAY
	MOV	A, R7
	JZ	PRELOOP
	DJNZ	R7, LOOP
PRELOOP:
	MOV	R7, #9FH
	CALL	updateSnake
	JMP	LOOP
;---DISPLAY-----------------------------------
DISPLAY:
	MOV 	R0, #SNAKE_TAIL	;SNAKE DISP
	MOV	R4, SNAKE_LEN
	CLR	C

DISP:	MOV 	R2, #00000001B
	MOV	R3, #00000001B

	MOV	A, @R0
	ANL 	A, #11110000B
	SWAP	A
	JZ	DISP_L2
DISP_L1:
	MOV	B, A		;B->TEMP
	MOV	A, R2
	RL	A
	MOV	R2, A
	MOV	A, B
	DJNZ	A, DISP_L1
DISP_L2:
	MOV	A, @R0
	ANL	A, #00001111B
	JZ	DISP_L4
DISP_L3:
	MOV	B, A		;B->TEMP
	MOV	A, R3
	RL	A
	MOV	R3, A
	MOV	A, B
	DJNZ	A, DISP_L3
DISP_L4:
	INC	R0
	CALL 	DOTCOLG
	CALL	DELAY		
	DJNZ	R4, DISP
	
	MOV 	R2, #00000000B
	MOV	R3, #00000000B
	CALL	DOTCOLG

	;EGG DISPLAY START
	MOV 	R2, #00000001B
	MOV	R3, #00000001B
	MOV	R0, #EGG_LOC
	CLR	C

	MOV 	A, @R0
	ANL 	A, #11110000B
	SWAP	A
	JZ	DISP_EGG2
DISP_EGG1:
	MOV	B, A		;B->TEMP
	MOV	A, R2
	RL	A
	MOV	R2, A
	MOV	A, B
	DJNZ	A, DISP_EGG1
DISP_EGG2:
	MOV	A, @R0
	ANL	A, #00001111B
	JZ	DISP_EGG4
DISP_EGG3:
	MOV	B, A		;B->TEMP
	MOV	A, R3
	RL	A
	MOV	R3, A
	MOV	A, B
	DJNZ	A, DISP_EGG3
DISP_EGG4:
	CALL	DOTCOLR
	CALL	DELAY		

	MOV 	R2, #00000000B
	MOV	R3, #00000000B
	CALL	DOTCOLR
	RET
	
;---SET_EGG-----------------------------------
;??? ???????????? egg??? ????????? ??????, ????????? ????????? ????????? ?????? set
SET_EGG:
	MOV	A, TL0
	ANL	A, #01110111B
SET_EGG1:
	JNZ	SET_EGG2
	JMP	SET_EGG
SET_EGG2:
	CJNE	A, #01110111B, SET_EGG3
	JMP	SET_EGG
SET_EGG3:
	CJNE	A, #01110000B, SET_EGG4
	JMP	SET_EGG
SET_EGG4:
	CJNE	A, #00000111B, SET_EGG5
	JMP	SET_EGG
SET_EGG5:
	MOV	EGG_LOC, A				
	RET

TIME_SET:
	CLR	TF0
	SETB	TCON.TR0
	RETI
	
;--------------------------------------
DOTCOLR:			;RED, EGG
	MOV	DPTR, #COLRED
	MOV	A, R3
	MOVX	@DPTR, A
	
	MOV	DPTR, #ROW
	MOV	A, R2
	MOVX	@DPTR, A
	RET

DOTCOLG:			;GREEN, SNAKE
	MOV	DPTR, #COLGREEN
	MOV	A, R3
	MOVX	@DPTR, A
	
	MOV	DPTR, #ROW
	MOV	A, R2
	MOVX	@DPTR, A
	RET

DELAY: 	MOV 	R3,#02H		;1mS delay FOR TEST
DELAY1: MOV 	R2,#0FAH
DELAY2: DJNZ 	R2,DELAY2
      	DJNZ 	R3,DELAY1
RET

; update elemente of snake array except the head. each element has the position of dot matrix
updateSnake:
	MOV     R1, #SNAKE_TAIL
arrayLoop:
	MOV     A, R1
	ADD     A, #01H
	MOV     R0, A		;CURRENT ADDR IS ON R1, NEXT ADDR IS ON R2

	MOV     A, @R0
	MOV     @R1, A
	INC     R1

	MOV	R0, #SNAKE_TAIL
	MOV	A, R0
	ADD	A, SNAKE_LEN
	MOV	R0, A
	DEC	R0		;??? ?????? ????????? ????????? ????????????

	MOV	A, R1
	SUBB	A, R0
	JNZ	arrayLoop

; update the position of head
UP:
	MOV	A, SNAKE_DIR
	CJNE    A, #00H, RIGHT
	MOV	A, @R0
	SUBB	A, #10H; UP
	MOV     @R0, A
	JC     	BUMP;??????

; check ate Egg
	MOV	A, EGG_LOC
	SUBB	A, @R0
	JNZ	COMPLETE

; increase snake length and update new head
	CALL	INCHEAD
	JMP	UP
RIGHT:
	MOV	A, SNAKE_DIR
	CJNE    A, #01H, DOWN
	MOV	A, @R0
    	ADD     A, #01H
    	MOV     @R0, A
    	ANL     A, #08H
    	JNZ     BUMP;??????

; check ate Egg
	MOV	A, EGG_LOC
	SUBB	A, @R0
	JNZ	COMPLETE

; increase snake length and update new head
	CALL	INCHEAD
	JMP	RIGHT
DOWN:
	MOV	A, SNAKE_DIR
	CJNE    A, #02H, LEFT
	MOV	A, @R0
    	ADD    	A, #10H
    	MOV     @R0, A
	ANL	A, #80H
    	JNZ	BUMP; ??????

; check ate Egg
	MOV	A, EGG_LOC
	SUBB	A, @R0
	JNZ	COMPLETE

; increase snake length and update new head
	CALL	INCHEAD
	JMP	DOWN
LEFT:
	MOV	A, @R0
	SWAP	A
    	SUBB    A, #10H
	SWAP	A
    	MOV     @R0, A
    	JC	BUMP; ??????

; check ate Egg
	MOV	A, EGG_LOC
	SUBB	A, @R0
	JNZ	COMPLETE

; increase snake length and update new head
	CALL	INCHEAD
	JMP	LEFT
COMPLETE:
    	RET
BUMP:
    	MOV     GAME_OVER, #00H
    	JMP     COMPLETE

INCHEAD:
; set random location of egg
	CALL	SET_EGG
; increase the length of snake
	MOV	A, SNAKE_LEN
	INC	A
	MOV	SNAKE_LEN, A
; update score on 7 segment
	CALL	DISPLAY_SEG

; update new head
	MOV	A, @R0
	INC	R0
	MOV	@R0, A
	RET

; check keypad and update direction
SAMPLEKEY:
	CALL	KEYINITIAL
	MOV	SNAKE_DIR, A
	RET

KEYINITIAL:
	MOV	R1, #00H
	MOV	A, #11101111B
	SETB	C

COLSCAN:
	MOV	R0, A
	INC	R1
	CALL	SUBKEY
	
	CJNE	A, #0FFH, RSCAN
	MOV	A, R0
	SETB	C
	RRC	A
	JNC	NO_INPUT
	JMP	COLSCAN

NO_INPUT:
	MOV	R0, #SNAKE_DIR
	MOV	A, @R0
	RET

RSCAN:	
	MOV	R2, #00H
ROWSCAN:
	RRC	A
	JNC	MATRIX
	INC	R2
	JMP	ROWSCAN

MATRIX:
   	MOV	A, R2
	MOV	B, #05H
	MUL	AB
	ADD	A, R1
keyUP:	
	CJNE	A, #11H, keyLEFT
	MOV	A, #00H
	JMP	KEYEND
keyLEFT:
	CJNE	A, #15H, keyDOWN
	MOV	A, #03H
	JMP	KEYEND
keyDOWN:
	CJNE	A, #16H, keyRIGHT
	MOV	A, #02H
	JMP	KEYEND
keyRIGHT:
	CJNE	A, #17H, WRONG
	MOV	A, #01H
	JMP	KEYEND
WRONG:	MOV	R0, #SNAKE_DIR
	MOV	A, @R0
KEYEND:	RET


SUBKEY:
    	MOV	DPTR, #DATAOUT
	MOVX	@DPTR, A
	MOV	DPTR, #DATAIN
	MOVX	A, @DPTR
	RET

; update score on 7-segment
; dot matrix ??? ????????? 64??? ????????? 99?????? ?????? ??? ??????, ????????? DLED??? ????????????
DISPLAY_SEG:
	MOV	A, SNAKE_LEN
	SUBB	A, #03H
; BCD
	MOV	B, #10
	DIV	AB
	SWAP	A
	ORL	A, B

	MOV	DPTR, #DLED
	MOVX	@DPTR, A
	RET

	ORG	9F0BH		;TIMER INTERRUPT
	JMP	TIME_SET
END