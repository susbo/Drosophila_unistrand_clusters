#!/bin/bash

# Author: Susanne Bornelöv
# Last change: 2022-11-22

# Remap repeat models back to genome, extend region, cluster, and construct consensus sequences
# This is only applied for LTR transposons of high quality
# It works really (surprisingly!) well

file=$1
path=`dirname $file`
name=`echo $file | cut -d'/' -f9-10 | sed -e 's/\//-/'`

# Go to folder
mkdir -p $path/annotation/TE_library/consensus
cd $path/annotation/TE_library/consensus

mkdir -p out

# Find hits in genome
blastn -query ../fasta/03_subset_reduced.fa -db $path/blast/genome.fa -outfmt "6 qseqid sseqid pident length mismatch qstart qend sstart send sstrand qlen" -evalue 1e-20 | awk '{OFS="\t"; if ($4 > $11/2) {print $0}}' > out.blast.o

# Convert to bed
cat out.blast.o | awk '{OFS="\t"; if ($1~/^\#/) {} else { if ($10~/plus/) {print $2, $8, $9, $1, $3, "+"} else {print $2, $9, $8, $1, $3, "-"}}}' | sort -k4,4 -k1,1 -k2,2n | uniq > out.blast.bed

# Extend regions; generally 2-5kb works well, but we found best performance with 4kb
# Main challenge are sequences with very few genomic hits
bedtools slop -s -i out.blast.bed  -g $path/chrom.sizes -b 4000 > out.blast.flank.bed

source ~/.bash_profile
conda activate cialign

TEs=`cat ../info/info.txt | awk '$6+$7+$8>=2' | awk -v OFS="" '{print $1,"#",$2}'`
for TE in $TEs
do
	outname=`echo $TE | cut -d'#' -f1` # Not needed if extracted from info.txt...
	outname="${outname}"
	mkdir -p out/$outname
	bedtools getfasta -fi $path/genome.fa -fo out/$outname/$outname.blast.bed.fa -bed <(cat out.blast.flank.bed | grep $TE) -s
	mafft --reorder --auto --thread 1 out/$outname/$outname.blast.bed.fa > out/$outname/$outname.maf.fa
	~/bin/CIAlign --infile out/$outname/$outname.maf.fa --outfile_stem out/$outname/$outname.maf.fa --crop_divergent --crop_divergent_min_prop_nongap 0.8 --crop_divergent_min_prop_ident 0.8 --remove_divergent --remove_divergent_minperc 0.3 --crop_ends --remove_insertions --insertion_max_size 1000 --remove_short --plot_input --plot_output --plot_coverage_output --plot_coverage_filetype svg --make_similarity_matrix_output --make_consensus

	# Remove flanking low-coverage regions from consensus
	blastn -query out/$outname/$outname.maf.fa_consensus.fasta -db $path/blast/genome.fa -outfmt 6 > out/$outname/out.blast.o
	perl /Users/bornel01/refs/drosophila/annotation/TE_library/data/crop_zero_coverage.pl out/$outname/out.blast.o out/$outname/$outname.maf.fa_consensus.fasta > out/$outname/$outname.cons.log

	# Repeat genome extraction - this does not appear to imrpove performance
#	blastn -query out/$outname/$outname.cons.fa -db $path/blast/genome.fa -outfmt "6 qseqid sseqid pident length mismatch qstart qend sstart send sstrand qlen" -evalue 1e-20 | awk '{OFS="\t"; if ($4 > $11/2) {print $0}}' > out/$outname/$outname.cons.blast.o
#	cat out/$outname/$outname.cons.blast.o | awk '{OFS="\t"; if ($1~/^\#/) {} else { if ($10~/plus/) {print $2, $8, $9, $1, $3, "+"} else {print $2, $9, $8, $1, $3, "-"}}}' | sort -k4,4 -k1,1 -k2,2n | uniq > out/$outname/$outname.cons.blast.bed
#	bedtools slop -s -i out/$outname/$outname.cons.blast.bed -g $path/chrom.sizes -b 4000 > out/$outname/$outname.cons.blast.flank.bed
#	bedtools getfasta -fi $path/genome.fa -fo out/$outname/$outname.cons.blast.bed.fa -bed out/$outname/$outname.cons.blast.flank.bed -s
#	mafft --reorder --auto --thread 1 out/$outname/$outname.cons.blast.bed.fa > out/$outname/$outname.cons.maf.fa
#	~/bin/CIAlign --infile out/$outname/$outname.cons.maf.fa --outfile_stem out/$outname/$outname.cons.maf.fa --crop_divergent --crop_divergent_min_prop_nongap 0.8 --crop_divergent_min_prop_ident 0.8 --remove_divergent --remove_divergent_minperc 0.3 --crop_ends --remove_insertions --insertion_max_size 1000 --remove_short --plot_input --plot_output --plot_coverage_output --plot_coverage_filetype svg --make_similarity_matrix_output --make_consensus

	# Remove zero-coverage regions from consensus
#	blastn -query out/$outname/$outname.cons.maf.fa_consensus.fasta -db $path/blast/genome.fa -outfmt 6 > out/$outname/out2.blast.o
#	perl /Users/bornel01/refs/drosophila/annotation/TE_library/data/crop_zero_coverage.pl out/$outname/out2.blast.o out/$outname/$outname.cons.maf.fa_consensus.fasta > out/$outname/$outname.cons.cons.log
done

conda deactivate

