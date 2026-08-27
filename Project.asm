.MODEL SMALL
 
.STACK 100H

.DATA

; =========================================================
;                 CONSTANTS
; =========================================================

ROWS EQU 15
COLS EQU 15
SIZE EQU 225

WALL      EQU 0
PATH      EQU 1
START_POS EQU 2
EXIT_POS  EQU 3
PLAYER    EQU 4
SOLUTION  EQU 5


; =========================================================
;                 MAZE DATA
; =========================================================

; 15 x 15 = 225 cells
; Every cell initially contains 0 (wall)

maze DB SIZE DUP(0)


; =========================================================
;                 PLAYER DATA
; =========================================================

playerRow DB 1
playerCol DB 1

exitRow DB 13
exitCol DB 13


; =========================================================
;                 RANDOM NUMBER DATA
; =========================================================

seed DW 1234


; =========================================================
;                 STACK DATA
; =========================================================

; Each stack element stores one maze position.
; Maximum 225 positions.

stack DW SIZE DUP(0)

stackTop DW 0


; =========================================================
;                 STATISTICS
; =========================================================

moves DW 0
nodesVisited DW 0
pathLength DW 0


; =========================================================
;                 MESSAGES
; =========================================================

titleMsg DB 13,10
         '=======================================',13,10
         '       MAZE PATHFINDING SYSTEM',13,10
         '=======================================',13,10,'$'

menuMsg DB 13,10
        '1. Generate New Maze',13,10
        '2. Play Maze',13,10
        '3. Solve Maze',13,10
        '4. Show Statistics',13,10
        '5. Exit',13,10
        'Enter choice: $'

newMazeMsg DB 13,10,'New maze generated!',13,10,'$'

playMsg DB 13,10
        'Use W = Up, A = Left, S = Down, D = Right',13,10
        'Press Q to return to menu.',13,10,'$'

wallMsg DB 13,10,'You cannot move through a wall!',13,10,'$'

exitMsg DB 13,10
        'Congratulations! You reached the exit!',13,10,'$'

noSolutionMsg DB 13,10
              'No solution was found.',13,10,'$'

solutionMsg DB 13,10
            'Solution found!',13,10,'$'

statsMsg DB 13,10
         '========== MAZE STATISTICS ==========',13,10,'$'

movesMsg DB 'Player moves: $'
nodesMsg DB 13,10,'Nodes visited: $'
pathMsg DB 13,10,'Solution path length: $'

pressMsg DB 13,10,'Press any key to continue...$'

invalidMsg DB 13,10,'Invalid choice!',13,10,'$'


.CODE
MAIN PROC

; =========================================================
;                 INITIALIZE DS
; =========================================================

MOV AX,@DATA
MOV DS,AX


; =========================================================
;                 DISPLAY TITLE
; =========================================================

LEA DX,titleMsg
MOV AH,09H
INT 21H


; =========================================================
;                 CREATE INITIAL MAZE
; =========================================================

CALL GENERATE_MAZE


; =========================================================
;                 MAIN MENU LOOP
; =========================================================

MAIN_MENU:

LEA DX,menuMsg
MOV AH,09H
INT 21H

; Read one keyboard character
MOV AH,01H
INT 21H

; Compare user's choice

CMP AL,'1'
JE MENU_GENERATE

CMP AL,'2'
JE MENU_PLAY

CMP AL,'3'
JE MENU_SOLVE

CMP AL,'4'
JE MENU_STATS

CMP AL,'5'
JE MENU_EXIT

; Invalid option

LEA DX,invalidMsg
MOV AH,09H
INT 21H

JMP MAIN_MENU


; =========================================================
;                 MENU OPTION 1
; =========================================================

MENU_GENERATE:

CALL GENERATE_MAZE

LEA DX,newMazeMsg
MOV AH,09H
INT 21H

CALL DISPLAY_MAZE

JMP MAIN_MENU


