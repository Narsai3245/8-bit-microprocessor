# 8-Bit Microprocessor (VHDL / FPGA)

A single-cycle-per-state 8-bit microprocessor implemented in VHDL for the Digilent Nexys A7-100T FPGA board. Built for an ECE 2700 (Digital Logic) course project.

## Overview

The processor is a simple switch-programmed machine: a 6-bit instruction is set on the board's switches (`IR_in`, encoded as `[5:2]=op`, `[1]=Ry`, `[0]=Rx`), and pulsing `w` latches the instruction and steps the control unit's FSM through fetch/execute. Results are shown on the board's multiplexed 7-segment display.

### Datapath

- **`alu8`** — 8-bit ALU, operation selected by a 4-bit opcode
- **`control_unit`** — FSM driving the datapath through two instruction paths:
  - **LDI path**: `CAPTURE_IN` → `LOAD_IN_TO_RX` — loads the switch input into a register
  - **ALU path**: `LOAD_A` → `EXEC1` → `WRITEBK` → `COMPLETE` — loads operands, executes the ALU op, writes back the result, and pulses `done`
- **`my_rege`** — 8-bit register with enable and synchronous clear, used for `IN`, `R0`, `R1`, `A`, `G`, and `OUT`
- **`my_4to1MUX`** — 4-to-1 8-bit bus mux selecting the internal bus source (`IN`, `G`, `R0`, or `R1`)

### I/O and support logic

- **`Debouncer/`** — switch/button debouncing (`mydebouncer.vhd`) built on a generic pulse generator (`my_genpulse_sclr.vhd`)
- **`2 Display Serializer/`** — drives two 7-segment digits from an 8-bit value: binary-to-BCD/hex decoding (`Dec2_2.vhd`, `hex2sevenseg.vhd`), a serializing FSM (`FSM_Ser_2.vhd`), and digit multiplexing (`MUX2_1.vhd`, `serializer_2disp.vhd`)
- **`top.vhd`** — top-level entity wiring the datapath, control unit, and display together for the Nexys A7-100T
- **`tb_top.vhd`** — testbench for the top-level design
- **`Nexys-A7-100T-Master.xdc`** — pin constraints for the Nexys A7-100T board

## Target hardware

Digilent Nexys A7-100T (Xilinx Artix-7), built/simulated in Xilinx Vivado.

## Building

Open Vivado, create a project targeting the Nexys A7-100T (`xc7a100tcsg324-1`), add all `.vhd` sources and the `.xdc` constraints file, set `top` as the top-level module, then run synthesis, implementation, and generate the bitstream.
