#!/bin/bash
# Map TEs to described subfamilies

# Author: Susanne Bornelöv
# Last update: 2022-11-21

file=$1
path=`dirname $file`
name=`echo $file | cut -d'/' -f9-10 | sed -e 's/\//-/'`

# Go to folder
mkdir -p $path/annotation/TE_library/subfamily
cd $path/annotation/TE_library/subfamily

source /Users/bornel01/.bashrc

conda activate full_blast
full_blast -q ../fasta/03_subset_reduced.fa -s /mnt/scratchb/ghlab/sus/resources/bergmanlab-transposons/transposons/current/blastdb/transposons.fa -p megablast -o 80-80-80 -i 80 -qc 80 -l 80 -t 10
full_blast -q ../fasta/03_subset_reduced.fa -s /mnt/scratchb/ghlab/sus/resources/bergmanlab-transposons/transposons/current/blastdb/transposons.fa -p megablast -o 90-80-90 -i 90 -qc 90 -l 80 -t 10
full_blast -q ../fasta/03_subset_reduced.fa -s /mnt/scratchb/ghlab/sus/resources/bergmanlab-transposons/transposons/current/blastdb/transposons.fa -p megablast -o 95-80-98 -i 95 -qc 98 -l 80 -t 10
conda deactivate

cat $path/annotation/TE_library/subfamily/95-80-98/03_subset_reduced_transposons.megablast.SignificantHits_95.0percIDN_98.0percQuerycov_min80bpHitLen.txt | cut -f1,2 | uniq | awk -v OFS="" '{print $1,"\t",$1," ",$2}' > $path/annotation/TE_library/subfamily/ids_stringent_95.txt
cat $path/annotation/TE_library/subfamily/90-80-90/03_subset_reduced_transposons.megablast.SignificantHits_90.0percIDN_90.0percQuerycov_min80bpHitLen.txt | cut -f1,2 | uniq | awk -v OFS="" '{print $1,"\t",$1," ",$2}' > $path/annotation/TE_library/subfamily/ids_stringent_90.txt
cat $path/annotation/TE_library/subfamily/80-80-80/03_subset_reduced_transposons.megablast.SignificantHits_80.0percIDN_80.0percQuerycov_min80bpHitLen.txt | cut -f1,2 | uniq | awk -v OFS="" '{print $1,"\t",$1," ",$2}' > $path/annotation/TE_library/subfamily/ids_stringent_80.txt

seqkit replace -p "^([\w#/-]+)" -r '{kv}' -k ids_stringent_90.txt --keep-key ../fasta/03_subset_reduced.fa > ../fasta/04_family_stringent.fa
