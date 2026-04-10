GHDL = ghdl
GHDL_FLAGS = --ieee=synopsys -fexplicit

.DEFAULT_GOAL := run

SRC_DIR = MACM-main
TB_DIR = banc_de_tests

# Auto-detect all testbenches
TESTBENCHES = $(patsubst $(TB_DIR)/%.vhd,%,$(wildcard $(TB_DIR)/test_*.vhd))

# Default testbench and generated waveform file
TB ?= test_pipeline_complet
WAVE_DIR = waves
WAVE = $(WAVE_DIR)/$(TB).ghw
VIEW = $(WAVE_DIR)/$(TB).gtkw

# Core sources in dependency order
CORE_SRC = $(SRC_DIR)/reg_bank.vhd $(SRC_DIR)/combi.vhd $(SRC_DIR)/mem.vhd $(SRC_DIR)/etages.vhd $(SRC_DIR)/ctrl.vhd $(SRC_DIR)/cond.vhd $(SRC_DIR)/aleas.vhd $(SRC_DIR)/proc.vhd

# Full sources with pipeline
FULL_SRC = $(CORE_SRC) $(SRC_DIR)/pipeline.vhd

# Select sources based on testbench
ifeq ($(findstring pipeline,$(TB)),pipeline)
	SRC = $(FULL_SRC)
else
	SRC = $(CORE_SRC)
endif

TB_FILE = $(TB_DIR)/$(TB).vhd

# Generate phony targets for all testbenches
.PHONY: all analyze elaborate run wave clean help
.PHONY: $(TESTBENCHES)

help:
	@echo ""
	@echo "Available testbenches:"
	@echo "  make test_fetch                    - Test FE stage"
	@echo "  make test_decode                   - Test DE stage"
	@echo "  make test_execute                  - Test EX stage"
	@echo "  make test_memory                   - Test ME stage"
	@echo "  make test_retire                   - Test RE stage"
	@echo "  make test_ctrl                     - Test control unit"
	@echo "  make test_cond                     - Test condition unit"
	@echo "  make test_aleas                    - Test hazard unit"
	@echo "  make test_proc                     - Test dataPath (proc)"
	@echo "  make test_pipeline_complet         - Test complete pipeline"
	@echo ""
	@echo "Other targets:"
	@echo "  make wave TB=<test_name>           - Open waves/<test_name>.gtkw + .ghw if possible"
	@echo "  make clean                         - Clean generated files"
	@echo ""
	@echo "Usage examples:"
	@echo "  make test_proc                     # Run test_proc and generate waves/test_proc.ghw"
	@echo "  make wave TB=test_fetch            # Open waves/test_fetch.gtkw (or .ghw fallback)"
	@echo ""

# Define target for each testbench automatically
$(TESTBENCHES):
	@$(MAKE) TB=$@ run

all: run

analyze:
	$(GHDL) -a $(GHDL_FLAGS) $(SRC) $(TB_FILE)

elaborate: analyze
	$(GHDL) -e $(GHDL_FLAGS) $(TB)

run: elaborate
	@mkdir -p $(WAVE_DIR)
	@echo "[$(TB)] Running simulation..."
	$(GHDL) -r $(GHDL_FLAGS) $(TB) --wave=$(WAVE) --stop-time=1000ns || true
	@echo "[$(TB)] Waveform saved to $(WAVE)"

wave:
	@if [ -f "$(WAVE)" ] && [ -f "$(VIEW)" ]; then \
		echo "Opening $(WAVE) with layout $(VIEW) in GTKWave..."; \
		gtkwave "$(WAVE)" "$(VIEW)"; \
	elif [ -f "$(WAVE)" ]; then \
		echo "Opening $(WAVE) in GTKWave (no .gtkw layout found)..."; \
		gtkwave "$(WAVE)"; \
	else \
		echo "Wave not found: $(WAVE)"; \
		echo "Run: make $(TB)"; \
	fi

clean:
	rm -f *.cf *.ghw *.o work-obj*.cf $(WAVE_DIR)/*.ghw
	@echo "Cleaned generated files"