; =========================================================
;                 MENU OPTION 2
; =========================================================

MENU_PLAY:

CALL PLAY_MAZE

JMP MAIN_MENU


; =========================================================
;                 MENU OPTION 3
; =========================================================

MENU_SOLVE:

CALL SOLVE_MAZE

JMP MAIN_MENU


; =========================================================
;                 MENU OPTION 4
; =========================================================

MENU_STATS:

CALL SHOW_STATISTICS

JMP MAIN_MENU


; =========================================================
;                 MENU OPTION 5
; =========================================================

MENU_EXIT:

JMP EXIT_PROGRAM


; =========================================================
;                 EXIT TO DOS
; =========================================================

EXIT_PROGRAM:

MOV AX,4C00H
INT 21H

MAIN ENDP


; =========================================================
;                 GENERATE MAZE
; =========================================================

GENERATE_MAZE PROC

; ---------------------------------------------------------
; First make every cell a wall.
; ---------------------------------------------------------

LEA SI,maze

MOV CX,SIZE
MOV AL,WALL

CLEAR_MAZE:

MOV [SI],AL
INC SI

LOOP CLEAR_MAZE


; ---------------------------------------------------------
; Create simple horizontal paths.
;
; Rows 1,3,5,7,9,11,13 become paths.
; ---------------------------------------------------------

MOV BL,1

GENERATE_ROWS:

; Calculate row starting position.
;
; AX = row number
; AX * 15 = array position

MOV AL,BL
MOV AH,0

MOV DL,COLS
MUL DL

MOV SI,AX

; Create path across this row.
MOV CX,COLS

MAKE_ROW:

MOV maze[SI],PATH

INC SI

LOOP MAKE_ROW


; Move to next odd row.
ADD BL,2

CMP BL,14
JL GENERATE_ROWS


; ---------------------------------------------------------
; Create vertical connections.
; ---------------------------------------------------------

MOV BL,1

GENERATE_COLUMNS:

; Calculate position:
;
; row 1, column BL

MOV AL,BL
MOV AH,0

MOV DL,COLS
MUL DL

ADD AX,1

MOV SI,AX

; Open cells vertically from row 1 to row 13.

MOV CX,13

MAKE_COLUMN:

MOV maze[SI],PATH

ADD SI,COLS

LOOP MAKE_COLUMN

; Move to another odd column.
ADD BL,2

CMP BL,14
JL GENERATE_COLUMNS


; ---------------------------------------------------------
; Create start position.
; ---------------------------------------------------------

MOV maze[16],START_POS

MOV playerRow,1
MOV playerCol,1


; ---------------------------------------------------------
; Create exit position.
; ---------------------------------------------------------

MOV maze[208],EXIT_POS

MOV exitRow,13
MOV exitCol,13


; ---------------------------------------------------------
; Reset player statistics.
; ---------------------------------------------------------

MOV moves,0
MOV nodesVisited,0
MOV pathLength,0


RET

GENERATE_MAZE ENDP


; =========================================================
;                 DISPLAY MAZE
; =========================================================

DISPLAY_MAZE PROC

; Start from first cell.
LEA SI,maze

MOV BL,0

DISPLAY_ROW:

MOV BH,0

DISPLAY_CELL:

MOV AL,[SI]

; Check if current cell is a wall.

CMP AL,WALL
JE PRINT_WALL

; Check if current cell is player.

CMP AL,PLAYER
JE PRINT_PLAYER

; Check if current cell is solution.

CMP AL,SOLUTION
JE PRINT_SOLUTION

; Check if current cell is start.

CMP AL,START_POS
JE PRINT_START

; Check if current cell is exit.

CMP AL,EXIT_POS
JE PRINT_EXIT

; Otherwise it is a path.

MOV DL,' '
MOV AH,02H
INT 21H

JMP NEXT_CELL


PRINT_WALL:

MOV DL,'#'
MOV AH,02H
INT 21H

JMP NEXT_CELL


