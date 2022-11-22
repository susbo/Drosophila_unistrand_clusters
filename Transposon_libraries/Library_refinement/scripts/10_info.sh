#!/bin/bash
# Author: Susanne Bornelöv
# Last change: 2022-11-22

file=$1
path=`dirname $file`
name=`echo $file | cut -d'/' -f9-10 | sed -e 's/\//-/'`

# Go to folder
mkdir -p $path/annotation/TE_library/info
cd $path/annotation/TE_library/info

samtools faidx ../fasta/03_subset_reduced.fa

perl /Users/bornel01/refs/drosophila/annotation/TE_library/data/parseInfo.pl > info.txt
perl /Users/bornel01/refs/drosophila/annotation/TE_library/data/parseRegions.pl > info_per_region.txt
