buildDir := build
PREFIX := install

luaGlobals := vim,unpack,loadstring
fennelOpts := --globals $(luaGlobals) --correlate

ignoredFiles := ./Makefile
ignoreRules := $(patsubst %, -not -path %,$(ignoredFiles))

SRC := $(shell find . -type f $(ignoreRules) -not -path "$(buildDir)/*")
SRCFENNEL := $(filter %.fnl,$(SRC))
SRCOTHER := $(filter-out %.fnl,$(SRC))

OUTLUA := $(patsubst %.fnl,$(buildDir)/%.lua,$(SRCFENNEL))
OUTOTHER := $(patsubst %,$(buildDir)/%,$(SRCOTHER))

build: $(OUTLUA) $(OUTOTHER)

$(OUTLUA): $(buildDir)/%.lua: %.fnl
	@mkdir -p $(@D)
	fennel $(fennelOpts) --compile $< > $@

$(OUTOTHER): $(buildDir)/%: %
	@mkdir -p $(@D)
	cp $< $@

install: build
	@mkdir -p $(PREFIX)
	cp -r $(buildDir)/* $(PREFIX)

.PHONY: build install
