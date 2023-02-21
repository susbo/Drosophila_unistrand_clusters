#!/bin/bash
# Convert tab-separated files to bed, but keep only LTR transposons

# Author: Susanne Bornelöv
# Last edited: 2023-02-21 (documentation and comments)

mkdir -p scratch/06_bed_LTR-only/{plus,minus}
mkdir -p scratch/06_bed_LTR-only/{plus,minus}/merged

genomes=`ls -d /mnt/scratchb/ghlab/sus/REFERENCE/drosophila/species/*/*`

for genome in $genomes
do
   echo GENOME: $genome

   species=`echo $genome | cut -d'/' -f9`
   build=`echo $genome | cut -d'/' -f10`

	# Remove "Unknown" repeats that may be repeat genes (e.g., Hist*)
	scripts/toBed6+10.pl scratch/03_tab/plus/$species.$build.tab | LC_COLLATE=C sort -k1,1 -k2,2n | awk -v OFS="\t" '$12=="LTR"' > scratch/06_bed_LTR-only/plus/$species.$build.bed
	scripts/toBed6+10.pl scratch/03_tab/minus/$species.$build.tab | LC_COLLATE=C sort -k1,1 -k2,2n | awk -v OFS="\t" '$12=="LTR"' > scratch/06_bed_LTR-only/minus/$species.$build.bed

	bedtools merge -i scratch/06_bed_LTR-only/plus/$species.$build.bed > scratch/06_bed_LTR-only/plus/merged/$species.$build.bed
	bedtools merge -i scratch/06_bed_LTR-only/minus/$species.$build.bed > scratch/06_bed_LTR-only/minus/merged/$species.$build.bed
done
