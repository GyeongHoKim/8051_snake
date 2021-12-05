;keypad

;up이 17번째, left가 21번째, down이 22번째, right가 23번째 index값임

FINDKEYCODE:
	PUSH	REG_0
    PUSH    REG_1
    PUSH    REG_2

INITIAL:
	MOV	    R1, #00H
	MOV	    A, #11101111B
	SETB	C

COLSCAN:
	MOV	    R0, A
	INC	    R1
	CALL	SUBKEY
	
	CJNE	A, #0FFH, RSCAN
	MOV	    A, R0
	SETB	C
	RRC	    A
	JNC	    INITIAL
	JMP	    COLSCAN

RSCAN:	
    MOV	R2, #00H
ROWSCAN:
	RRC	A
	JNC	MATRIX
	INC	R2
	JMP	ROWSCAN

MATRIX:
    MOV	    A, R2
	MOV	    B, #05H
	MUL	    AB
	ADD	    A, R1
	POP	    REG_0
	POP	    REG_1
	POP	    REG_2
	RET

SUBKEY:
    MOV	    DPTR, #DATAOUT
	MOVX	@DPTR, A
	MOV	    DPTR, #DATAIN
	MOVX	A, @DPTR
	RET

RWKEY	EQU	10H
COMMA	EQU	11H
PERIOD	EQU	12H
GO	EQU	13H
REG	EQU	14H
CD	EQU	15H
INCR	EQU	16H
ST	EQU	17H
RST	EQU	18H

INDEX:
    MOVC	A,@A+PC
	RET

KEYBASE:
	DB ST
	DB INCR
	DB CD
	DB REG
	DB GO
	DB 0CH
	DB 0DH
	DB 0EH
	DB 0FH
	DB COMMA
	DB 08H
	DB 09H
	DB 0AH
	DB 0BH
	DB PERIOD
	DB 04H
	DB 05H
	DB 06H
	DB 07H
	DB RWKEY
	DB 00H
	DB 01H
	DB 02H
	DB 03H
	END