# 32-Stage Pipelined CORDIC Hardware Accelerator (Verilog)

## Overview
This project is a high-performance hardware implementation of the **CORDIC (Coordinate Rotation Digital Computer)** algorithm, designed using **SystemVerilog**. The core is fully pipelined to maximize data throughput, calculating trigonometric functions (Sine, Cosine, Phase Shift) without using expensive hardware multipliers.

The design was verified against a Python Golden Model and synthesized for an **Intel MAX 10 FPGA**.

## Key Features
* **Architecture:** Iterative architecture unrolled into a 32-stage deep pipeline.
* **Throughput:** Produces 1 valid result every clock cycle (after initial latency).
* **Efficiency:** Multiplier-less implementation (Shift-and-Add operations only), resulting in **0 DSP blocks used**.
* **Verification:** Bit-accurate matching against a floating-point Python reference model.

## Implementation Results (Post-Synthesis)
Target Device: Intel MAX 10 (10M50DAF484C7G)

| Metric | Value | Description |
| :--- | :--- | :--- |
| **Max Frequency (Fmax)** | **95.57 MHz** | Verified at Slow 1200mV 85C Model |
| **Logic Elements** | **2,585** (5%) | Low area utilization |
| **DSP Blocks** | **0** | Confirms pure shift/add topology |
| **Registers** | **1,550** | Supports the deep pipeline structure |

## System Architecture
The CORDIC core is built as a pipeline of 31 combinational stages separated by registers.
1.  **Input:** Accepts X, Y coordinates and a Phase angle.
2.  **Processing:** Each stage performs a fixed rotation using a pre-calculated `atan` lookup table (hardcoded in logic).
3.  **Arithmetic:** Uses arithmetic shifts (`>>>`) effectively replacing complex multiplication logic.

## Verification Flow
The project includes a full self-checking testbench environment:

1.  **Python Script (`cordic_rotate.py`):**
    * Generates random test vectors.
    * Calculates expected results using standard math libraries.
    * Exports input and reference output files (`.mem`).

2.  **SystemVerilog Testbench (`cordic_pipeline_32_tb.sv`):**
    * Reads the generated memory files.
    * Drives the DUT (Device Under Test) continuously.
    * Writes the hardware outputs to text files for comparison.

## How to Run
1.  Generate test vectors:
    `python3 cordic_rotate.py`
2.  Open the project in **Intel Quartus Prime** or **ModelSim**.
3.  Compile `rtl/pipeline.sv` and `rtl/cordic_phase_shifter.sv`.
4.  Run the testbench `tb/cordic_pipeline_32_tb.sv`.

---
*FPGA Implementation Project*
