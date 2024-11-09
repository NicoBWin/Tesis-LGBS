clear all

modules_number = 9;

%% Internal Parameters

cfg.ts  = 5e-9;
cfg.fl  = 50;
cfg.r    = 10;
cfg.c    = 3*(3e-6+0.1e-6);
cfg.l    = 20e-3;
cfg.w    = 2*pi*cfg.fl;
cfg.sharing_L = 1E-3;
cfg.main_L = 0E-3;
cfg.cs_soft_start_time = 1E-3;

cfg.tri_phase_shift = 360/modules_number;

%% Controlled values

cfg.mf   = 5001;
cfg.ma = 0.9238;
cfg.iref = 10;

%% Switches values
cfg.switch.Ron        = 1e-3;
cfg.switch.snubber_Rs = 1e7;
cfg.switch.snubber_Cs = inf;