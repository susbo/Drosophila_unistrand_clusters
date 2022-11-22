#!/bin/bash
# Create bowtie indices for use with sRNA-seq analysis
# Author: Susanne Bornelöv
# Last change: 2022-11-22

file=$1
path=`dirname $file`
name=`echo $file | cut -d'/' -f9-10 | sed -e 's/\//-/'`

# Go to folder
mkdir -p $path/annotation/TE_library/bowtie
cd $path/annotation/TE_library/bowtie

ln -s $path/annotation/TE_library/fasta/03_subset_reduced.fa library.fa
bowtie-build library.fa library
samtools faidx library.fa

bedtools makewindows -w 1 -s 1 -g $path/annotation/TE_library/bowtie/library.fa.fai > $path/annotation/TE_library/bowtie/windows.bed