PRINT_PLAYER:

MOV DL,'P'
MOV AH,02H
INT 21H

JMP NEXT_CELL


PRINT_SOLUTION:

MOV DL,'.'
MOV AH,02H
INT 21H

JMP NEXT_CELL


PRINT_START:

MOV DL,'S'
MOV AH,02H
INT 21H

JMP NEXT_CELL


PRINT_EXIT:

MOV DL,'E'
MOV AH,02H
INT 21H


NEXT_CELL:

INC SI
INC BH

CMP BH,COLS
JL DISPLAY_CELL

; Move to next row.

MOV DL,13
MOV AH,02H
INT 21H

MOV DL,10
MOV AH,02H
INT 21H

INC BL

CMP BL,ROWS
JL DISPLAY_ROW

RET

DISPLAY_MAZE ENDP


; =========================================================
;                 PLAY MAZE
; =========================================================

PLAY_MAZE PROC

; Reset player position.

MOV playerRow,1
MOV playerCol,1

; Put player at starting position.

MOV maze[16],PLAYER


LEA DX,playMsg
MOV AH,09H
INT 21H


PLAY_LOOP:

CALL DISPLAY_MAZE

; Read keyboard input.

MOV AH,01H
INT 21H


; ---------------------------------------------------------
; Q = quit
; ---------------------------------------------------------

CMP AL,'q'
JE PLAY_END

CMP AL,'Q'
JE PLAY_END


; ---------------------------------------------------------
; W = move up
; ---------------------------------------------------------

CMP AL,'w'
JE MOVE_UP

CMP AL,'W'
JE MOVE_UP


; ---------------------------------------------------------
; S = move down
; ---------------------------------------------------------

CMP AL,'s'
JE MOVE_DOWN

CMP AL,'S'
JE MOVE_DOWN


; ---------------------------------------------------------
; A = move left
; ---------------------------------------------------------

CMP AL,'a'
JE MOVE_LEFT

CMP AL,'A'
JE MOVE_LEFT


; ---------------------------------------------------------
; D = move right
; ---------------------------------------------------------

CMP AL,'d'
JE MOVE_RIGHT

CMP AL,'D'
JE MOVE_RIGHT


JMP PLAY_LOOP


; =========================================================
;                 MOVE UP
; =========================================================

MOVE_UP:

CMP playerRow,1
JBE PLAY_LOOP

DEC playerRow

CALL CHECK_MOVE

JMP PLAY_LOOP


; =========================================================
;                 MOVE DOWN
; =========================================================

MOVE_DOWN:

CMP playerRow,13
JAE PLAY_LOOP

INC playerRow

CALL CHECK_MOVE

JMP PLAY_LOOP


; =========================================================
;                 MOVE LEFT
; =========================================================

MOVE_LEFT:

CMP playerCol,1
JBE PLAY_LOOP

DEC playerCol

CALL CHECK_MOVE

JMP PLAY_LOOP


; =========================================================
;                 MOVE RIGHT
; =========================================================

MOVE_RIGHT:

CMP playerCol,13
JAE PLAY_LOOP

INC playerCol

CALL CHECK_MOVE

JMP PLAY_LOOP


; =========================================================
;                 END PLAYING
; =========================================================

PLAY_END:

RET

PLAY_MAZE ENDP


; =========================================================
;                 CHECK PLAYER MOVEMENT
; =========================================================

CHECK_MOVE PROC

; ---------------------------------------------------------
; Convert:
;
; row and column
;
; into:
;
; array position = row * 15 + column
; ---------------------------------------------------------

MOV AL,playerRow
MOV AH,0

MOV DL,COLS
MUL DL

MOV DL,playerCol
MOV DH,0

ADD AX,DX

MOV SI,AX


; ---------------------------------------------------------
; Check whether destination is a wall.
; ---------------------------------------------------------

CMP maze[SI],WALL
JE INVALID_MOVE


