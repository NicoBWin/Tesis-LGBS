clear

% Recordar que si tri_freq < 160KHz entonces hay que arreglar el tamanio
% de la palabra a la salida del primer contador.

cfg.clk_freq = 48e6; %Es 48MHz
cfg.tri_freq = 250e3;
cfg.mod_number = 3;

cfg.sawtooth_counter = cfg.clk_freq/cfg.tri_freq - 1;

cfg.phase_mul_var = (uint16(cfg.sawtooth_counter/cfg.mod_number));

cfg.sawtooth_phase = [0*cfg.phase_mul_var
                      1*cfg.phase_mul_var
                      2*cfg.phase_mul_var];

cfg.tri_counter_comp = uint16(cfg.sawtooth_counter / 2 - 1)

%% TODO