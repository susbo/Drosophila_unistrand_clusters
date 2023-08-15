#!/bin/bash

# Author: Susanne Bornelöv
# Last change: 2022-11-22

# Copy raw TE libraries from EDTA and RepeatModeler
# Make sure that TE annotation is removed and that headers are unique

file=$1
path=`dirname $file`
name=`echo $file | cut -d'/' -f9-10 | sed -e 's/\//-/'`

mkdir -p $path/annotation/TE_library/fasta
mkdir -p $path/annotation/TE_library/fasta/tmp

### Input directories of EDTA and RepeatModeler2 outputs
INPUT_1="$path/annotation/EDTA/genome.fa.mod.EDTA.TElib.fa"
#INPUT_2="$path/annotation/EDTA/genome.fa.mod.EDTA.final/genome.fa.mod.RM.consensi.fa"
INPUT_2="$path/annotation/EDTA/genome.fa.mod.EDTA.final/genome.fa.mod.RM.consensi.fa.rexdb.cls.lib" # Results of TEsorter step of EDTA

### Copy the two input files removing duplicate header names
cat $INPUT_1 | sed -e 's/#/ /' | seqkit rename > $path/annotation/TE_library/fasta/tmp/00_EDTA.fa
cat $INPUT_2 | sed -e 's/#/ /' | seqkit rename > $path/annotation/TE_library/fasta/tmp/00_RepeatModeller.fa
