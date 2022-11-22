#!/bin/bash
# Analyse repeat content in selected regions

# Author: Susanne Bornelöv
# Last change: 2022-11-22

file=$1
path=`dirname $file`
name=`echo $file | cut -d'/' -f9-10 | sed -e 's/\//-/'`

# Go to folder
mkdir -p $path/annotation/TE_library/cluster_analysis
cd $path/annotation/TE_library/cluster_analysis

# Extract species and build name
name=`echo $path | cut -d'/' -f9-10 | sed -e 's/\//-/'`
s=`echo $path | cut -d'/' -f9`
b=`echo $path | cut -d'/' -f10`

while read -r line; do
	echo LINE: $line
	chr=`echo $line | cut -d' ' -f3`
	from=`echo $line | cut -d' ' -f4`
	to=`echo $line | cut -d' ' -f5`
	name=`echo $line | cut -d' ' -f6`
	strand=`echo $line | cut -d' ' -f8`
	strand_argument=""
	if [[ $strand == "-" ]]; then strand_argument="-i"; fi
	CMD="samtools faidx $strand_argument -o $path/annotation/TE_library/cluster_analysis/$name.fa $file $chr:$from-$to"
	echo $CMD
	$CMD
done < <(cat /Users/bornel01/refs/drosophila/annotation/TE_library/data/flam_coordinates.txt | awk -v species=$s -v build=$b '$1==species && $2==build')

fastas=`ls *.fa`
for fasta in $fastas
do
	cmd="RepeatMasker -s -pa 6 -lib $path/annotation/TE_library/fasta/03_subset_reduced.fa -xsmall -html -gff -dir $path/annotation/TE_library/cluster_analysis $fasta"
	echo $cmd
	$cmd
	perl /Users/bornel01/refs/drosophila/annotation/TE_library/data/extractNestedRepeats.pl $fasta.out | sort -k1,1 -k2,2n > $fasta.nestedRepeats.bed
	perl /Users/bornel01/refs/drosophila/annotation/TE_library/data/extractAllRepeats.pl $fasta.out | sort -k1,1 -k2,2n > $fasta.allRepeats.bed
done

source /Users/bornel01/.bashrc
conda activate repeatmasker

for fasta in $fastas
do
   perl /Users/bornel01/Software/RepeatMasker-4.1.2-Dfam-3.5/util/buildSummary.pl $fasta.out > $fasta.summary
done

conda deactivate


# -s slow
# -q quick
# -qq rush job
