# Basys3 Calculator

This directory contains the Verilog source files for the Basys3 calculator, its OLED interface, and the trigonometric-function mode.

## Group theme

This project is an integrated FPGA-based calculator system for the Digilent Basys3 board. It combines a normal arithmetic calculator, a number-representation converter, and a trigonometric calculator behind a shared switch-and-button interface. Results and input status are presented on the onboard OLED display, while the LEDs provide immediate switch-state feedback. The system's main capabilities include four basic arithmetic operations, decimal-to-binary/octal/hexadecimal conversion, three-digit sine/cosine/tangent calculations with four-decimal-place results, degree/radian selection, tangent undefined detection, and input validation when multiple digit switches are selected. Together, these components demonstrate interactive digital computation, fixed-point lookup-table calculations, mode control, and hardware display interfacing on the Basys3 FPGA platform.

## User workflow

1. Power the Basys3 board and wait for the OLED to initialize.
2. Select one operating mode using `SW11`, `SW12`, or `SW13`:
   - `SW11` for arithmetic operations.
   - `SW12` for number conversion.
   - `SW13` for trigonometric functions.
   - Leave `SW11`–`SW13` off to return to the mode-selection screen. `SW10` does not affect mode selection.
3. In any mode, select a digit by turning on exactly one of `SW0`–`SW9`. The corresponding LED turns on. If multiple digit switches are on, follow the OLED instruction `SELECT ONE / DIGIT ONLY` before continuing.
4. When finished with a mode, turn off its mode switch before selecting another mode. Each mode retains its internal state while inactive.

### Arithmetic calculation

1. Select `SW11`.
2. Select the first digit with `SW0`–`SW9` and press `btnC` to confirm it.
3. Select an operator: `btnU` for addition, `btnD` for subtraction, `btnL` for multiplication, or `btnR` for division.
4. Press `btnC` to confirm the operator.
5. Select the second digit and press `btnC` to calculate.
6. Read the completed equation and result on the OLED. The calculator records completed equations in its display history; up to seven entries can be retained, with older entries scrolling away when the history is full.

### Number conversion

1. Select `SW12`.
2. Select and confirm one, two, or three decimal digits with `SW0`–`SW9` and `btnC`. For example, confirm `1`, then `2`, then `3` to enter `123`.
3. Select the output representation with `btnU` for binary, `btnR` for octal, `btnD` for hexadecimal, or `btnL` for decimal.
4. Read the converted value on the OLED.
5. Press `btnC` after a conversion has been displayed, or after three digits have been entered, to clear the value and begin a new entry.

### Trigonometric calculation

1. Select `SW13`.
2. The default input unit is degrees. Press `btnL` at any time to switch between degrees and radians; the existing input is preserved.
3. Select and confirm one, two, or three digits with `SW0`–`SW9` and `btnC`.
4. Press `btnU` for sine, `btnR` for cosine, or `btnD` for tangent. The selected function can be changed by pressing another function button without re-entering the number.
5. Read the expression and four-decimal-place result on the OLED. The expression shows `°` for degree mode and ` RAD` for radian mode.
6. For tangent, an input at an odd multiple of 90 degrees is displayed as `UNDEFINED` instead of a clamped numerical value.
7. Press `btnC` with no digit selected, or after three digits have been entered, to clear the trigonometric input. The selected function and degree/radian setting are preserved.

### Indicators and display behavior

- Each switch has a corresponding LED indicator.
- The OLED shows the current mode, input, equation, result, conversion, or error message.
- Error messages use reddish orange, while the pending bottom-left digit or operator uses cyan.
- The seven-segment display is intentionally disabled and remains off. Its outputs are driven to the inactive state so it can be used for a future feature.

## Mode selection

Only one of switches 11–13 should be on at a time. `SW10` is ignored for mode selection:

| Switch | Function |
|---|---|
| `SW10` | Reserved / ignored by mode selection |
| `SW11` | Operations calculator |
| `SW12` | Number-representation converter |
| `SW13` | Trigonometric functions |

With `SW11`–`SW13` all off, the OLED displays the centered mode-selection header `- SELECT MODE -`. If more than one of those three mode selectors is on, it displays:

```text
SELECT ONE
MODE ONLY
```

The LEDs mirror the switch states.

Switches `SW0`–`SW9` are one-hot digit inputs. When two or more digit switches are on in an active input mode, the OLED displays the centered warning:

```text
SELECT ONE
DIGIT ONLY
```

## Operations mode (`SW11`)

The normal calculator is implemented by `calc_fsm.v`. It supports addition, subtraction, multiplication, and division using the calculator's pushbuttons. Negative subtraction results are clamped to zero, and division by zero produces zero. The current implementation enters single decimal digits for the operands.

