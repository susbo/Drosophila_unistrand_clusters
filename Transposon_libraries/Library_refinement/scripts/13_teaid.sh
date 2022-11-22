#!/bin/bash

# Author: Susanne Bornelöv
# Last change: 2022-11-22

# Run TE-Aid on re-constructed consensus sequences to admire improvement

file=$1
path=`dirname $file`
name=`echo $file | cut -d'/' -f9-10 | sed -e 's/\//-/'`

# Go to folder
mkdir -p $path/annotation/TE_library/consensus/teaid
cd $path/annotation/TE_library/consensus/teaid

source ~/.bash_profile
conda activate R

mkdir -p out

files=`ls ../out/*/*.cons.fa`
for file in $files
do
	name=`echo $file | cut -d'/' -f4 | sed -e 's/.cons.fa//'`
	TE-Aid -q $file -g $path/genome.fa -o out -t
	mkdir -p out/$name
	mv out/$name.*.{fasta,out,txt,pdf} out/$name
done

conda deactivate
