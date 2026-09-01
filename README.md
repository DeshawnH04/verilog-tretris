# Verilog Tetris

FPGA-based Tetris game implemented in Verilog with game logic, VGA graphics, timing control, input handling, and score rendering.

## Features
- Tetris gameplay implemented in Verilog
- VGA video output
- Piece movement and game control
- Line clearing
- Game-over detection
- Score display
- Button debouncing and edge detection
- Hardware-based timing for gravity and game events

## Main Modules
- `tetris_top.v` - Top-level design
- `tetris_game_logic.v` - Core game logic
- `tetris_controller.v` - Game control
- `tetris_board_renderer.v` - Tetris board graphics
- `tetris_grid_renderer.v` - Grid rendering
- `tetris_vga_top.v` - VGA integration
- `vga_controller.v` - VGA timing
- `arcade_scoreboard_renderer.v` - Score display
- `game_over_renderer.v` - Game-over graphics
- `gravity_tick_gen.v` - Piece fall timing
- `line_clear_timer.v` - Line-clear timing
- `lock_delay_timer.v` - Piece lock timing
- `debounce.v` - Button debouncing
- `edge_detect.v` - Input edge detection

## Concepts Used
- Verilog HDL
- FPGA design
- Finite state machines
- VGA timing and graphics
- Sequential and combinational logic
- Counters and timers
- Digital input handling
- Modular hardware design

## Tools
- Vivado
- FPGA development board
