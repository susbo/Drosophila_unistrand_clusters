#!/bin/bash
# Convert the .out file to tab-separated format

# Author: Susanne Bornelöv
# Last edited: 2023-02-21 (documentation and comments)

mkdir -p scratch/03_tab/{all,plus,minus}

genomes=`ls -d /mnt/scratchb/ghlab/sus/REFERENCE/drosophila/species/*/*`

for genome in $genomes
do
   echo GENOME: $genome

   species=`echo $genome | cut -d'/' -f9`
   build=`echo $genome | cut -d'/' -f10`

   hgLoadOut -tabFile=scratch/03_tab/all/$species.$build.tab -nosplit test scratch/02_fix_header/$species.$build.out

	cat scratch/03_tab/all/$species.$build.tab | awk -v OFS="\t" '$10=="+"' > scratch/03_tab/plus/$species.$build.tab
	cat scratch/03_tab/all/$species.$build.tab | awk -v OFS="\t" '$10=="-"' > scratch/03_tab/minus/$species.$build.tab
done
