### Makefile for compiling latex documents
###
### Adapted from:
### ransford at cs.washington.edu
### http://github.com/ransford/pdflatex-makefile
### http://www.apache.org/licenses/LICENSE-2.0
###
### Usage:
###   * Compile pdf document from LaTeX source: make
###   * Compile pdf and open in viewer: 	make view
###   * Compile pdf draft: 			make snapshot
###   * Compile pdf with embedded fonts: 	make distill
###   * Clean up:				make clean
###
### Generates a \Revision command to print the current vc revision
### in the tex document. To use \Revision, add \input{revision.tex}
### in your preamble.
###
########################################################################
##  Define your target here:
TARGET	=	project4
########################################################################
#
## Definitions
PDFLATEX	?= pdflatex -halt-on-error -file-line-error -shell-escape
BIBTEX		?= biber
MAKEGLOSSARIES ?= makeglossaries
MAKENOMENCL ?= makeindex

# String to find in log to check whether rerun is necessary
RERUN_PATTERN = Rerun to

ifneq ($(QUIET),)
PDFLATEX	+= -interaction=batchmode
ERRFILTER	:= > /dev/null || (egrep ':[[:digit:]]+:' *.log && false)
BIBTEX		+= -quiet
else
PDFLATEX	+= -interaction=nonstopmode
ERRFILTER=
endif

# Action for 'make view'
OS=$(shell uname -s)
ifeq ($(OS),Darwin)
PDFVIEWER	?= open
else
PDFVIEWER	?= evince
endif

## Name of the target file, minus .pdf: e.g., TARGET=mypaper causes this
## Makefile to turn mypaper.tex into mypaper.pdf.
TARGETS += $(TARGET)
TEXTARGETS = $(TARGETS:=.tex)
PDFTARGETS = $(TARGETS:=.pdf)
AUXFILES   = $(TARGETS:=.aux)
LOGFILES   = $(TARGETS:=.log)

