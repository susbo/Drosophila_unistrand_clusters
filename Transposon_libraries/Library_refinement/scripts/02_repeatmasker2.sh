#!/bin/bash

# Author: Susanne Bornelöv
# Last change: 2022-11-22

# Run some additional analyses based on the RepeatMasker output
# This is used at several steps to compare refinement progress

file=$1
fasta=$2
path=`dirname $file`
name=`echo $file | cut -d'/' -f9-10 | sed -e 's/\//-/'`

# Go to folder
mkdir -p $path/annotation/TE_library/repeatmasker
cd $path/annotation/TE_library/repeatmasker

source /Users/bornel01/.bashrc
conda activate repeatmasker

# Extract species and build name
name=`echo $path | cut -d'/' -f9-10 | sed -e 's/\//-/'`
s=`echo $path | cut -d'/' -f9`
b=`echo $path | cut -d'/' -f10`

twobit=`ls /mnt/scratchb/ghlab/sus/Jasper/201026_all_hubs/out/$s/$b/*.2bit`

cd $fasta
perl /Users/bornel01/Software/RepeatMasker-4.1.2-Dfam-3.5/util/buildSummary.pl -genome $twobit genome.fa.out > summary.txt

perl /Users/bornel01/Software/RepeatMasker-4.1.2-Dfam-3.5/util/calcDivergenceFromAlign.pl -s genome.divsum genome.fa.cat.gz
perl /Users/bornel01/Software/RepeatMasker-4.1.2-Dfam-3.5/util/createRepeatLandscape.pl -div genome.divsum -twoBit $twobit > repeat_landscape_$name.html

# Extract nesed repeats for repeat counting; these scripts are from the RepatMasker package but has been sligthly modified
perl /Users/bornel01/refs/drosophila/annotation/TE_library/data/extractNestedRepeats.pl genome.fa.out | sort -k1,1 -k2,2n > genome.fa.nestedRepeats.bed
perl /Users/bornel01/refs/drosophila/annotation/TE_library/data/extractAllRepeats.pl genome.fa.out | sort -k1,1 -k2,2n > genome.fa.allRepeats.bed

# Save space
gzip genome.fa.masked
gzip genome.fa.out
cd ..

conda deactivate
