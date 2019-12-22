##### automatic target names ####
tex_dir = ./tex
output_dir = ./output

PDFLATEX_FLAGS = --output-directory=$(output_dir) --halt-on-error \
		 --file-line-error

DOCUMENT=LaTeX_Document

.PHONY: clean 

# Make targets:

all: $(output_dir)/$(DOCUMENT).pdf

$(output_dir)/%.pdf:$(tex_dir)/%.tex
	pdflatex $(PDFLATEX_FLAGS) $<

#### Cleanup ####
clean: 
	$(RM) $(output_dir)/*.log 
	$(RM) $(output_dir)/*.aux 
	$(RM) $(output_dir)/*.pdf 
	$(RM) $(output_dir)/*_latexmk 
	$(RM) $(output_dir)/*.syntex.gz
