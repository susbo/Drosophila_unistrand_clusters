#!/bin/bash
# 
# Script to download and prepare all genome assemblies. Please note that some paths are hard-coded for our storage
# structure, but it should give a very clear idea of where every sample came from and how to access them.

# Author: Susanne Bornelöv
# Last edited: 2022-02-21

prefix="/mnt/scratchb/ghlab/sus/REFERENCE/drosophila"
mkdir -p $prefix

echo Copying git repository
if [ ! -e "$prefix/git" ]; then
	mkdir -p $prefix/git
	git clone https://github.com/danrdanny/Drosophila15GenomesProject.git $prefix/git
	rm -r $prefix/git/.git # To save space...
fi

# Please note that the D nebulosa genome was later assigned to another species.
# This species was therefore not included in the current study.
echo Downloading 101 Drosophila genomes
mkdir -p $prefix/101genomes
wget -r -l1 -nH --no-parent --cut-dirs=4 https://web.stanford.edu/~bkim331/files/genomes/ -P $prefix/101genomes
files=`ls $prefix/101genomes/*.fasta.gz`
for file in $files
do
	base=`basename $file`
	species=`basename $file | sed -e 's/.fasta.gz//'`
	order=`echo $species | awk '{print substr($1,1,1)}'`
	sub=`echo $species | cut -d'.' -f2 | awk '{print substr($1,1,3)}'`
	if [[ "$sub" == "car" || "$sub" == "tri" || "$sub" == "sub" ]]; then sub=`echo $species | cut -d'.' -f2 | awk '{print substr($1,1,4)}'`; fi
	if [[ "$sub" == "rep" ]]; then sub=`echo $species | cut -d'.' -f2 | awk -v OFS="" '{print substr($1,1,3),substr($1,7,1)}'`; fi
	if [[ "$sub" == "p" ]]; then sub=`echo $species | cut -d'.' -f2-3 | awk -v FS="." -v OFS="" '{print "psea_",substr($2,1,3)}'`; fi
	if [[ "$sub" == "sp" ]]; then sub=`echo $species | cut -d'.' -f2-3 | awk -v FS="." -v OFS="" '{print "sp_",substr($2,1,3)}'`; fi
	if [[ "$sub" == "spa" ]]; then sub=`echo $species | cut -d'.' -f2-3 | awk -v FS="." -v OFS="" '{print "sp_affcha"}'`; fi
	if [[ "$sub" == "ezo" ]]; then sub=`echo $species | cut -d'.' -f2-3 | awk -v FS="." -v OFS="" '{print "ezo_mas"}'`; fi
	if [[ "$sub" == "m" ]]; then sub=`echo $species | cut -d'.' -f2-3 | awk -v FS="." -v OFS="" '{print "mal_",substr($2,1,3)}'`; fi
	if [[ "$sub" == "tria" ]]; then sub="tri"; fi # Make compatible with old names
	if [[ "$sub" == "subo" ]]; then sub="sub"; fi # Make compatible with old names
	build="d101g"
	last=`echo $species | cut -d'.' -f3`
	if [[ $last =~ [0-9] && "$sub" != "wil" ]]; then
		build="$build""_$last"
	fi
	echo $order - $sub - $build - $species - $base
	species2="$order$sub"
	mkdir -p $prefix/species/$species2
	mkdir -p $prefix/species/$species2/$build
	if [ ! -e $prefix/species/$species2/$build/genome.fa ]; then
		zcat $file | awk '{print $1}' > $prefix/species/$species2/$build/genome.fa
	fi
done

echo Preparing reference genomes for 15 drosophila assemblies
files=`ls $prefix/git/assembledGenomes/*.gz`
for file in $files
do
	species=`basename $file | cut -d'.' -f1`
	mkdir -p $prefix/species
	mkdir -p $prefix/species/$species
	mkdir -p $prefix/species/$species/d15genomes
	if [ ! -e $prefix/species/$species/d15genomes/genome.fa ]; then
		zcat $file | sed -e 's/Consensus_Consensus_Consensus_//' | sed -e 's/_pilon_pilon_pilon//' > $prefix/species/$species/d15genomes/genome.fa
	fi
done

echo Preparing reference for NCBI assemblies
# Download genomes from annotation pipeline
mkdir -p $prefix/NCBI
wget https://www.ncbi.nlm.nih.gov/genome/annotation_euk/all/
perl download_NCBI.pl

# Download a few additional genomes
mkdir -p $prefix/NCBI2
wget -r -l1 -nH --no-parent --cut-dirs=7 -e robots=off -A "genomic.fna.gz" https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/754/195/GCF_000754195.2_ASM75419v2 -P $prefix/NCBI2/Drosophila_simulans
wget -r -l1 -nH --no-parent --cut-dirs=7 -e robots=off -A "gtf.gz" https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/754/195/GCF_000754195.2_ASM75419v2 -P $prefix/NCBI2/Drosophila_simulans
wget -r -l1 -nH --no-parent --cut-dirs=7 -e robots=off -A "genomic.fna.gz" https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/975/GCF_000005975.2_dyak_caf1 -P $prefix/NCBI2/Drosophila_yakuba
wget -r -l1 -nH --no-parent --cut-dirs=7 -e robots=off -A "gtf.gz" https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/975/GCF_000005975.2_dyak_caf1 -P $prefix/NCBI2/Drosophila_yakuba

