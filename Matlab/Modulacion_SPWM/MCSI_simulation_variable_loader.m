clear all

modules_number = 3;

%% SPWM_Mod_Block

cfg.clk_freq = 48e6;
cfg.tri_freq = 187.5e3;
cfg.mod_number = 3;
 
cfg.sawtooth_counter = uint16(cfg.clk_freq/cfg.tri_freq - 1)

%cfg.counter_word_length = ceil(log2(cfg.sawtooth_counter));
%cfg.counter_tri_word_length = cfg.counter_word_length - 1;
cfg.counter_word_length = 8;
cfg.counter_tri_word_length = 8;


cfg.phase_mul_var = (uint16(cfg.sawtooth_counter/cfg.mod_number))

cfg.sawtooth_phase = [0*cfg.phase_mul_var
                      1*cfg.phase_mul_var
                      2*cfg.phase_mul_var];

cfg.tri_counter_comp = uint16(cfg.sawtooth_counter / 2 - 1)

%% Internal Parameters

cfg.ts  = 1/cfg.clk_freq
cfg.fl  = 100;
cfg.r    = 10;
cfg.c    = 3*(3e-6+0.1e-6);
cfg.l    = 1e-3;
cfg.w    = 2*pi*cfg.fl;
cfg.sharing_L = 2E-3;
cfg.main_L = 0E-3;
cfg.cs_soft_start_time = 1E-3;

cfg.tri_phase_shift = 360/modules_number;

%% Controlled values

cfg.mf   = cfg.tri_freq/cfg.fl;
cfg.ma = 0.9238;
cfg.iref = 10;

%% Switches values
cfg.switch.Ron        = 1e-3;
cfg.switch.snubber_Rs = 1e7;
cfg.switch.snubber_Cs = inf;


%% Simulation Reference

cfg.sim_ref_gain = uint8((cfg.tri_counter_comp) *cfg.ma );