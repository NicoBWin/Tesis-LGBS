clear
clc

D = 0.1; % Approximation 
R_i = 1; %(inductor current sense transformer gain in ohm)
T_s = 1 / (20E3)
V_in = 100;

L = 8E-3;

Vpp_Ramp = (D - 0.18)*R_i*T_s*V_in/L