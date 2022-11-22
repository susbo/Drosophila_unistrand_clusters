#!/bin/bash
# Author: Susanne Bornelöv
# Last change: 2022-11-22

file=$1
fasta=$2

path=`dirname $file`
name=`echo $file | cut -d'/' -f9-10 | sed -e 's/\//-/'`

# Go to folder
mkdir -p $path/annotation/TE_library/repeatmasker
cd $path/annotation/TE_library/repeatmasker

source /Users/bornel01/.bashrc
conda activate repeatmasker

mkdir -p $path/annotation/TE_library/repeatmasker/$fasta
cd $fasta

#cmd="RepeatMasker -s -pa 6 -lib $path/annotation/TE_library/fasta/$fasta.fa -no_is -nolow -norna -xsmall -html -gff -dir $path/annotation/TE_library/repeatmasker/$fasta $path/genome.fa"
cmd="RepeatMasker -s -pa 6 -lib $path/annotation/TE_library/fasta/$fasta.fa -a -xsmall -html -gff -dir $path/annotation/TE_library/repeatmasker/$fasta $path/genome.fa"
echo $cmd
$cmd

cd ..

conda deactivate

# -s slow
# -q quick
# -qq rush job
