##### automatic target names ####

RAPPORT=main
TITLEPAGE=pageTitre

.PHONY: clean

# Make targets:

all: main.tex clean $(TITLEPAGE).pdf
	pdflatex main.tex && bibtex main && pdflatex main.tex && pdflatex main.tex

%.pdf:%.tex
	pdflatex $^

#### Cleanup ####
# Je sais que c'est laid, mais rm *.log marchait pas avec make sur windows.
clean:
	rm -f $(RAPPORT).log
	rm -f $(RAPPORT).aux
	rm -f $(RAPPORT).pdf
	rm -f $(RAPPORT)_latexmk
	rm -f $(RAPPORT).syntex.gz
	rm -f $(RAPPORT).toc
	rm -f $(TITLEPAGE).log
	rm -f $(TITLEPAGE).aux
	rm -f $(TITLEPAGE)_latexmk
	rm -f $(TITLEPAGE).synctex.gz
	rm -f $(TITLEPAGE).pdf
	rm -f *.log
	rm -f *.aux *.syntex.gz
	rm -f *.bbl *.blg

#####                    EOF                   #####