## Inkscape SVG file processing:
ifeq ($(shell which inkscape >/dev/null 2>&1 && echo USING_INKSCAPE),USING_INKSCAPE)
  FIG_SVG=$(wildcard $(FIGS)/*.svg)
  FIG_PDF=$(FIG_SVG:.svg=.pdf)
else
  FIG_PDF=
endif

## If $(TARGET).tex refers to .bib files like \bibliography{foo,bar}, then
## $(BIBFILES) will contain foo.bib and bar.bib, and both files will be added as
## dependencies to $(PDFTARGETS).
## Effect: updating a .bib file will trigger re-typesetting.
BIBFILES += $(patsubst %,%.bib,\
		$(shell grep '^[^%]*\\bibliography{' $(TEXTARGETS) | \
			grep -o '\\bibliography{[^}]\+}' | \
			sed -e 's/^[^%]*\\bibliography{\([^}]*\)}.*/\1/' \
			    -e 's/, */ /g'))

BIBFILES += $(patsubst %,%.bib,\
		$(shell grep '^[^%]*\\addbibresource{' $(TEXTARGETS) | \
			grep -o '\\addbibresource{[^}]\+}' | \
			sed -e 's/^[^%]*\\addbibresource{\([^}]*\)}.*/\1/' \
			    -e 's/, */ /g'))

## Add \input'ed or \include'd files to $(PDFTARGETS) dependencies; ignore
## .tex extensions.
INCLUDEDTEX = $(patsubst %,%.tex,\
		$(shell grep '^[^%]*\\\(input\|include\){' $(TEXTARGETS) | \
			grep -o '\\\(input\|include\){[^}]\+}' | \
			sed -e 's/^.*{\([^}]*\)}.*/\1/' \
			    -e 's/\.tex$$//'))

AUXFILES += $(INCLUDEDTEX:.tex=.aux)

## grab a version number from the repository (if any) that stores this.
## * REVISION is the current revision number (short form, for inclusion in text)
## * VCSTURD is a file that gets touched after a repo update
SPACE = $(empty) $(empty)
ifeq ($(shell git status >/dev/null 2>&1 && echo USING_GIT),USING_GIT)
  ifeq ($(shell git svn info >/dev/null 2>&1 && echo USING_GIT_SVN),USING_GIT_SVN)
    # git-svn
    ifeq ($(REVISION),)
      REVISION := $(shell git svn find-rev git-svn)
    endif
    VCSTURD := $(subst $(SPACE),\ ,$(shell git rev-parse --git-dir)/refs/remotes/git-svn)
  else
    # plain git
    ifeq ($(REVISION),)
      REVISION := $(shell git describe --always HEAD)
    endif
    GIT_BRANCH := $(shell git symbolic-ref HEAD 2>/dev/null)
    VCSTURD := $(subst $(SPACE),\ ,$(shell git rev-parse --git-dir)/$(GIT_BRANCH))
  endif
else ifeq ($(shell hg root >/dev/null 2>&1 && echo USING_HG),USING_HG)
  # mercurial
  ifeq ($(REVISION),)
    REVISION := $(shell hg id -i)
  endif
  VCSTURD := $(subst $(SPACE),\ ,$(shell hg root)/.hg/dirstate)
else ifeq ($(shell svn info >/dev/null && echo USING_SVN),USING_SVN)
  # subversion
  ifeq ($(REVISION),)
    REVISION := $(subst :,-,$(shell svnversion -n))
  endif
  VCSTURD := $(addsuffix /.svn/entries, $(shell svn info | grep 'Root Path' | sed -e 's/\(.*\:\)\(.*\) /\2/'))
endif

# .PHONY names all targets that aren't filenames
.PHONY: all clean pdf view snapshot distill distclean

all: pdf $(AFTERALL)

ifeq ($(shell which inkscape >/dev/null 2>&1 && echo USING_INKSCAPE),USING_INKSCAPE)
$(FIGS)/%.pdf: $(FIGS)/%.svg  ## Figures for the manuscript
	inkscape -C -z --file=$< --export-pdf=$@ 2> /dev/null
endif

pdf: $(FIG_PDF) $(PDFTARGETS)


view: $(PDFTARGETS)
	$(PDFVIEWER) $(PDFTARGETS)

# define a \Revision{} command you can include in your document's preamble.
# especially useful with e.g. draftfooter.sty or fancyhdr.
# usage: \input{revision}
#        ... \Revision{}
ifneq ($(REVISION),)
REVDEPS += revision.tex
revision.tex: $(VCSTURD)
	/bin/echo '\newcommand{\Revision}'"{$(subst _,\_,$(REVISION))}" > $@
AUXFILES += revision.aux
endif

# to generate aux but not pdf from pdflatex, use -draftmode
%.aux: %.tex $(REVDEPS)
	$(PDFLATEX) -draftmode $* $(ERRFILTER)

# specify KEEPAUX=1 if you need to keep auxiliary (.aux) files for some other
# tool (e.g., an autocompleting text editor)
ifneq ($(KEEPAUX),1)
  .INTERMEDIATE: $(AUXFILES)
endif

# introduce BibTeX dependency if we found a \bibliography
# Temporarily commented out, because the bib deps break the initial
# compilation
#ifneq ($(strip $(BIBFILES)),)
#BIBDEPS = %.bcf
#%.bcf: %.aux $(BIBFILES)
#	$(BIBTEX) $*
#endif

# introduce makeglossaries dependency if we found \printglossary/ies
HAS_GLOSSARIES = $(shell \
		grep '^[^%]*\\printglossar\(ies\|y\)' $(TEXTARGETS) $(INCLUDEDTEX) && \
		echo HAS_GLOSSARIES)
ifneq ($(HAS_GLOSSARIES),)
GLSDEPS = %.gls
%.gls: %.aux
	$(MAKEGLOSSARIES) $(TARGETS)
endif

# introduce makenomenclature dependency if we found \printnomenclature
HAS_NOMENCL = $(shell \
		grep '^[^%]*\\printnomenclature' $(TEXTARGETS) $(INCLUDEDTEX) && \
		echo HAS_NOMENCL)
ifneq ($(HAS_NOMENCL),)
NLSDEPS = %.nls
%.nls: %.nlo
	$(MAKENOMENCL) $(TARGETS).nlo -s nomencl.ist -o $(TARGETS).nls
endif

$(PDFTARGETS): %.pdf: %.tex %.aux $(GLSDEPS) $(BIBDEPS) $(INCLUDEDTEX) $(REVDEPS) $(NLSDEPS)
	$(PDFLATEX) $* $(ERRFILTER)
ifneq ($(strip $(BIBFILES)),)
	@if egrep -q "undefined (references|citations)" $*.log; then \
		$(BIBTEX) $* && $(PDFLATEX) $* $(ERRFILTER); fi
endif
	@while grep -q "$(RERUN_PATTERN)" $*.log; do \
		$(PDFLATEX) $* $(ERRFILTER); done

DRAFTS := $(PDFTARGETS:.pdf=-$(REVISION).pdf)
$(DRAFTS): %-$(REVISION).pdf: %.pdf
	cp $< $@
snapshot: $(DRAFTS)

%.distilled.pdf: %.pdf
	gs -q -dSAFER -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=$@ \
		-dCompatibilityLevel=1.5 -dPDFSETTINGS=/prepress -c .setpdfwrite -f $<
	exiftool -overwrite_original -Title="" -Creator="" -CreatorTool="" $@

distill: $(PDFTARGETS:.pdf=.distilled.pdf)

distclean: clean
	$(RM) $(PDFTARGETS) $(PDFTARGETS:.pdf=.distilled.pdf) $(EXTRADISTCLEAN)

clean:
	$(RM) $(foreach T,$(TARGETS), \
		$(T).bbl $(T).bcf $(T).bit $(T).blg $(T).tex.blg \
		$(T)-blx.bib $(T).brf $(T).glg $(T).glo \
		$(T).gls $(T).glsdefs $(T).glx \ $(T).gxg \
		$(T).gxs $(T).idx $(T).ilg $(T).ind \
		$(T).ist $(T).loa $(T).lof $(T).lol \
		$(T).lot $(T).maf $(T).mtc $(T).nav \
		$(T).out $(T).pag $(T).run.xml $(T).snm \
		$(T).svn $(T).tdo $(T).tns $(T).toc \
		$(T).vtc $(T).url) \
		$(REVDEPS) $(AUXFILES) $(LOGFILES) \
		$(EXTRACLEAN) $(FIG_PDF)
