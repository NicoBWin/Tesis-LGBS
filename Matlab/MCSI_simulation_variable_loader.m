clear all

modules_number = 9;

%% Internal Parameters

cfg.ts  = 2.083333333e-8;
cfg.fl  = 100;
cfg.r    = 10;
cfg.c    = 3*(3e-6+0.1e-6);
cfg.l    = 1e-3;
cfg.w    = 2*pi*cfg.fl;
cfg.sharing_L = 2E-3;
cfg.sharing_R = 14;
cfg.main_L = 4E-3;
cfg.cs_soft_start_time = 1E-2;

cfg.tri_phase_shift = 360/modules_number;

%% Controlled values

cfg.mf   = 2000;
cfg.ma = 1; %0.9238
cfg.iref = 5;

%% Switches values
cfg.switch.Ron        = 1e-3;
cfg.switch.snubber_Rs = 1e7;
cfg.switch.snubber_Cs = inf;

%% Refresh Period Simulation

cfg.refresh_period = 1/250e3;

%% Parameters of interest

cut_freq_load_filter_1 = (1/(2*pi))*((2*cfg.sharing_L*3*cfg.c))^0.5
cut_freq_load_filter_2 = (1/(2*pi))*((2*cfg.sharing_L*3*9*cfg.c))^0.5  