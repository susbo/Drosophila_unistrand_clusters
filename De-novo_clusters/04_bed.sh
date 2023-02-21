#!/bin/bash
# Convert the tab-separated format to bed format (this will allow using bedtools!)

# Author: Susanne Bornelöv
# Last edited: 2023-02-21 (documentation and comments)

mkdir -p scratch/04_bed/{plus,minus}
mkdir -p scratch/04_bed/{plus,minus}/merged

genomes=`ls -d /mnt/scratchb/ghlab/sus/REFERENCE/drosophila/species/*/*`

for genome in $genomes
do
   echo GENOME: $genome

   species=`echo $genome | cut -d'/' -f9`
   build=`echo $genome | cut -d'/' -f10`

	# Remove "Unknown" repeats that may be repeat genes (e.g., Hist*)
	scripts/toBed6+10.pl scratch/03_tab/plus/$species.$build.tab | LC_COLLATE=C sort -k1,1 -k2,2n | awk -v OFS="\t" '$12!="Unknown"' > scratch/04_bed/plus/$species.$build.bed
	scripts/toBed6+10.pl scratch/03_tab/minus/$species.$build.tab | LC_COLLATE=C sort -k1,1 -k2,2n | awk -v OFS="\t" '$12!="Unknown"' > scratch/04_bed/minus/$species.$build.bed

	bedtools merge -i scratch/04_bed/plus/$species.$build.bed > scratch/04_bed/plus/merged/$species.$build.bed
	bedtools merge -i scratch/04_bed/minus/$species.$build.bed > scratch/04_bed/minus/merged/$species.$build.bed
done