# Download some more additional genomes with gene predictions
wget -r -l1 -nH --no-parent --cut-dirs=7 -e robots=off -A "genomic.fna.gz" https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/009/664/405/GCA_009664405.1_UCBerk_Dbif_1.0 -P $prefix/NCBI3/Drosophila_bifasciata
wget -r -l1 -nH --no-parent --cut-dirs=7 -e robots=off -A "genomic.fna.gz" https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/005/876/895/GCA_005876895.1_DaztRS1 -P $prefix/NCBI3/Drosophila_azteca
wget -r -l1 -nH --no-parent --cut-dirs=7 -e robots=off -A "genomic.fna.gz" https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/008/121/215/GCA_008121215.1_UCBerk_Dath_EB_1.0 -P $prefix/NCBI3/Drosophila_athabasca
wget -r -l1 -nH --no-parent --cut-dirs=7 -e robots=off -A "genomic.fna.gz" https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/008/121/275/GCA_008121275.1_UCBerk_Dlow_1.0 -P $prefix/NCBI3/Drosophila_lowei
wget -r -l1 -nH --no-parent --cut-dirs=7 -e robots=off -A "genomic.fna.gz" https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/005/876/975/GCA_005876975.1_DoreRS1 -P $prefix/NCBI3/Drosophila_orena
wget -r -l1 -nH --no-parent --cut-dirs=7 -e robots=off -A "genomic.fna.gz" https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/008/042/775/GCA_008042775.1_UCB_Dpec_1.0 -P $prefix/NCBI3/Drosophila_pectinifera
wget -r -l1 -nH --no-parent --cut-dirs=7 -e robots=off -A "genomic.fna.gz" https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/008/042/475/GCA_008042475.1_UCB_Dkan_1.0 -P $prefix/NCBI3/Drosophila_kanapiae
wget -r -l1 -nH --no-parent --cut-dirs=7 -e robots=off -A "genomic.fna.gz" https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/008/042/815/GCA_008042815.1_UCB_Dbun_1.0 -P $prefix/NCBI3/Drosophila_bunnanda
wget -r -l1 -nH --no-parent --cut-dirs=7 -e robots=off -A "genomic.fna.gz" https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/008/042/835/GCA_008042835.1_UCB_Dser_1.0 -P $prefix/NCBI3/Drosophila_serrata
wget -r -l1 -nH --no-parent --cut-dirs=7 -e robots=off -A "genomic.fna.gz" https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/008/042/755/GCA_008042755.1_UCB_Dbir_1.0 -P $prefix/NCBI3/Drosophila_birchii
wget -r -l1 -nH --no-parent --cut-dirs=7 -e robots=off -A "genomic.fna.gz" https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/020/883/555/GCA_020883555.1_orgogozo-p-161206-1 -P $prefix/NCBI3/Drosophila_nannoptera
wget -r -l1 -nH --no-parent --cut-dirs=7 -e robots=off -A "genomic.fna.gz" https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/020/883/565/GCA_020883565.1_orgogozo-p-171030-0 -P $prefix/NCBI3/Drosophila_pachea

ncbis=`ls $prefix/NCBI*/*/*genomic.fna.gz | grep -v rna | grep -v cds`
for ncbi in $ncbis
do
	abbr=`echo $ncbi | cut -d'/' -f9 | cut -d'_' -f2 | cut -c1-3`
	abbr="D$abbr"
	name=`echo $ncbi | cut -d'/' -f10 | cut -d'_' -f1-2 | cut -d'.' -f1`
	if [[ "$name" == "GCF_014743375" ]]; then abbr="Dsubp"; fi # Manual override
	mkdir -p $prefix/species/$abbr
	mkdir -p $prefix/species/$abbr/$name
	if [ ! -e "$prefix/species/$abbr/$name/genome.ncbi.fa" ]; then
		zcat $ncbi > $prefix/species/$abbr/$name/genome.ncbi.fa
	fi
	if [ ! -e "$prefix/species/$abbr/$name/genome.fa" ]; then
		echo $attr $name
		perl rename_chromosomes.pl $prefix/species/$abbr/$name/genome.ncbi.fa > $prefix/species/$abbr/$name/genome.fa 2> $prefix/species/$abbr/$name/chromosome_names.txt
	fi
done

echo Preparing drosophila melanogaster genomes
mkdir -p $prefix/species/Dmel
mkdir -p $prefix/species/Dmel/dm6
ln -s /mnt/scratchb/ghlab/sus/REFERENCE/dmelanogaster6/dm6.fa $prefix/species/Dmel/dm6/genome.fa

