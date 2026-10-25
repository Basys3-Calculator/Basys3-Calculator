# Verilog Files

## [calc\_top.v]

Overall, calc\_top.v is the main design entry point. It uses sw\_encoder.v and debounce.v for inputs, calc\_fsm.v for calculator behavior, font\_rom.v and chars.vh for text generation, slow\_clock.v for timing, and Oled\_display.v to drive the OLED.

&#x20; The main calculator top-level module. It connects together:

&#x20; - The 100 MHz board clock

&#x20; - Debounced buttons

&#x20; - Switch-to-digit conversion

&#x20; - The calculator FSM

&#x20; - Character/font rendering

&#x20; - The OLED display driver

&#x20; It formats the calculator state onto the OLED. The top row shows the expression or result, while the bottom row shows the currently selected digit or operator.

## [calc\_fsm.v]

&#x20; Implements the calculator’s finite-state machine. It sequences through:

&#x20; 1. Enter first number (S\_N1)

&#x20; 2. Select an operator (S\_OP)

&#x20; 3. Enter second number and calculate (S\_N2)

&#x20; It stores n1, n2, and the operator, then computes addition, subtraction, multiplication, or division.

The current digit is used directly for the calculation. Results are stored in a 7-bit register, allowing values up to 127.

## [sw\_encoder.v]

&#x20; Converts the first ten switches into a digit. It expects exactly one switch to be active:

&#x20; - sw\[0] represents 0

&#x20; - sw\[1] represents 1

&#x20; - …

&#x20; - sw\[9] represents 9

&#x20; If zero or multiple switches are active, digit\_valid is cleared.

## [diff\_num\_rep.v]

&#x20; An empty placeholder module. It currently has no ports, logic, or functionality.

## [font\_rom.v]

&#x20; Contains 8×8 bitmap glyphs for digits, operators, the equals sign, and spaces. Given a character code and row number, it outputs the corresponding 8-bit row of pixels. The display logic scales each glyph to 16×16 pixels.

## [debounce.v]

&#x20; Filters mechanical button bouncing. It samples the button at approximately 1 ms intervals and generates a one-clock-cycle pulse when a button press is detected. It then ignores further changes for roughly 200 ms.

## [slow\_clock.v]

&#x20; Divides the Basys3’s 100 MHz clock down to approximately 6.25 MHz by toggling the output every eight input-clock cycles. This clock is used by the OLED controller.

## [Oled\_display.v]

&#x20; A reusable OLED controller for the 96×64 RGB OLED display. It:

&#x20; - Performs OLED startup and configuration

&#x20; - Generates display timing

&#x20; - Sends pixel data over SPI-like signals

&#x20; - Requests pixels using pixel\_index

&#x20; - Drives the PMOD control pins

&#x20; The file explicitly says it should not be modified.

## [calc\_oled\_test.v]

&#x20; A standalone OLED test top module.

It displays the hardcoded expression 5+3=8 on the first OLED row and displays the switch-selected digit on the bottom row.

It is intended for testing the font renderer, OLED layout, and switch encoder before using the complete calculator.





# Verilog Header Files

## [chars.vh]

&#x20; Defines 4-bit character codes for digits 0–9, the four operators, the equals sign, and a blank space. These codes are shared by the font ROM and display logic.

## [calc\_params.vh]

&#x20; A Verilog header containing shared constants:

&#x20; - FSM states: entering number 1, selecting an operator, entering number 2

&#x20; - Operator codes: add, subtract, multiply, divide





# Constraint File

## [constraints.xdc]

&#x20; Maps the Verilog ports to physical pins on the Basys3 board. It assigns pins for:

&#x20; - The 100 MHz clock

&#x20; - Switches

&#x20; - Pushbuttons

&#x20; - PMOD header JB, which connects to the OLED

&#x20; LED, seven-segment, and other PMOD assignments are present but commented out.
