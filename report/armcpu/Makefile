# $File: Makefile
# $Date: Wed Jan 29 19:26:36 2014 +0800
# $Author: jiakai <jia.kai66@gmail.com>

TARGET = report
TEX = xelatex -shell-escape
BIBTEX = bibtex
PDFDEPS = build $(addprefix build/,$(wildcard *.tex)) \
		  $(addprefix build/,$(wildcard *.bib))

all: view

build/$(TARGET).pdf: $(PDFDEPS)
	cd build && $(TEX) $(TARGET).tex && $(BIBTEX) $(TARGET).aux && \
		$(TEX) $(TARGET).tex && $(TEX) $(TARGET).tex

build/%: %
	[ -h $@ ] || ln -s ../$< build/

build:
	mkdir $@

view: build/$(TARGET).pdf
	evince build/$(TARGET).pdf

rebuild: clean build/$(TARGET).pdf

clean:
	rm -rf build

.PHONY: all view clean rebuild

# vim: ft=make

