# Basys3 Calculator

This directory contains the Verilog source files for the Basys3 calculator and its OLED display interface.

## Operating modes

The top-level design selects its operating mode using switches 11 and 12:

| SW11 | SW12 | Mode |
|---:|---:|---|
| 0 | 0 | Mode-selection screen |
| 1 | 0 | Normal calculator |
| 0 | 1 | Number-representation converter |
| 1 | 1 | Mode-conflict screen |

Switches 0–9 are one-hot digit inputs. Exactly one of these switches must be on at a time.

When both mode switches are off, the OLED displays `SELECT MODE`, `11: OPERATIONS`, and `12: NUMBER REP`. When both are on, it displays `MODE CONFLICT` and `TURN ONE OFF`. Inputs are gated by the active mode, while each mode preserves its internal state when inactive.

## Verilog source files

### `calc_top.v`

The main top-level module. It connects the 100 MHz clock, debounced pushbuttons, switch-to-digit encoding, both calculator modules, character rendering, and the OLED controller.

It selects the active mode, converts the selected state into character codes, and generates OLED pixel data.

Normal calculator mode uses 16×16 character cells. Number-representation mode also uses 16×16 cells:

- The label appears near the top.
- The confirmed value appears below the label.
- Long binary values wrap onto the next row.
- The currently selected switch digit appears once near the bottom while entering a number.

### `calc_fsm.v`

Implements the normal calculator finite-state machine:

1. `S_N1`: enter the first number.
2. `S_OP`: select an operator.
3. `S_N2`: enter the second number and calculate.

The supported operators are addition, subtraction, multiplication, and division. Subtraction is clamped to zero for negative results, and division by zero produces zero.

The operands are currently single decimal digits. The result is stored in a 7-bit register.

### `diff_num_rep.v`

Implements the number-representation converter.

- Stores a decimal value of up to three digits, from 0 through 999.
- Uses `btnC` to confirm each entered digit.
- Allows one-, two-, or three-digit inputs.
- Uses `btnU` for binary.
- Uses `btnR` for octal.
- Uses `btnD` for hexadecimal.
- Uses `btnL` for decimal.
- Uses `btnC` after conversion to clear the value and start a new entry.

The output includes the stored value, the number of confirmed digits, and the selected representation mode.

### `sw_encoder.v`

Converts switches 0–9 into a 4-bit digit:

- `sw[0]` represents 0.
- `sw[1]` represents 1.
- `...`
- `sw[9]` represents 9.

`digit_valid` is asserted only when exactly one digit switch is active.

### `debounce.v`

Filters mechanical button bouncing and generates a one-clock-cycle pulse for each button press.

### `font_rom.v`

Contains 8×8 bitmap glyphs. The OLED renderer samples each glyph at 2× scale to produce 16×16 characters.

The font includes digits 0–9, calculator operators, the equals sign, hexadecimal letters A–F, letters used by `BIN`, `OCT`, `HEX`, and `DEC`, a colon, and a blank space.

### `slow_clock.v`

Divides the 100 MHz board clock to approximately 6.25 MHz for the OLED controller.

### `Oled_display.v`

Drives the 96×64 RGB OLED connected to the PMOD interface. It handles OLED initialization, pixel timing, and serial pixel output.

This is a reusable display controller and should not normally be modified.

### `calc_oled_test.v`

A standalone OLED test top module. It displays a fixed `5+3=8` expression and tests switch-to-digit display behavior.

It is useful for checking the OLED, font ROM, switch encoder, and display timing independently of the calculator FSM.

## Header files

### `chars.vh`

Defines character-code constants shared by `calc_top.v` and `font_rom.v`.

Codes 0–15 contain the original calculator characters. Additional codes contain letters A–F, label letters, the colon, and the blank character.

### `calc_params.vh`

Defines the normal calculator FSM states and operator codes shared by `calc_fsm.v` and `calc_top.v`.

## Other files

### `constraints.xdc`

Maps the top-level ports to physical Basys3 pins, including the 100 MHz clock, pushbuttons, switches, and OLED PMOD signals.

Some LED and seven-segment display assignments are present but commented out.
