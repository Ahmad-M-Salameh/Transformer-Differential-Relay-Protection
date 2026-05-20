function [Trip, CB_cmd, Id_display, Ir_display, H2_display, Inrush_Block, Inrush_Current_display] = Relay_advanced(I1_pu_raw, I2_pu_raw)
persistent buf1 buf2 k trip_latch polarity_ready pol trip_counter

%% Simulation parameters
Ts = 1e-4;                 % powergui sample time
f0 = 50;                   % system frequency
N  = round(1/(f0*Ts));     % samples per cycle = 200

%% Relay settings
startup_block_time = 0.08;
startup_samples    = round(startup_block_time/Ts);

Id_pickup = 0.25;          % pu minimum pickup
Slope1    = 0.30;
Slope2    = 0.70;
Ir_break  = 1.50;          % pu

HighSet = 6.00;            % pu instantaneous differential trip

H2_block_ratio = 0.15;     % second harmonic inrush blocking
H5_block_ratio = 0.25;     % fifth harmonic overexcitation blocking

confirm_time    = 0.005;   % 5 ms confirmation time
confirm_samples = round(confirm_time/Ts);

%% Initialize
if isempty(buf1)
    buf1 = zeros(N,3);
    buf2 = zeros(N,3);
    k = 0;
    trip_latch = 0;
    polarity_ready = 0;
    pol = 1;
    trip_counter = 0;
end

%% Default outputs
Trip = trip_latch;
CB_cmd = 1 - Trip;

Id_display = 0;
Ir_display = 0;
H2_display = 0;
Inrush_Block = 0;
Inrush_Current_display = 0;

%% Input formatting
I1 = reshape(I1_pu_raw, 1, []);
I2 = reshape(I2_pu_raw, 1, []);

if length(I1) < 3 || length(I2) < 3
    Trip = 0;
    CB_cmd = 1;
    Id_display = 0;
    Ir_display = 0;
    H2_display = 0;
    Inrush_Block = 0;
    Inrush_Current_display = 0;
    return;
end

I1 = I1(1:3);
I2 = I2(1:3);

%% Inrush current display signal
% This output shows the instantaneous primary-side current magnitude.
% It is useful for observing the current behavior during transformer energization.
Inrush_Current_display = max(abs(I1));

%% Buffer update
k = k + 1;
idx = mod(k-1, N) + 1;

buf1(idx,:) = I1;
buf2(idx,:) = I2;

%% Wait until one full cycle is available
if k < N
    Trip = trip_latch;
    CB_cmd = 1 - Trip;
    Id_display = 0;
    Ir_display = 0;
    H2_display = 0;
    Inrush_Block = 0;
    return;
end

%% Arrange one-cycle window
if idx == N
    x1 = buf1;
    x2 = buf2;
else
    x1 = [buf1(idx+1:end,:); buf1(1:idx,:)];
    x2 = [buf2(idx+1:end,:); buf2(1:idx,:)];
end

%% DFT phasors
I1_1 = local_dft(x1, 1, N);   % fundamental
I2_1 = local_dft(x2, 1, N);

I1_2 = local_dft(x1, 2, N);   % second harmonic
I2_2 = local_dft(x2, 2, N);

I1_5 = local_dft(x1, 5, N);   % fifth harmonic
I2_5 = local_dft(x2, 5, N);

%% Automatic polarity correction
% This selects the correct secondary current direction during the initial healthy period.
if polarity_ready == 0 && k > N && k < startup_samples

    error_same_direction     = sum(abs(I1_1 - I2_1));
    error_opposite_direction = sum(abs(I1_1 + I2_1));

    if error_same_direction <= error_opposite_direction
        pol = 1;
    else
        pol = -1;
    end

    polarity_ready = 1;
end

I2c_1 = pol * I2_1;
I2c_2 = pol * I2_2;
I2c_5 = pol * I2_5;

%% Differential and restraint currents
Id_phase = abs(I1_1 - I2c_1);
Ir_phase = 0.5 * (abs(I1_1) + abs(I2c_1));

Id_display = max(Id_phase);
Ir_display = max(Ir_phase);

%% Harmonic ratios
Id2_phase = abs(I1_2 - I2c_2);
Id5_phase = abs(I1_5 - I2c_5);

H2_ratio = zeros(1,3);
H5_ratio = zeros(1,3);

for ph = 1:3
    if Id_phase(ph) > 1e-6
        H2_ratio(ph) = Id2_phase(ph) / Id_phase(ph);
        H5_ratio(ph) = Id5_phase(ph) / Id_phase(ph);
    else
        H2_ratio(ph) = 0;
        H5_ratio(ph) = 0;
    end
end

H2_display = max(H2_ratio);

if H2_display > H2_block_ratio
    Inrush_Block = 1;
else
    Inrush_Block = 0;
end

%% Differential operation logic
Diff_Operate = 0;
HighSet_Trip = 0;

for ph = 1:3

    Id = Id_phase(ph);
    Ir = Ir_phase(ph);

    if Ir <= Ir_break
        threshold = Id_pickup + Slope1 * Ir;
    else
        threshold = Id_pickup + Slope1 * Ir_break + Slope2 * (Ir - Ir_break);
    end

    phase_inrush_block = H2_ratio(ph) > H2_block_ratio;
    phase_overexc_block = H5_ratio(ph) > H5_block_ratio;

    normal_diff_condition = (Id > threshold) && ~phase_inrush_block && ~phase_overexc_block;
    highset_condition = Id > HighSet;

    if normal_diff_condition
        Diff_Operate = 1;
    end

    if highset_condition
        HighSet_Trip = 1;
    end
end

%% Startup blocking
if k < startup_samples
    Diff_Operate = 0;
    HighSet_Trip = 0;
    Inrush_Block = 0;
end

%% Final trip with confirmation time
operate = Diff_Operate || HighSet_Trip;

if operate == 1
    trip_counter = trip_counter + 1;
else
    trip_counter = 0;
end

if trip_counter >= confirm_samples
    trip_latch = 1;
end

Trip = trip_latch;

% Breaker command:
% 1 = Closed
% 0 = Open
CB_cmd = 1 - Trip;

end

%% ==========================================================
function phasor = local_dft(x, h, N)
% RMS complex phasor for harmonic order h
% x size: N x 3

phasor = complex(zeros(1,3), zeros(1,3));

n = 0:N-1;
w = exp(-1i * 2*pi*h*n/N).';

for ph = 1:3
    temp = (sqrt(2)/N) * sum(x(:,ph) .* w);
    phasor(ph) = complex(temp);
end

end