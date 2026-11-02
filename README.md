# Basys3-Calculator
FPGA Design Project for NUS EE2026 Digital Design

## Features

- Calculator mode with basic arithmetic, rounded division, and error display.
- Number representation mode for decimal, octal, hexadecimal, and binary.
- Trigonometric mode for sine, cosine, and tangent, with degree/radian input.
- Tangent undefined warnings at asymptotes and improved whole-degree precision.
- Polynomial mode for linear and quadratic roots, including complex answers.
- OLED menus and mode-specific color coding: yellow labels, green confirmed
  values, cyan pending input, and orange error messages.

The OLED menu is shown when no mode switch is selected. Mode-conflict and
multi-digit-selection warnings are displayed directly on the OLED.

## Code Files

Verilog, Verilog Header and Constraint Files are found in Basys3-Calculator.srcs/sources_1/new.

## Tracking the Project Files

### What to track:
• Source Files: Your .v (Verilog), .sv (SystemVerilog), or .vhd (VHDL) files located inside the *.srcs/ directory.

• Constraints File: Your .xdc file (which defines pinouts and timing constraints).

• Project File: The .xpr file, which holds the project structure and references.

• IP Blocks (if used): Only the .xci configuration files for your IP, not the generated outputs.

### What to ignore:
You must exclude auto-generated directories like *.cache/, *.runs/, *.hw/,
*.sim/, *.gen/, *.ip_user_files/, *.srcs/utils_1/, and massive binary output
files like .bit or .mcs streams unless you are marking a final release.
