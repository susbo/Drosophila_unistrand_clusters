#!/bin/bash
# Prepare 100kb genomic bins and calculate (LTR) coverage within each bin

# Author: Susanne Bornelöv
# Last edited: 2023-02-21 (documentation and comments)

mkdir -p scratch/07_bins_LTR-only/{bins,overlap}
mkdir -p scratch/07_bins_LTR-only/overlap/{plus,minus}

genomes=`ls -d /mnt/scratchb/ghlab/sus/REFERENCE/drosophila/species/*/*`

for genome in $genomes
do
   echo GENOME: $genome

   species=`echo $genome | cut -d'/' -f9`
   build=`echo $genome | cut -d'/' -f10`

	# Create windows
	if [ ! -e scratch/07_bins_LTR-only/bins/$species.$build.bed.gz ]; then
	   bedtools makewindows -w 100000 -s 5000 -g $genome/genome.fa.fai | awk -v OFS="\t" '$3-$2>95000' | gzip -c > scratch/07_bins_LTR-only/bins/$species.$build.bed.gz
	fi

	bedtools coverage -a <(zcat scratch/07_bins_LTR-only/bins/$species.$build.bed.gz) -b scratch/06_bed_LTR-only/plus/merged/$species.$build.bed > scratch/07_bins_LTR-only/overlap/plus/$species.$build.bed
	bedtools coverage -a <(zcat scratch/07_bins_LTR-only/bins/$species.$build.bed.gz) -b scratch/06_bed_LTR-only/minus/merged/$species.$build.bed > scratch/07_bins_LTR-only/overlap/minus/$species.$build.bed

done
