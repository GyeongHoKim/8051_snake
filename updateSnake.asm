SNAKE_LEN	EQU	30H
SNAKE_DIR	EQU	31H	;0 1 2 3 / UP R DOWN L
SNAKE_TAIL	EQU	32H
GAME_OVER   EQU 2BH; GAME OVER IF ZERO

updateSnake:
    PUSH    PSW
    SETB    PSW.3
    CLR     PSW.4

    MOV     R0, #SNAKE_TAIL
    ADD     R0, SNAKE_LEN
    DEC     R0; 이 안에 머리의 주소가 담겨있음

    MOV     R1, #SNAKE_TAIL
arrayLoop:
    MOV     A, R1
    ADD     A, #01H
    MOV     R2, A; CURRENT ADDR IS ON R1, NEXT ADDR IS ON R2
    
    MOV     A, @R2
    MOV     @R1, A
    INC     R1
    CJNE    R1, R0, arrayLoop

    MOV     A, @R0
UP: 
    CJNE    SNAKE_DIR, #00H, RIGHT
    ADD     A, #10H; UP
    MOV     @R0, A
    ANL     A, #80H
    JNZ     BUMP;벽쿵
    CALL    ateItself
    JMP     COMPLETE
RIGHT:
    CJNE    SNAKE_DIR, #01H, DOWN
    ADD     A, #01H
    MOV     @R0, A
    ANL     A, #08H
    JNZ     BUMP;벽쿵
    CALL    ateItself
    JMP     COMPLETE
DOWN:
    CJNE    SNAKE_DIR, #02H, LEFT
    SUBB    A, #10H
    MOV     @R0, A
    JC      BUMP; 벽쿵
    CALL    ateItself
    JMP     COMPLETE
LEFT:
    CJNE    SNAKE_DIR, #03H, NAN
    SUBB    A, #01H
    MOV     @R0, A
    JC      BUMP; 벽쿵
    CALL    ateItself
    JMP     COMPLETE
COMPLETE:
    POP     PSW
    RET
BUMP:
    MOV     GAME_OVER, #00H
    JMP     COMPLETE
ateItself:
    MOV     A, @R0
    MOV     R3, A
    MOV     R1, #SNAKE_TAIL
ateCheckLoop:
    MOV     A, @R1
    SUBB    A, R3
    JNZ     BUMP; ATE ITSELF
    CJNE    R1, R0, ateCheckLoop
    RET





