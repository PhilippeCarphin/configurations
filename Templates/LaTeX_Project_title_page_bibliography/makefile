##### automatic target names ####

RAPPORT=main
TITLEPAGE=page_titre

TEXFILES=$(wildcard *.tex)

.PHONY: clean

# Make targets:

all: main.tex clean $(TITLEPAGE).pdf
	pdflatex main.tex && bibtex main && pdflatex main.tex && pdflatex main.tex

$(TITLEPAGE).pdf:$(TITLEPAGE).tex
	pdflatex $^

vars:
	@echo "FILES = $(FILES)"

#### Cleanup ####
# Je sais que c'est laid, mais rm *.log marchait pas avec make sur windows.
clean:
	rm -f $(TEXFILES:.tex=.log) $(TEXFILES:.tex=.aux) $(TEXFILES:.tex=.pdf) $(TEXFILES:.tex=_latexmk) $(TEXFILES:.tex=.syntex.gz) $(TEXFILES:.tex=.toc) $(TEXFILES:.tex=.bbl) $(TEXFILES:.tex=.blg)

#####                    EOF                   #####

