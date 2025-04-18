clear all

modules_number = 3;

%% SPWM_Mod_Block

cfg.clk_freq = 48e6;
cfg.tri_freq = 187.5e3;
cfg.mod_number = 3;
 
cfg.sawtooth_counter = uint16(cfg.clk_freq/cfg.tri_freq - 2);

cfg.counter_word_length = ceil(log2(double(cfg.sawtooth_counter)));
cfg.counter_tri_word_length = cfg.counter_word_length - 1;

cfg.phase_mul_var = (uint16(cfg.sawtooth_counter/cfg.mod_number));

cfg.sawtooth_phase = [0*cfg.phase_mul_var
                      1*cfg.phase_mul_var
                      2*cfg.phase_mul_var]

cfg.tri_counter_comp = uint16(cfg.sawtooth_counter / 2 - 1)

%% Internal Parameters

cfg.ts  = 2.083333333e-8;
cfg.fl  = 100;
cfg.r    = 0.45;
cfg.c    = 3*(100E-9);%3*(3e-6+0.1e-6);
cfg.l    = 100E-6;
cfg.w    = 2*pi*cfg.fl;
cfg.sharing_L = 15E-3;
cfg.sharing_R = 14;
cfg.main_L = 0E-3;
cfg.cs_soft_start_time = 1E-5;
cfg.tri_phase_shift = 360/modules_number;

%% Controlled values

cfg.sim_ref_gain = 128; % Amplitud discreta de triangular y senoidal
cfg.mf   = (48e6/(2*cfg.sim_ref_gain))/(cfg.fl);
cfg.ma = 1; %0.9238
cfg.iref = 3;

%% Switches values
cfg.switch.Ron        = 1e-3;
cfg.switch.snubber_Rs = 1e7;
cfg.switch.snubber_Cs = inf;
