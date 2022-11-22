#!/bin/bash

# Author: Susanne Bornelöv
# Last change: 2022-11-22

# Combine similar sequences into clusters and select single cluster representatives
# based on the number of good genomic hits and the length.
# Currently hits and lengths have equal importance.

# We compare several clustering settings for evaluation purpose.

file=$1
path=`dirname $file`
name=`echo $file | cut -d'/' -f9-10 | sed -e 's/\//-/'`

# Go to folder
mkdir -p $path/annotation/TE_library/cdhit
cd $path/annotation/TE_library/cdhit

rm $path/annotation/TE_library/cdhit/*

cd-hit-est -i ../fasta/01_EDTA_RepeatModeller.fa -o 02_reduced_95_98.fa -G 0 -g 1 -aS 0.98 -c 0.95 -n 9 -d 0 -b 500 -M 160000 -T 20
perl /Users/bornel01/refs/drosophila/annotation/TE_library/data/parseCDhit.pl 02_reduced_95_98.fa.clstr > 02_reduced_95_98.fa.clstr.info
perl /Users/bornel01/refs/drosophila/annotation/TE_library/data/parseCDhit2.pl 02_reduced_95_98.fa.clstr.info > 02_reduced_95_98.selected_ids.txt
seqkit grep -f <(cat 02_reduced_95_98.selected_ids.txt | cut -f1) ../fasta/01_EDTA_RepeatModeller.fa -o 02_reduced_95_98.selected_ids.fa

cd-hit-est -i ../fasta/01_EDTA_RepeatModeller.fa -o 02_reduced_80_80.fa -G 0 -g 1 -aS 0.80 -c 0.80 -n 5 -d 0 -b 500 -M 160000 -T 20
perl /Users/bornel01/refs/drosophila/annotation/TE_library/data/parseCDhit.pl 02_reduced_80_80.fa.clstr > 02_reduced_80_80.fa.clstr.info
perl /Users/bornel01/refs/drosophila/annotation/TE_library/data/parseCDhit2.pl 02_reduced_80_80.fa.clstr.info > 02_reduced_80_80.selected_ids.txt
seqkit grep -f <(cat 02_reduced_80_80.selected_ids.txt | cut -f1) ../fasta/01_EDTA_RepeatModeller.fa -o 02_reduced_80_80.selected_ids.fa

cd-hit-est -i ../fasta/01_EDTA_RepeatModeller.fa -o 02_reduced_90_90.fa -G 0 -g 1 -aS 0.90 -c 0.90 -n 8 -d 0 -b 500 -M 160000 -T 20
perl /Users/bornel01/refs/drosophila/annotation/TE_library/data/parseCDhit.pl 02_reduced_90_90.fa.clstr > 02_reduced_90_90.fa.clstr.info
perl /Users/bornel01/refs/drosophila/annotation/TE_library/data/parseCDhit2.pl 02_reduced_90_90.fa.clstr.info > 02_reduced_90_90.selected_ids.txt
seqkit grep -f <(cat 02_reduced_90_90.selected_ids.txt | cut -f1) ../fasta/01_EDTA_RepeatModeller.fa -o 02_reduced_90_90.selected_ids.fa

cp 02_reduced_95_98.selected_ids.fa ../fasta/02_subset_reduced_95_98.fa
cp 02_reduced_80_80.selected_ids.fa ../fasta/02_subset_reduced_80_80.fa
cp 02_reduced_90_90.selected_ids.fa ../fasta/02_subset_reduced_90_90.fa

# Need to decide which one to use for all downstream processing!
cp 02_reduced_90_90.selected_ids.fa ../fasta/03_subset_reduced.fa
