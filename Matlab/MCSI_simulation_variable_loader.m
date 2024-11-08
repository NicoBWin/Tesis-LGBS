clear all

%% Internal Parameters

cfg.ts  = 1e-6;
cfg.fl  = 50;
cfg.r    = 26;
cfg.c    = 3*(3e-6+0.1e-6);
cfg.l    = 20e-3;
cfg.w    = 2*pi*cfg.fl;

%% Controlled values

cfg.mf   = 63;
cfg.ma = 0.9238;

%% Switches values
cfg.switch.Ron        = 1e-3;
cfg.switch.snubber_Rs = 1e7;
cfg.switch.snubber_Cs = inf;