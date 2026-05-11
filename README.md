# Parameterized ALU — RTL Design and Functional Verification

## Overview

This project presents the RTL design and functional verification of a Parameterized Arithmetic and Logic Unit (ALU) implemented in Verilog HDL. The ALU supports both arithmetic and logical operations across a configurable operand width. Verification is carried out using a self-checking testbench that compares the DUT against a combinational reference model for every test vector.

---



## Design Parameters

| Parameter | Default | Description |
|---|---|---|
| `b` / `width` | 8 | Operand bit width |
| `c` | 4 | Command bus width |

---

## Supported Operations

### Arithmetic Mode (`mode = 1`)

| CMD | Operation |
|---|---|
| 0 | Unsigned Add |
| 1 | Unsigned Subtract |
| 2 | Add with Carry |
| 3 | Subtract with Borrow |
| 4 | Increment A |
| 5 | Decrement A |
| 6 | Increment B |
| 7 | Decrement B |
| 8 | Unsigned Compare |
| 9 | Increment Multiply — (opa+1)×(opb+1) |
| 10 | Shift Multiply — (opa<<1)×opb |
| 11 | Signed Add |
| 12 | Signed Subtract |

### Logical Mode (`mode = 0`)

| CMD | Operation |
|---|---|
| 0 | AND |
| 1 | NAND |
| 2 | OR |
| 3 | NOR |
| 4 | XOR |
| 5 | XNOR |
| 6 | NOT A |
| 7 | NOT B |
| 8 | Shift Right A |
| 9 | Shift Left A |
| 10 | Shift Right B |
| 11 | Shift Left B |
| 12 | Rotate Left A |
| 13 | Rotate Right A |

---

## Testbench Architecture

The testbench uses a dual-instantiation self-checking architecture. Both the DUT and the reference model receive identical stimulus simultaneously. All outputs are compared after every test vector and a PASS or FAIL is reported. Cumulative pass and fail counts are printed at the end of simulation.

### Test Coverage

| Category | Vectors |
|---|---|
| Reset / CE disable | 2 |
| inp_valid corner cases | 4 |
| Arithmetic — valid inputs | 31 |
| Logical — valid inputs | 20 |
| Arithmetic — invalid inputs | 16 |
| Logical — invalid inputs | 14 |
| Out-of-range commands | 2 |
| Corner / overflow / rotate cases | 18 |
| **Total** | **107** |

---

## Simulation Results


RESULTS:  PASS=95  FAIL=12


Simulated using Questa SIM v10.6c. Synthesis checks performed using Vivado.

---

## Tools Used

| Tool | Version | Purpose |
|---|---|---|
| Questa SIM | 10.6c | Functional simulation and coverage |
| Vivado | — | RTL synthesis and lint checks |

---

## Author

**Name:** Harshitha Naik

**Date:** May 2026