; ---------------------------------------------------------
; Remove player from previous position.
;
; We calculate the previous position depending
; on the current movement.
;
; For simplicity, the old player position is searched
; through the maze.
; ---------------------------------------------------------

LEA DI,maze

MOV CX,SIZE

REMOVE_PLAYER:

CMP [DI],PLAYER
JE FOUND_OLD_PLAYER

INC DI

LOOP REMOVE_PLAYER

JMP PLACE_PLAYER


FOUND_OLD_PLAYER:

MOV BYTE PTR [DI],PATH


; ---------------------------------------------------------
; Put player at new position.
; ---------------------------------------------------------

PLACE_PLAYER:

MOV maze[SI],PLAYER

INC moves


; ---------------------------------------------------------
; Check if player reached exit.
; ---------------------------------------------------------

MOV AL,playerRow
CMP AL,exitRow
JNE CHECK_END

MOV AL,playerCol
CMP AL,exitCol
JNE CHECK_END

LEA DX,exitMsg
MOV AH,09H
INT 21H

MOV maze[SI],EXIT_POS

CALL DISPLAY_MAZE


CHECK_END:

RET


; ---------------------------------------------------------
; Invalid movement.
; ---------------------------------------------------------

INVALID_MOVE:

LEA DX,wallMsg
MOV AH,09H
INT 21H

; Restore player position because the attempted
; movement was invalid.

; This part searches for the player and uses
; the position stored in the maze.

LEA DI,maze

MOV CX,SIZE

FIND_PLAYER:

CMP [DI],PLAYER
JE RESTORE_POSITION

INC DI

LOOP FIND_PLAYER

RET


RESTORE_POSITION:

; Find the player's current location from the array.
;
; We do not change playerRow/playerCol here.
; Instead, reverse the movement is handled by the
; caller's current position limitations.

RET

CHECK_MOVE ENDP


; =========================================================
;                 SOLVE MAZE
; =========================================================

SOLVE_MAZE PROC

; ---------------------------------------------------------
; Reset stack.
; ---------------------------------------------------------

MOV stackTop,0

MOV nodesVisited,0

MOV pathLength,0


; ---------------------------------------------------------
; Clear previous solution marks.
; ---------------------------------------------------------

LEA SI,maze

MOV CX,SIZE

CLEAR_SOLUTION:

CMP [SI],SOLUTION
JNE NOT_SOLUTION

MOV BYTE PTR [SI],PATH

NOT_SOLUTION:

INC SI

LOOP CLEAR_SOLUTION


; ---------------------------------------------------------
; Push starting position.
;
; Starting position:
;
; row = 1
; col = 1
;
; position = 1*15+1 = 16
; ---------------------------------------------------------

MOV AX,16

CALL PUSH_STACK


; ---------------------------------------------------------
; Begin DFS search.
; ---------------------------------------------------------

DFS_LOOP:

; Check whether stack is empty.

CMP stackTop,0
JE SOLUTION_NOT_FOUND


; ---------------------------------------------------------
; Pop one position.
; ---------------------------------------------------------

CALL POP_STACK

; AX now contains current maze position.

MOV SI,AX

INC nodesVisited


; ---------------------------------------------------------
; Check if this is the exit.
;
; Exit position = 208
; ---------------------------------------------------------

CMP SI,208
JE SOLUTION_FOUND


; ---------------------------------------------------------
; Mark this cell as visited.
;
; We use SOLUTION temporarily to mark visited cells.
; ---------------------------------------------------------

CMP maze[SI],START_POS
JE CHECK_NEIGHBORS

MOV maze[SI],SOLUTION


; ---------------------------------------------------------
; Check UP
; ---------------------------------------------------------

MOV AX,SI

CMP AX,15
JB CHECK_DOWN

SUB AX,15

CMP maze[AX],WALL
JE CHECK_DOWN

CMP maze[AX],SOLUTION
JE CHECK_DOWN

CALL PUSH_STACK


