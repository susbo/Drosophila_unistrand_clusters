#!/bin/bash

# Author: Susanne Bornelöv
# Last change: 2022-11-22

# Combine EDTA and RepeatModeler output
# Also removes unwanted repeat classes

file=$1
path=`dirname $file`
name=`echo $file | cut -d'/' -f9-10 | sed -e 's/\//-/'`

mkdir -p $path/annotation/TE_library/fasta

# Merge libraries
# Remove duplicated sequences (regardless of strand)
# Remove rRNA, snRNA, ARTEFACT, Simple_repeat hits, tRNA
cat $path/annotation/TE_library/fasta/00_EDTA.fa $path/annotation/TE_library/fasta/00_RepeatModeller.fa | seqkit rmdup -s -i | seqkit rename | seqkit grep -r -p \#rRNA -v | seqkit grep -r -p ARTEFACT -v | seqkit grep -r -p \#tRNA -v | seqkit grep -r -p \#snRNA -v | seqkit grep -r -p Simple_repeat -v > $path/annotation/TE_library/fasta/01_EDTA_RepeatModeller.fa

