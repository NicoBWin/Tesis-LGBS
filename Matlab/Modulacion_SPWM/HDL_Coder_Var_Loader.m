clear

cfg.clk_freq = 40e6;
cfg.tri_freq = 250e3;
cfg.mod_number = 3;

cfg.sawtooth_counter = cfg.clk_freq/cfg.tri_freq - 1;

cfg.phase_mul_var = (uint16(cfg.sawtooth_counter/cfg.mod_number));

cfg.sawtooth_phase = [0*cfg.phase_mul_var
                      1*cfg.phase_mul_var
                      2*cfg.phase_mul_var];

cfg.tri_counter_comp = uint16(cfg.sawtooth_counter / 2 - 1);