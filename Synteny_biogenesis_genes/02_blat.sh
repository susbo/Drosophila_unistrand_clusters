#!/bin/bash

mkdir -p tmp/psl
mkdir -p log

genomes=`ls /mnt/scratchb/ghlab/sus/REFERENCE/drosophila/species/*/*/genome.fa`
for genome in $genomes
do
   species=`echo $genome | cut -d'/' -f9`
   build=`echo $genome | cut -d'/' -f10`

#	if [ ! -e "tmp/psl/$species-$build.raw.psl" ]; then
		sbatch -n 1 -N 1 --mem 10G -t 1:00:00 -e log/02-$species-$build -o log/02-$species-$build 02_blat.template $species $build
#	fi
done

