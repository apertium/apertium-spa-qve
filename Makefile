#hfst-expand-equivalences -a ...acx -i input.hfst -o output.hfst should work

LANG1=spa
LANG2=qve
BASENAME=apertium-spa-qve
PREFIX1=spa-qve
PREFIX2=qve-spa

all: $(PREFIX2).automorf.hfst $(PREFIX1).autogen.hfst $(PREFIX2).rlx.bin $(PREFIX2).autobil.bin $(PREFIX2).mode \
	$(PREFIX2).t1x.bin $(PREFIX2).t2x.bin $(PREFIX2).t3x.bin $(PREFIX2).autogen.bin $(PREFIX1).automorf.bin \
	$(PREFIX2).autopgen.bin $(PREFIX2).lrx.bin

debug: .deps/$(LANG2).LR-debug.hfst

.deps/$(LANG2).LR-debug.hfst: $(BASENAME).$(LANG2).lexc .deps/$(LANG2).twol.hfst
	if [ ! -d .deps ]; then mkdir .deps; fi
	cat $< | grep -v 'Dir/RL' | grep -v 'Use/Circ' > .deps/$(LANG2).LR-debug.lexc
	hfst-lexc --format foma .deps/$(LANG2).LR-debug.lexc -o .deps/$(LANG2).LR-debug.lexc.hfst
	hfst-compose-intersect -1 .deps/$(LANG2).LR-debug.lexc.hfst -2 .deps/$(LANG2).twol.hfst -o $@

.deps/$(LANG2).twol.hfst: $(BASENAME).$(LANG2).twol
	if [ ! -d .deps ]; then mkdir .deps; fi
	hfst-twolc $< -o $@

.deps/$(LANG2).lexc.hfst: $(BASENAME).$(LANG2).lexc
	if [ ! -d .deps ]; then mkdir .deps; fi
	hfst-lexc --format foma $< -o $@

.deps/$(LANG2).hfst: .deps/$(LANG2).lexc.hfst .deps/$(LANG2).twol.hfst
	if [ ! -d .deps ]; then mkdir .deps; fi
	hfst-compose-intersect -1 .deps/$(LANG2).lexc.hfst -2 .deps/$(LANG2).twol.hfst -o $@

$(PREFIX1).autogen.hfst: .deps/$(LANG2).hfst
	if [ ! -d .deps ]; then mkdir .deps; fi
	hfst-fst2fst -O $< -o $@

$(PREFIX2).automorf.hfst: .deps/$(LANG2).hfst
	if [ ! -d .deps ]; then mkdir .deps; fi
	hfst-invert $< | hfst-fst2fst -O -o $@

$(PREFIX2).autobil.bin: $(BASENAME).$(PREFIX1).dix
	apertium-validate-dictionary $<
	lt-comp lr $< $@

$(PREFIX2).rlx.bin: $(BASENAME).$(PREFIX2).rlx
	cg-comp $< $@

$(PREFIX2).t1x.bin: $(BASENAME).$(PREFIX2).t1x
	apertium-validate-transfer $<
	apertium-preprocess-transfer $< $@

$(PREFIX2).t2x.bin: $(BASENAME).$(PREFIX2).t2x
	apertium-validate-interchunk $<
	apertium-preprocess-transfer $< $@

$(PREFIX2).t3x.bin: $(BASENAME).$(PREFIX2).t3x
	apertium-validate-postchunk $<
	apertium-preprocess-transfer $< $@

$(PREFIX2).autogen.bin: $(BASENAME).$(LANG1).dix
	apertium-validate-dictionary $<
	lt-comp rl $< $@

$(PREFIX1).automorf.bin: $(BASENAME).$(LANG1).dix
	apertium-validate-dictionary $<
	lt-comp lr $< $@

$(PREFIX2).autopgen.bin: $(BASENAME).post-$(LANG1).dix
	apertium-validate-dictionary $<
	lt-comp lr $< $@

$(PREFIX2).lrx.bin: $(BASENAME).$(PREFIX2).lrx
	lrx-comp $< $@

$(PREFIX2).mode: modes.xml
	apertium-validate-modes $<
	apertium-gen-modes $<
	cp *.mode modes/
