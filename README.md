# CORDIC Hardware Accelerator

## Overview
A fully synchronous, pipelined hardware accelerator for trigonometric calculations (Sine/Cosine) implemented in Verilog. The design utilizes the CORDIC algorithm to perform complex calculations using only shift-and-add operations, eliminating the need for expensive multipliers.

## Key Features
* **Multiplier-less Architecture:** Uses shift-and-add operations for area efficiency.
* **Pipelined Design:** Maximizes throughput for high-frequency operation.
* **Performance:** Achieves **0.14 cycles/element** throughput.
* **Verification:** Validated with a Python-based reference model and self-checking testbench.

## Directory Structure
* `rtl/`: SystemVerilog/Verilog source code.
* `tb/`: Testbench files and simulation scripts.
* `scripts/`: Python reference model (`cordic_rotate.py`).
* `reports/`: Synthesis and Timing reports.

## Tools Used
* **Simulation:** Cadence SimVision / ModelSim
* **Language:** Verilog, Python
