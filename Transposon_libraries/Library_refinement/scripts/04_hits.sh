#!/bin/bash

# Author: Susanne Bornelöv
# Last change: 2022-11-22

# Calculate good genomic hits to guide deduplication using cd-hit-est
# The params to calculate genomic hits are inspired by https://github.com/annaprotasio/TE_ManAnnot

file=$1
path=`dirname $file`
name=`echo $file | cut -d'/' -f9-10 | sed -e 's/\//-/'`

db=$2

# Go to folder
mkdir -p $path/annotation/TE_library/hits
cd $path/annotation/TE_library/hits

mkdir -p $db
cd $db

blastn -query ../../fasta/$db.fa -db $path/blast/genome.fa -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen" -out blast_hits.o
cat blast_hits.o | awk '{OFS="\t"; if ($3 >= 80 && (($4/$13) > 0.5 )) {print $0,$4/$13}}' > blast_hits.filtered.o
cat blast_hits.filtered.o | cut -f1 | sort | uniq -c | awk -v OFS="\t" '{print $1,$2}' > blast_hits.filtered.summary
