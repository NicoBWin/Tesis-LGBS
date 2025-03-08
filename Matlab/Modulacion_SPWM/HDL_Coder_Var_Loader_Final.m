clear

cfg.clk_freq = 48e6; %Es 48MHz
cfg.tri_freq = 187.5e3;
cfg.mod_number = 3;

cfg.sawtooth_counter = uint8(cfg.clk_freq/cfg.tri_freq - 2);

cfg.counter_word_length = ceil(log2(double(cfg.sawtooth_counter)));
cfg.counter_tri_word_length = cfg.counter_word_length - 1;

cfg.phase_mul_var = (uint16(cfg.sawtooth_counter/cfg.mod_number));

cfg.sawtooth_phase = [0*cfg.phase_mul_var
                      1*cfg.phase_mul_var
                      2*cfg.phase_mul_var];

cfg.tri_counter_comp = uint16(cfg.sawtooth_counter / 2 - 1)