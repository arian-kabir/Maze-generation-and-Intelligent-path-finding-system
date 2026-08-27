# Procedural Maze Generation and Intelligent Pathfinding System

## Project Overview

The **Procedural Maze Generation and Intelligent Pathfinding System** is a software-based project developed using **8086 Assembly Language** and **Emu8086**.

The project generates a maze structure in memory, displays it using ASCII characters, allows a user to navigate through the maze using the keyboard, and provides an automatic maze-solving mechanism using a stack-based **Depth-First Search (DFS)** approach.

The project demonstrates fundamental assembly language concepts including arrays, stacks, procedures, loops, conditional branching, arithmetic operations, keyboard input, and memory manipulation.

---

## Objectives

The main objectives of this project are:

* To implement a maze using a one-dimensional array.
* To generate a maze using basic 8086 assembly instructions.
* To allow interactive player movement through the maze.
* To prevent the player from moving through walls or outside the maze.
* To implement a stack-based maze-solving algorithm.
* To demonstrate Depth-First Search (DFS) in 8086 Assembly.
* To display the discovered solution path.
* To collect basic statistics about the maze and solving process.

---

## Features

### 1. Procedural Maze Generation

The system creates a maze dynamically in memory instead of relying entirely on a predefined maze. The maze is represented using an array where each element represents a cell.

Different values are used to represent:

* Wall
* Path
* Starting position
* Exit
* Player
* Solution path

### 2. Random Maze Generation

The system can generate different maze layouts using a basic pseudo-random generation approach. The generated structure contains paths connecting the starting point to different sections of the maze.

### 3. Interactive Maze Navigation

The user can control the player inside the maze using keyboard commands.

| Key | Action     |
| --- | ---------- |
| W   | Move Up    |
| A   | Move Left  |
| S   | Move Down  |
| D   | Move Right |
| Q   | Exit Maze  |

The player's position is continuously updated in the maze array.

### 4. Wall and Boundary Collision Detection

Before a movement is performed, the system checks whether the destination cell contains a wall or whether the movement would take the player outside the maze.

Invalid movements are rejected.

### 5. Automatic Maze Solving Using DFS

The system can automatically search for a route from the starting point to the exit using **Depth-First Search (DFS)**.

A stack is used to store maze positions that still need to be explored.

The algorithm checks neighboring cells and continues exploring until it reaches the exit or determines that no route is available.

### 6. Solution Path Visualization

After the maze has been solved, the discovered path can be displayed directly on the maze using a special character.

Example:

```text
#S#...#     #
# #.# ##### #
# #.#       #
# #.#########
# ...       E
```

Here, `.` represents cells belonging to the solution path.

### 7. Maze Performance Analysis

The system keeps track of basic information about the maze-solving process, including:

* Number of player movements
* Number of nodes/cells visited by the solver
* Solution path information
* Whether a solution was found

---

## Maze Representation

The maze uses a one-dimensional array:

```asm
maze DB SIZE DUP(0)
```

For a 15 × 15 maze:

```text
15 × 15 = 225 cells
```

Therefore, the array contains 225 elements.

Each cell contains a numerical value representing its type.

| Value | Meaning           |
| ----: | ----------------- |
|     0 | Wall              |
|     1 | Path              |
|     2 | Starting Position |
|     3 | Exit              |
|     4 | Player            |
|     5 | Solution          |

Although the maze is stored as a one-dimensional array, it is treated as a two-dimensional grid.

The position of a cell is calculated using:

```text
Position = Row × Number of Columns + Column
```

For a 15-column maze:

```text
Position = Row × 15 + Column
```

---

## Maze Example

The maze is displayed using ASCII characters.

```text
#################
#S#       #     #
# # ##### # ### #
# #     # #     #
# ##### # ##### #
#       #       #
####### ##### ###
#       #       #
# ##### # ##### #
#     # #       #
##### # ####### #
#     #         #
# ### ######### #
#             E #
#################
```

The symbols represent:

```text
# = Wall
  = Open Path
S = Starting Position
E = Exit
P = Player
. = Solution Path
```

---

## Maze Solving Algorithm

The automatic solver uses **Depth-First Search (DFS)**.

The basic process is:

```text
1. Place the starting position into the stack.
2. Take a position from the top of the stack.
3. Check whether it is the exit.
4. If it is not the exit, examine neighboring cells.
5. Add valid unexplored cells to the stack.
6. Continue until the exit is found.
7. If the stack becomes empty, no solution exists.
```

The project implements its own stack:

```asm
stack DW SIZE DUP(0)
```

The current top of the stack is tracked using:

```asm
stackTop DW 0
```

Two procedures are used to manage it:

```asm
PUSH_STACK
POP_STACK
```

This demonstrates the use of a **Stack data structure** as required by the project specifications.

---

## Main Procedures

The program is divided into multiple procedures to keep the code organized.

### `GENERATE_MAZE`

Initializes the maze and creates the paths, starting position, and exit.

### `DISPLAY_MAZE`

