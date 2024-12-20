clear all

modules_number = 9;

%% SPWM_Mod_Block

cfg.clk_freq = 40e6;
cfg.tri_freq = 160e3;
cfg.mod_number = 3;

%This counter value shouldn't exceed 255 (tri_freq >= 160E3)
% else general uint8 data type have to be changed into uint16. 
cfg.sawtooth_counter = cfg.clk_freq/cfg.tri_freq - 1;

cfg.phase_mul_var = (uint16(cfg.sawtooth_counter/cfg.mod_number));

cfg.sawtooth_phase = [0*cfg.phase_mul_var
                      1*cfg.phase_mul_var
                      2*cfg.phase_mul_var];

cfg.tri_counter_comp = uint16(cfg.sawtooth_counter / 2 - 1);

%% Internal Parameters

cfg.ts  = 2.5e-8;
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


%% Simulation Reference

cfg.sim_ref_gain = uint8((cfg.tri_counter_comp / 2) *cfg.ma );