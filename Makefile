#!gmake -f

define [DOCUMENTATION](http://daringfireball.net/projects/markdown/)

#DESCRIPTION

  This file creates a vimball of the .vim personalization files specified in
  the files.txt file.  Assumes GNU make 3.8.1 and a GNU tar 2.8.3 or later.

#INSTRUCTIONS

  Use make with one of the following phony targets

  - *vimball* creates the vimball for installation

  - *update* fetches updates from GitHub. Assumes you have a git repository
    and git installed.

  - *fetch* copies your personal changes from your installation to this
    directory. You may then add, commit and submit a merge request to me for
    consideration/inclusion. Please describe what your changes accomplish and
    why they are important to you. Or just keep them in your own special branch.

endef

.PHONY: default help vimball update fetch

# Useful scripts
# $(call Find_executable,PROGRAM_NAME) expands to full path of the executable if found; otherwise, empty
Find_executable:=$(firstword $(wildcard $(foreach pgm,$1,$(addsuffix /${pgm},$(subst :, ,${PATH})))))

# Variables
SC_FILES := sc_files.txt
HERE     := $(shell pwd)
DATE     := $(shell date +%Y%m%d)
SC_BALL  := $(HERE)/dcblack_sc-$(DATE).vmb
# Following works on both MacOS X and Linux
VIM_BIN  := $(firstword $(wildcard /Applications/MacVim.app/Contents/MacOS/Vim $(call Find_executable,PROGRAM_NAME)))
MAKEFILE_RULES := $(realpath $(lastword $(MAKEFILE_LIST)))

# Shortcuts

default: help

vimball: $(SC_BALL)

# The rules

help:
	@perl -ne 'if(m{^define..DOCUMENTATION.}..m{endef}){print if !m{DOCUMENTATION} and !m/endef/;}' ${MAKEFILE_RULES}

ORIG:=$(wildcard \
	 $(addprefix ${HOME}/.vim/,$(strip\
	   $(shell cat sc_files.txt)\
      )))

fetch:
	for f in ${ORIG}; do d=$$(echo $$f | perl -pe 's{.*vim/}{};s{/.*}{};');rsync -auvP $$f $$d/; done

update:
	git pull

doc/README_sc.html: README.md
	markdown --html4tags $? >$@

$(SC_FILES): $(shell grep -v '#' $(SC_FILES)) Makefile
	touch $@

$(SC_BALL): $(SC_FILES)
	$(VIM_BIN) -c "let g:vimball_home='.'" -c '%MkVimball! $@' -c quit $<
	@echo "Created $@"

# The end