echo Preparing UCSC genomes - 211019
for genome in http://hgdownload.soe.ucsc.edu/goldenPath/droEre1/bigZips/droEre1.fa.gz http://hgdownload.soe.ucsc.edu/goldenPath/droSec1/bigZips/droSec1.fa.gz http://hgdownload.soe.ucsc.edu/goldenPath/droSim1/bigZips/droSim1.fa.gz http://hgdownload.soe.ucsc.edu/goldenPath/droYak2/bigZips/droYak2.fa.gz http://hgdownload.soe.ucsc.edu/goldenPath/droAna2/bigZips/droAna2.fa.gz http://hgdownload.soe.ucsc.edu/goldenPath/droPer1/bigZips/droPer1.fa.gz http://hgdownload.soe.ucsc.edu/goldenPath/dp3/bigZips/dp3.fa.gz http://hgdownload.soe.ucsc.edu/goldenPath/droMoj2/bigZips/droMoj2.fa.gz http://hgdownload.soe.ucsc.edu/goldenPath/droVir2/bigZips/droVir2.fa.gz http://hgdownload.soe.ucsc.edu/goldenPath/droGri1/bigZips/droGri1.fa.gz
do
   name=`echo $genome | cut -d'/' -f5`
   short=`echo $name | cut -c4-6 | tr A-Z a-z`
   short="D$short"
   if [[ "$short" == "D" ]]; then short="Dpse"; fi
   if [[ ! -e $prefix/species/$short/$name/genome.fa ]]; then
      echo $genome $name $short
      mkdir -p $prefix/species/$short/$name
      wget -O $prefix/species/$short/$name/genome.fa.gz $genome
      gunzip $prefix/species/$short/$name/genome.fa.gz
   fi
done

echo Preparing bowtie indices
genomes=`ls $prefix/species/*/*/genome.fa`
for genome in $genomes
do
	base=`dirname $genome`
	mkdir -p $base/bowtie
	if [ ! -e $base/bowtie/genome.fa.fai ]; then
   	ln -s $base/genome.fa $base/bowtie/genome.fa
      bowtie-build --threads 10 $base/bowtie/genome.fa $base/bowtie/genome
      samtools faidx $base/bowtie/genome.fa
	fi
done

echo Preparing blast indices
genomes=`ls $prefix/species/*/*/genome.fa`
for genome in $genomes
do
	base=`dirname $genome`
	mkdir -p $base/blast
	if [ ! -e $base/blast/genome.fa.fai ]; then
   	ln -s $base/genome.fa $base/blast/genome.fa
      makeblastdb -in $base/blast/genome.fa -dbtype nucl
      samtools faidx $base/blast/genome.fa
	fi
done

# We use this aligner due to the small index size
echo Preparing HiSeq2 indices
genomes=`ls $prefix/species/*/*/genome.fa`
for genome in $genomes
do
	base=`dirname $genome`
	mkdir -p $base/hisat2
	if [ ! -e $base/hisat2/genome.1.ht2 ]; then
   	ln -s $base/genome.fa $base/hisat2/genome.fa
      hisat2-build -p 10 $base/hisat2/genome.fa $base/hisat2/genome
      samtools faidx $base/hisat2/genome.fa
	fi
done

# Prepare GMAP indices to allow mapping of cDNA fasta -> gff; not currently used
echo Preparing GMAP indices
genomes=`ls $prefix/species/*/*/genome.fa`
for genome in $genomes
do
   base=`dirname $genome`
   mkdir -p $base/gmap
   if [ ! -e $base/gmap/genome/genome.genomebits128 ]; then
      gmap_build -d genome --dir $base/gmap $base/genome.fa
   fi
done

echo Prepare chrom sizes files
genomes=`ls $prefix/species/*/*/genome.fa`
for genome in $genomes
do
	base=`dirname $genome`
	if [ ! -e $base/chrom.sizes ]; then
		samtools faidx $genome
		cat $genome.fai | cut -f1-2 > $base/chrom.sizes
	fi
done

echo Prepare GTF files
gtfs=`ls $prefix/NCBI*/*/*.gtf.gz`
for gtf in $gtfs
do
	abbr=`echo $gtf | cut -d'/' -f9 | cut -d'_' -f2 | cut -c1-3`
	abbr="D$abbr"
	build=`echo $gtf | cut -d'/' -f10 | cut -d'_' -f1-2 | cut -d'.' -f1`
	if [[ "$build" == "GCF_014743375" ]]; then abbr="Dsubp"; fi # Manual override
	if [[ ! -e "$prefix/species/$abbr/$build/transcripts.gtf" ]]; then
		zcat $gtf > $prefix/species/$abbr/$build/transcripts.ncbi.gtf
		cvbio UpdateContigNames -i $prefix/species/$abbr/$build/transcripts.ncbi.gtf -o $prefix/species/$abbr/$build/transcripts.gtf -m $prefix/species/$abbr/$build/chromosome_names.txt --comment-chars '#' --columns 0 --skip-missing false
	fi
done



