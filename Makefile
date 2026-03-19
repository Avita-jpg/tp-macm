GHDL = ghdl
GHDL_FLAGS = --ieee=synopsys -fexplicit

SRC_DIR = MACM-main
TB_DIR = banc_de_tests

# Default testbench and generated waveform file
TB = test_fetch
WAVE = $(TB).ghw

# Default design sources in dependency order
# (override with: make SRC='MACM-main/file1.vhd MACM-main/file2.vhd')
SRC = $(SRC_DIR)/reg_bank.vhd $(SRC_DIR)/combi.vhd $(SRC_DIR)/mem.vhd $(SRC_DIR)/etages.vhd
TB_FILE = $(TB_DIR)/$(TB).vhd

.PHONY: all analyze elaborate run wave clean

all: run

analyze:
	$(GHDL) -a $(GHDL_FLAGS) $(SRC) $(TB_FILE)

elaborate: analyze
	$(GHDL) -e $(GHDL_FLAGS) $(TB)

run: elaborate
	$(GHDL) -r $(GHDL_FLAGS) $(TB) --wave=$(WAVE) || true

wave: run
	gtkwave $(WAVE)

clean:
	rm -f *.cf *.ghw *.o
