
HMM        ?=fungi_odb10
OUTPEPEXT  ?= aa.fa
HMMALIGN   ?= hmmalign
REFORMAT   ?= esl-reformat
TRIMAL     ?= trimal
RESOVERLAP ?= 0.70
SEQOVERLAP ?= 75
TRIMALSCHEME ?=-automated1
MRTRANS    ?= bp_mrtrans.pl
HMMFOLDER  ?= $(realpath HMM/${HMM}/HMM3)
ALNDIR     ?= $(realpath aln/${HMM})

#$(info "${HMMFOLDER} is HMMFOLDER")
#CWD := $(shell pwd)

seqs    = $(wildcard ${ALNDIR}/*.$(OUTPEPEXT))
msa     = $(seqs:.fa=.msa)
clean   = $(seqs:.fa=.clnaln)
filter  = $(seqs:.fa=.filter)
trim    = $(seqs:.fa=.trim)

all: $(msa) $(clean) $(filter) $(trim)

.PHONY: clean all

clean:
	rm -f *.msa *.clnaln *.filter *.trim

empty   :=
trailAA := .aa.fa
trailCDS:= .cds.fa

%.aa.msa : %.aa.fa
	$(eval marker=$(subst $(trailAA),$(empty),$(notdir $<)))
	${HMMALIGN} --trim --amino -o $@ ${HMMFOLDER}/${marker}.hmm $<

%.cds.msa : %.cds.fa
	$(eval ALN=$(subst $(trailCDS),$(tailAA),$<))
	${MRTRANS} -if fasta -of fasta -i $ALN -s $< -o $@

%.clnaln : %.msa
	esl-reformat --replace=x:- --gapsym=- afa $< | perl -p -e 'if (! /^>/) { s/[ZBzbXx\*]/-/g }' > $@

%.filter : %.clnaln
	trimal -resoverlap ${RESOVERLAP} -seqoverlap ${SEQOVERLAP} -in $< -out $@

%.trim : %.filter
	trimal ${TRIMALSCHEME} -fasta -in $< -out $@
