Author: Ahmad M. Salameh

Overview

MATLAB/Simulink differential protection relay for three-phase power transformers. Calculates differential and restraint currents, applies 2nd harmonic inrush blocking and 5th harmonic restraint. Includes high-set tripping and CB control.

Tested Scenarios:
Normal operation → No trip
Three-phase internal fault → Trip
External fault → No trip
Transformer energization (inrush) → Blocked (no trip)
Single-phase internal fault → Trip

Key Features:
Percentage differential protection
2nd harmonic inrush blocking
5th harmonic restraint
High-set tripping
Trip latching
Circuit breaker control

Files:
Transformer_Diff_Relay.slx` - Simulink model
Relay_advanced.m` - MATLAB Function code
protection.pdf` - Full report

How to Run:
Open MATLAB
Open Transformer_Diff_Relay.slx
Run simulation
License

MIT License
