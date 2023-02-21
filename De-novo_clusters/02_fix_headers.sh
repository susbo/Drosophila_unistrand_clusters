#!/bin/bash
# EDTA will cut chromosomes longer than a fixed length. Here we restore the chromosome names.

# Author: Susanne Bornelöv
# Last edited: 2023-02-21 (documentation and comments)

mkdir -p scratch/02_fix_header

genomes=`ls -d /mnt/scratchb/ghlab/sus/REFERENCE/drosophila/species/*/*`

for genome in $genomes
do
   echo GENOME: $genome

   species=`echo $genome | cut -d'/' -f9`
   build=`echo $genome | cut -d'/' -f10`

   if [ ! -e "$genome/annotation/EDTA/genome.fa.mod.EDTA.anno/genome.fa.mod.out" ]; then
      echo Input file missing for $genome
      continue;
   fi

   mkdir -p scratch/02_fix_header
   cat $genome/annotation/EDTA/genome.fa.mod.EDTA.anno/genome.fa.mod.out > scratch/02_fix_header/$species.$build.out

   # Ugly, but replaces headers that EDTA shortened
   cat $genome/annotation/EDTA/genome.fa | grep "^>" | sed -e 's/>//' | cut -d' ' -f1 > headers1.txt
   cat $genome/annotation/EDTA/genome.fa.mod | grep "^>" | sed -e 's/>//' | cut -d' ' -f1 > headers2.txt
   paste headers1.txt headers2.txt > headers.txt
   perl scripts/fixHeaders.pl scratch/02_fix_header/$species.$build.out headers.txt
done
