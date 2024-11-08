clear all

modules_number = 9;

%% Internal Parameters

cfg.ts  = 1e-6;
cfg.fl  = 50;
cfg.r    = 26;
cfg.c    = 3*(3e-6+0.1e-6);
cfg.l    = 20e-3;
cfg.w    = 2*pi*cfg.fl;
cfg.sharing_L = 10E-3;
cfg.main_L = 200E-3;
cfg.cs_soft_start_time = 100E-6;

cfg.tri_phase_shift = 360/modules_number;

%% Controlled values

cfg.mf   = 63;
cfg.ma = 0.9238;
cfg.iref = 10;

%% Switches values
cfg.switch.Ron        = 1e-3;
cfg.switch.snubber_Rs = 1e7;
cfg.switch.snubber_Cs = inf;