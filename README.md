# Transformer Differential Relay Protection

**Author:** Ahmad M. Salameh

## Overview

MATLAB/Simulink differential protection relay for three-phase power transformers.  
The relay calculates differential and restraint currents, applies 2nd harmonic inrush blocking, 5th harmonic restraint, high-set tripping, trip latching, and circuit breaker control.

## Tested Scenarios

1. Normal operation → No trip  
2. Three-phase internal fault → Trip  
3. External fault → No trip  
4. Transformer energization (inrush) → Blocked, no trip  
5. Single-phase internal fault → Trip  

## Key Features

- Percentage differential protection
- 2nd harmonic inrush blocking
- 5th harmonic restraint
- High-set tripping
- Trip latching
- Circuit breaker control

## Files

- `Transformer_Diff_Relay.slx` — Simulink model
- `Relay Algorithm (Code).m` — MATLAB Function code
- `Transformer Differential Protection.pdf` — Full report

## How to Run

1. Open MATLAB.
2. Open `Transformer_Diff_Relay.slx`.
3. Run the simulation.
4. Check the trip signal and relay outputs.

## License

MIT License