## Number-representation mode (`SW12`)

`diff_num_rep.v` stores a decimal input of up to three digits, from 0 through 999.

- `btnC` confirms each selected digit.
- `btnU` selects binary output.
- `btnR` selects octal output.
- `btnD` selects hexadecimal output.
- `btnL` selects decimal output.
- `btnC` with no digit selected clears the current value.

The selected digit is shown at the bottom of the OLED while it is being entered. The confirmed value is rendered above it.

## Trigonometric mode (`SW13`)

`trig_top.v`, `trig_ctrl.v`, `trig_lut.v`, `trig_text.v`, and `trig_display.v` implement the trigonometric mode.

### Input and controls

- Select one digit with `SW0`–`SW9`.
- Press `btnC` to append/confirm the selected digit.
- Inputs are limited to one through three digits.
- Press `btnU` for sine.
- Press `btnR` for cosine.
- Press `btnD` for tangent.
- Press `btnL` to toggle between degree and radian input.
- Press `btnC` with no digit selected, or after three digits have been entered, to clear the input.

The selected digit remains visible at the bottom-left while entering the number. After confirmation, the value moves into the expression line. Clearing the input preserves the selected trigonometric function; it does not automatically return to sine.

The OLED expression uses the selected unit, for example:

```text
SIN(90°)
=0.0000
```

or:

```text
SIN(90 RAD)
=0.8940
```

The result is displayed to four decimal places with rounding in both directions. Tangent is reported as `UNDEFINED` when the cosine of the input is zero, including odd multiples of 90 degrees.

The trigonometric implementation uses a half-degree sine lookup table with higher internal precision. Cosine is calculated using a 90-degree phase shift, and tangent is calculated from the sine/cosine ratio. Degree inputs are normalized by the lookup-table period; radian inputs retain the fractional conversion constant before interpolation and are rounded only when producing the four-decimal-place result.

## Verilog source files

### `calc_top.v`

Top-level module. It connects the clock, debounced pushbuttons, switch encoder, calculator modes, OLED controller, LED outputs, and disabled seven-segment outputs. It selects the active mode and multiplexes the corresponding OLED pixel data.

### `calc_fsm.v`

Finite-state machine for the operations calculator. Its states handle the first number, operator selection, second number, and result display.

### `diff_num_rep.v`

Stores the decimal input and generates binary, octal, hexadecimal, or decimal conversion results.

### `trig_top.v`

Top-level wrapper for the trigonometric input, calculation, and text-rendering modules.

### `trig_ctrl.v`

Stores the one-to-three-digit input, selected trigonometric function, and degree/radian mode. It also handles clearing and repeated confirmation of the same selected switch digit.

### `trig_lut.v`

Contains the scaled sine lookup table and the fixed-point calculations for sine, cosine, tangent, unit conversion, interpolation, rounding, and tangent undefined detection.

### `trig_text.v`

Generates the character codes for the trigonometric expression, result, pending digit, and the `SELECT ONE / DIGIT ONLY` warning.

### `trig_display.v`

Connects trigonometric calculation state to the character renderer.

### `sw_encoder.v`

Converts `SW0`–`SW9` into a 4-bit digit. `digit_valid` is asserted only when exactly one digit switch is active.

### `debounce.v`

Filters mechanical button bounce and generates one-clock-cycle button pulses.

### `font_rom.v`

Contains the 8×8 bitmap glyphs used by the OLED renderer. Glyphs are sampled at 2× scale to form 16×16 character cells. It includes calculator symbols, hexadecimal letters, labels, warning-message letters, parentheses, decimal point, and degree symbol.

### `slow_clock.v`

Divides the 100 MHz board clock to approximately 6.25 MHz for the OLED controller.

### `Oled_display.v`

Drives the 96×64 RGB OLED connected to the PMOD interface. It handles OLED initialization, pixel timing, and serial pixel output.

### `calc_oled_test.v`

Standalone OLED test top module. It displays a fixed `5+3=8` expression and can be used to test the OLED, font ROM, and switch encoder independently.

## Header files

### `chars.vh`

Defines the character-code constants shared by the renderers and `font_rom.v`.

### `calc_params.vh`

Defines the normal calculator FSM states and operator codes shared by `calc_fsm.v` and `calc_top.v`.

## Hardware configuration

### `constraints.xdc`

Maps the top-level ports to the physical Basys3 pins, including the 100 MHz clock, pushbuttons, switches, LEDs, seven-segment display, and OLED PMOD signals.

The LEDs mirror `SW0`–`SW15`. The seven-segment display is currently intentionally disabled: its active-low segment, decimal-point, and anode outputs are driven high so that no segments remain lit. It can be re-enabled later without changing the OLED functionality.
