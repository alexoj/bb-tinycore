.PHONY: all
all:
	# Do twice for TOC to get updated.
	pdflatex -halt_on_error report.tex </dev/null
	pdflatex -halt_on_error report.tex </dev/null

.PHONY: clean
clean:
	rm -f report.aux
	rm -f report.lof
	rm -f report.log
	rm -f report.lol
	rm -f report.pdf
	rm -f report.toc