Reads the maze array and displays each cell using the appropriate ASCII character.

### `PLAY_MAZE`

Handles keyboard input and allows the user to move through the maze.

### `CHECK_MOVE`

Checks whether the player's requested movement is valid.

### `SOLVE_MAZE`

Uses DFS to automatically search for the exit.

### `PUSH_STACK`

Adds a maze position to the DFS stack.

### `POP_STACK`

Removes the most recently added maze position from the stack.

### `SHOW_STATISTICS`

Displays information collected during the player's session and maze-solving process.

### `PRINT_NUMBER`

Converts a numerical value into decimal ASCII digits so it can be displayed on the screen.

---

## Main Menu

When the program starts, the user is presented with the following menu:

```text
=======================================
       MAZE PATHFINDING SYSTEM
=======================================

1. Generate New Maze
2. Play Maze
3. Solve Maze
4. Show Statistics
5. Exit

Enter choice:
```

The user selects an option by entering a number from `1` to `5`.

---

## Technologies Used

* **Programming Language:** 8086 Assembly Language
* **Development Environment:** Emu8086
* **Assembler:** MASM-compatible assembler
* **Operating Environment:** DOS-compatible 8086 environment

---

## Assembly Concepts Used

The project demonstrates the following concepts:

* Data segments
* Code segments
* Registers
* Memory addressing
* Arrays
* Stack implementation
* Procedures
* Loops
* Conditional jumps
* Arithmetic operations
* Keyboard input
* Character output
* String output
* ASCII values
* Array indexing
* Searching algorithms
* Depth-First Search
* Coordinate-to-array conversion

---

## Project Structure

The project can be maintained as a single Emu8086 assembly source file:

```text
MazeProject/
│
├── maze.asm
└── README.md
```

The main source file contains:

```text
.DATA
    Maze data
    Player data
    Stack
    Statistics
    Messages

.CODE
    MAIN
    GENERATE_MAZE
    DISPLAY_MAZE
    PLAY_MAZE
    CHECK_MOVE
    SOLVE_MAZE
    PUSH_STACK
    POP_STACK
    SHOW_STATISTICS
    PRINT_NUMBER
```

---

## Group Work Distribution

For a three-member group, the project can be divided into the following modules:

### Member 1 — Maze Generation

* Maze array implementation
* Maze initialization
* Maze generation algorithm
* Maze display

### Member 2 — Player Interaction

* Keyboard input
* Player movement
* Boundary detection
* Wall collision detection
* Player position management

### Member 3 — Pathfinding

* Stack implementation
* DFS algorithm
* Automatic maze solving
* Solution visualization
* Performance statistics

Each member therefore has multiple meaningful technical components to implement and explain.

---

## Limitations

Because the project is implemented in 8086 Assembly, the system intentionally uses a simple text-based interface rather than graphical rendering.

The maze size is also limited to a fixed size so that memory usage and array manipulation remain manageable within the 8086 environment.

The project focuses on demonstrating algorithm implementation and low-level programming rather than providing a full graphical maze application.

---

## Future Improvements

Possible extensions include:

* Implementing a true pseudo-random maze generator.
* Adding multiple maze difficulty levels.
* Implementing Breadth-First Search (BFS).
* Comparing DFS and BFS performance.
* Calculating the actual shortest path.
* Tracking the exact solution path using parent cells.
* Adding a timer for the player's attempt.
* Adding multiple starting and ending locations.
* Allowing the user to select maze dimensions.
* Comparing player performance with the automatic solver.

---

## Learning Outcomes

Through this project, the group will gain practical experience with:

1. Designing an algorithm in 8086 Assembly.
2. Managing arrays and memory locations.
3. Implementing a stack manually.
4. Using procedures to organize assembly programs.
5. Handling keyboard input using DOS interrupts.
6. Performing arithmetic and array-index calculations.
7. Implementing a search algorithm at a low level.
8. Understanding how high-level pathfinding algorithms can be translated into assembly instructions.

---

## Project Requirements Fulfilled

| Requirement            | Implementation             |
| ---------------------- | -------------------------- |
| Software-based project | Yes                        |
| 8086 Assembly          | Yes                        |
| Emu8086                | Yes                        |
| At least 6 features    | Yes                        |
| Array implementation   | Maze array                 |
| Stack implementation   | DFS stack                  |
| Procedures/Macros      | Multiple procedures        |
| Algorithmic component  | DFS pathfinding            |
| Interactive component  | Keyboard-controlled player |
| Demonstrable output    | ASCII maze and solution    |

---

## Conclusion

The Procedural Maze Generation and Intelligent Pathfinding System combines an interactive maze environment with algorithmic pathfinding. Instead of functioning as a simple information-management system, the project focuses on **data structures, algorithms, memory manipulation, and low-level problem solving**.

The use of an array for maze representation and a stack for DFS provides a direct demonstration of fundamental data structures in 8086 Assembly, while the interactive navigation and solution visualization make the project suitable for live demonstration in an Emu8086 environment.
