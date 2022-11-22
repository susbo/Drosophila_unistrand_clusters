#!/bin/bash
# Search for hits to LTR-relevant proteins

# Author: Susanne Bornelöv
# Last change: 2022-11-20

file=$1
path=`dirname $file`
name=`echo $file | cut -d'/' -f9-10 | sed -e 's/\//-/'`

# Go to folder
mkdir -p $path/annotation/TE_library/env
cd $path/annotation/TE_library/env

blastx -query ../fasta/03_subset_reduced.fa -db /mnt/scratchb/ghlab/sus/resources/env/env.pep -num_threads 10 -max_target_seqs 100 -evalue 1e-3 -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen" > $path/annotation/TE_library/env/env.outfmt6.tmp
cat $path/annotation/TE_library/env/env.outfmt6.tmp | awk -v OFS="\t" '{print $0, $4/$13, $4/$14}' > $path/annotation/TE_library/env/env.outfmt6
perl /Users/bornel01/refs/drosophila/annotation/TE_library/data/parsePeptides.pl $path/annotation/TE_library/env/env.outfmt6 > $path/annotation/TE_library/env/env.outfmt6.summary

blastx -query ../fasta/03_subset_reduced.fa -db /mnt/scratchb/ghlab/sus/resources/env/gag.pep -num_threads 10 -max_target_seqs 100 -evalue 1e-3 -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen" > $path/annotation/TE_library/env/gag.outfmt6.tmp
cat $path/annotation/TE_library/env/gag.outfmt6.tmp | awk -v OFS="\t" '{print $0, $4/$13, $4/$14}' > $path/annotation/TE_library/env/gag.outfmt6
perl /Users/bornel01/refs/drosophila/annotation/TE_library/data/parsePeptides.pl $path/annotation/TE_library/env/gag.outfmt6 > $path/annotation/TE_library/env/gag.outfmt6.summary

blastx -query ../fasta/03_subset_reduced.fa -db /mnt/scratchb/ghlab/sus/resources/env/pol.pep -num_threads 10 -max_target_seqs 100 -evalue 1e-3 -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen" > $path/annotation/TE_library/env/pol.outfmt6.tmp
cat $path/annotation/TE_library/env/pol.outfmt6.tmp | awk -v OFS="\t" '{print $0, $4/$13, $4/$14}' > $path/annotation/TE_library/env/pol.outfmt6
perl /Users/bornel01/refs/drosophila/annotation/TE_library/data/parsePeptides.pl $path/annotation/TE_library/env/pol.outfmt6 > $path/annotation/TE_library/env/pol.outfmt6.summary