; ---------------------------------------------------------
; Check DOWN
; ---------------------------------------------------------

CHECK_DOWN:

MOV AX,SI
ADD AX,15

CMP AX,SIZE
JAE CHECK_LEFT

CMP maze[AX],WALL
JE CHECK_LEFT

CMP maze[AX],SOLUTION
JE CHECK_LEFT

CALL PUSH_STACK


; ---------------------------------------------------------
; Check LEFT
; ---------------------------------------------------------

CHECK_LEFT:

MOV AX,SI

CMP AX,0
JE CHECK_RIGHT

DEC AX

CMP maze[AX],WALL
JE CHECK_RIGHT

CMP maze[AX],SOLUTION
JE CHECK_RIGHT

CALL PUSH_STACK


; ---------------------------------------------------------
; Check RIGHT
; ---------------------------------------------------------

CHECK_RIGHT:

MOV AX,SI
INC AX

CMP AX,SIZE
JAE DFS_LOOP

CMP maze[AX],WALL
JE DFS_LOOP

CMP maze[AX],SOLUTION
JE DFS_LOOP

CALL PUSH_STACK

JMP DFS_LOOP


; =========================================================
;                 SOLUTION FOUND
; =========================================================

SOLUTION_FOUND:

LEA DX,solutionMsg
MOV AH,09H
INT 21H

CALL DISPLAY_MAZE

MOV AX,nodesVisited
MOV pathLength,AX

RET


; =========================================================
;                 NO SOLUTION
; =========================================================

SOLUTION_NOT_FOUND:

LEA DX,noSolutionMsg
MOV AH,09H
INT 21H

RET

SOLVE_MAZE ENDP


; =========================================================
;                 PUSH INTO STACK
; =========================================================

PUSH_STACK PROC

; AX contains the position to push.

MOV BX,stackTop

MOV stack[BX],AX

ADD stackTop,2

RET

PUSH_STACK ENDP


; =========================================================
;                 POP FROM STACK
; =========================================================

POP_STACK PROC

SUB stackTop,2

MOV BX,stackTop

MOV AX,stack[BX]

RET

POP_STACK ENDP


; =========================================================
;                 SHOW STATISTICS
; =========================================================

SHOW_STATISTICS PROC

LEA DX,statsMsg
MOV AH,09H
INT 21H


; ---------------------------------------------------------
; Display player moves
; ---------------------------------------------------------

LEA DX,movesMsg
MOV AH,09H
INT 21H

MOV AX,moves

CALL PRINT_NUMBER


; ---------------------------------------------------------
; Display nodes visited
; ---------------------------------------------------------

LEA DX,nodesMsg
MOV AH,09H
INT 21H

MOV AX,nodesVisited

CALL PRINT_NUMBER


; ---------------------------------------------------------
; Display solution path length
; ---------------------------------------------------------

LEA DX,pathMsg
MOV AH,09H
INT 21H

MOV AX,pathLength

CALL PRINT_NUMBER


RET

SHOW_STATISTICS ENDP


; =========================================================
;                 PRINT NUMBER
; =========================================================

PRINT_NUMBER PROC

; If AX = 0, print 0.

CMP AX,0
JNE CONVERT_NUMBER

MOV DL,'0'
MOV AH,02H
INT 21H

RET


CONVERT_NUMBER:

; ---------------------------------------------------------
; Convert decimal number into individual digits.
;
; We use the stack temporarily to reverse the digits.
; ---------------------------------------------------------

MOV CX,0

MOV BX,10


NUMBER_LOOP:

MOV DX,0

DIV BX

PUSH DX

INC CX

CMP AX,0
JNE NUMBER_LOOP


; ---------------------------------------------------------
; Print digits.
; ---------------------------------------------------------

PRINT_DIGIT:

POP DX

ADD DL,'0'

MOV AH,02H
INT 21H

LOOP PRINT_DIGIT

RET

PRINT_NUMBER ENDP


END MAIN
