#!/bin/bash

# Author: Susanne Bornelöv
# Last change: 2022-11-21

# Run TE-Aid on each repeat model to allow manual inspection

file=$1
path=`dirname $file`
name=`echo $file | cut -d'/' -f9-10 | sed -e 's/\//-/'`

# Go to folder
mkdir -p $path/annotation/TE_library/teaid
cd $path/annotation/TE_library/teaid

samtools faidx ../fasta/03_subset_reduced.fa

source ~/.bash_profile
conda activate R

mkdir -p fastas
mkdir -p out

seqkit seq -m 2000 ../fasta/03_subset_reduced.fa -o selected_ids.fa

# Split into individual fastas
cat selected_ids.fa | awk -F ' ' '/^>/ {H=$1; gsub("/","-",H); gsub(">","",H); F = "fastas/"H".fa"; print > F; next;} {print >> F; close(F)}'

files=`ls fastas/*.fa`
for file in $files
do
	TE-Aid -q $file -g $path/genome.fa -o out
done

conda deactivate
