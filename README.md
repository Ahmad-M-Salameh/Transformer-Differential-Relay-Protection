Author: Ahmad M. Salameh

Overview

MATLAB/Simulink differential protection relay for three-phase power transformers. Calculates differential and restraint currents, applies 2nd harmonic inrush blocking and 5th harmonic restraint. Includes high-set tripping and CB control.

Tested Scenarios:
1.Normal operation → No trip
2.Three-phase internal fault → Trip
3.External fault → No trip
4.Transformer energization (inrush) → Blocked (no trip)
5.Single-phase internal fault → Trip

Key Features:
1.Percentage differential protection
2.2nd harmonic inrush blocking
3.5th harmonic restraint
4.High-set tripping
5.Trip latching
6.Circuit breaker control

Files:
1.Transformer_Diff_Relay.slx` - Simulink model
2.Relay Algorethim - MATLAB Function code
3.Transformer Differential Protection.pdf - Full report

How to Run:
1.Open MATLAB
2.Open Transformer_Diff_Relay.slx
3.Run simulation

License
MIT License
