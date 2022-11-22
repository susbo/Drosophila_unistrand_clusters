#!/bin/bash
# Author: Susanne Bornelöv
# Last change: 2022-11-22

# Re-annotate all repeats in a consistent manner using RepeatClassifier
# This uses Dfam 3.5 and RepBase
# In general, the inclusion of RepBase reduces the number of "Unknown" significantly.

####################

### Input variables
file=$1
path=`dirname $file`
SPECIES=$1

mkdir -p $path/annotation/TE_library/classifier
cd $path/annotation/TE_library/classifier

mkdir -p EDTA
cd EDTA

rm -f $path/annotation/TE_library/classifier/EDTA/EDTA.fa
ln -s $path/annotation/TE_library/fasta/tmp/00_EDTA.fa EDTA.fa
RepeatClassifier -consensi EDTA.fa &

cd ..
mkdir -p RepeatModeller
cd RepeatModeller

rm -f $path/annotation/TE_library/classifier/RepeatModeller/RepeatModeller.fa
ln -s $path/annotation/TE_library/fasta/tmp/00_RepeatModeller.fa RepeatModeller.fa
RepeatClassifier -consensi RepeatModeller.fa &
cd ..

wait

cp EDTA/EDTA.fa.classified $path/annotation/TE_library/fasta/00_EDTA.fa
cp RepeatModeller/RepeatModeller.fa.classified $path/annotation/TE_library/fasta/00_RepeatModeller.fa
