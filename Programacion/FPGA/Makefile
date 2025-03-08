# Set up the enviroment(Download from https://github.com/YosysHQ/oss-cad-suite-build)
# On windows start.bat
# make.exe should be on PATH
# To verbose make all QUIET=
ifeq ($(OS),Windows_NT)
    uname_S := Windows
else
    uname_S := $(shell uname -s)
endif

ifeq ($(uname_S), Windows)	
    APIOPKGFOLDER = $(USERPROFILE)\.apio
	OSSCAD_LIB_IVL = "$(APIOPKGFOLDER)\packages\tools-oss-cad-suite\lib\ivl"
	OSSCAD_ICE40_PREDEFMODULES = "$(APIOPKGFOLDER)\packages\tools-oss-cad-suite\share\yosys\ice40\cells_sim.v"
endif

ifeq ($(uname_S), Linux)
    APIOPKGFOLDER = $${HOME}/.apio
	# Direccion a la carpeta .apio (usualmente en la carpeta del usuario)
	OSSCAD_LIB_IVL = "$(APIOPKGFOLDER)/packages/tools-oss-cad-suite/lib/ivl"
	OSSCAD_ICE40_PREDEFMODULES = "$(APIOPKGFOLDER)/packages/tools-oss-cad-suite/share/yosys/ice40/cells_sim.v"
endif

ifeq ($(uname_S), Darwin)
	APIOPKGFOLDER = $${HOME}/.apio	# Direccion a la carpeta .apio (usualmente en la carpeta del usuario)
	OSSCAD_LIB_IVL = "$(APIOPKGFOLDER)/packages/tools-oss-cad-suite/lib/ivl"
	OSSCAD_ICE40_PREDEFMODULES = "$(APIOPKGFOLDER)/packages/tools-oss-cad-suite/share/yosys/ice40/cells_sim.v"
endif

LIB_SRC = ./src/SPI/SPI_request_data.v ./src/PRAM/PRAM.v ./src/timer/timer.v ./src/SPI/SPI_Master.v ./src/SPI/SPI_Master_With_Single_CS.v ./src/utils/hamming_decoder.v ./src/utils/hamming_encoder.v ./src/ADC/ADC.v ./src/utils/clk_divider.v ./src/utils/up_counter.v ./src/utils/shift_register.v ./src/UART/uart_tx.v ./src/UART/uart_rx.v 
SOURCES = ./tops/top_main_FPGA.v $(LIB_SRC)
TBNAME = pram_tb
MODULE_TO_DRAW = top_main_FPGA.v
SOURCES_TB = ./testbenchs/pram_tb.v $(LIB_SRC)
PCF = upduino.pcf
#QUIET = -q

IVERILOG = apio raw 'iverilog
YOSYS = apio raw 'yosys
ICE40 = apio raw 'nextpnr-ice40
ICEPROG = apio raw 'iceprog
ICEPACK = apio raw 'icepack
ICETIME = apio raw 'icetime
VVP = apio raw 'vvp

ifdef ComSpec
    RM=del /F /Q
	CP=copy
else
    RM=rm -f
	CP=cp
endif

all: hardware.bin

hardware.json: $(SOURCES) ./src/config/config.vh
#	yosys -p "synth_ice40 -dsp -json hardware.json -abc9 -device u" C $(SOURCES)
	$(YOSYS) -p "synth_ice40 -dsp -json hardware.json -top top" $(QUIET) $(SOURCES)'

hardware.asc: $(PCF) hardware.json
	$(ICE40) --up5k --package sg48 --json hardware.json --asc hardware.asc --pcf $(PCF) --freq 24 $(QUIET)'

hardware.bin: hardware.asc
	$(ICEPACK) hardware.asc hardware.bin'

time: hardware.asc
	$(ICETIME) -d up5k -P sg48 -t hardware.asc'

prog: hardware.bin
	$(ICEPROG) -d i:0x0403:0x6014 hardware.bin'

sim: $(SOURCES_TB) $(SOURCES_LIB)
	$(IVERILOG) -B $(OSSCAD_LIB_IVL) -o $(TBNAME).out -D VCD_OUTPUT=$(TBNAME) -D NO_ICE40_DEFAULT_ASSIGNMENTS $(OSSCAD_ICE40_PREDEFMODULES) $(SOURCES_TB)'
	$(VVP) $(TBNAME).out'

show: $(MODULE_TO_DRAW)
	$(YOSYS) -p "prep; write_json output.json" $(MODULE_TO_DRAW)'
	netlistsvg output.json -o hardware.svg

verify:
	$(IVERILOG) -B $(OSSCAD_LIB_IVL) -o hardware.out -D VCD_OUTPUT= -D NO_ICE40_DEFAULT_ASSIGNMENTS $(OSSCAD_ICE40_PREDEFMODULES) $(SOURCES)'

clean:
	$(RM) hardware.json hardware.asc hardware.bin abc.history *.out *.vcd
