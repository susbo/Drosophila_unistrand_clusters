#!/bin/bash
# Author: Susanne Bornelöv and Jasper van Lopik
# Last update: 2022-11-19

mkdir -p log
mkdir -p log/{copy,merge,classifier,cdhit,bowtie,env,subfamily,repeatmasker,repeatmasker2,cluster_analysis,info,teaid,hits,consensus}
WD=$(pwd)

FILES=`ls /mnt/scratchb/ghlab/sus/REFERENCE/drosophila/species/*/*/genome.fa`

for FILE in $FILES
do
	echo $FILE
	OUT=`dirname $FILE`
	SPECIES=`echo $FILE | cut -d'/' -f9-10 | sed -e 's/\//-/'`
	JOBID=0 # Main pipeline
	JOBID2=0 
	JOBIDx=0 # No need to wait; ever.

	### Make directory infrastructure
	mkdir -p $OUT/annotation/TE_library

	# Copy raw libraries and do some basic deduplication
   dep=""; if [ $JOBID != 0 ]; then dep="-d afterok:$JOBID"; fi
	JOBID=$(sbatch -n 1 -N 1 -p general --mem=8G -t 1:00:00 -J 00_copy_%j -o log/copy/$SPECIES.log -e log/copy/$SPECIES.log $dep scripts/00_copy.sh $FILE | awk '{print $NF}')

	# Add repeat annotations
   dep=""; if [ $JOBID != 0 ]; then dep="-d afterok:$JOBID"; fi
	JOBID=$(sbatch -n 2 -N 1 -p general --mem=16G -t 1-00:00:00 -J 01_classifier_%j --kill-on-invalid-dep=yes -o log/classifier/$SPECIES.log -e log/classifier/$SPECIES.log $dep scripts/01_classifier.sh $FILE | awk '{print $NF}')

	DB="00_EDTA"

	# Run RepeatMasker
   dep=""; if [ $JOBID != 0 ]; then dep="-d afterok:$JOBID"; fi
	JOBID2=$(sbatch -n 20 -N 1 -p general --mem=160G -t 3-00:00:00 -J 02_rm_%j --kill-on-invalid-dep=yes -o log/repeatmasker/$SPECIES.$DB.log -e log/repeatmasker/$SPECIES.$DB.log $dep scripts/02_repeatmasker.sh $FILE $DB | awk '{print $NF}')
   dep=""; if [ $JOBID != 0 ]; then dep="-d afterok:$JOBID2"; fi
	JOBID2=$(sbatch -n 1 -N 1 -p general --mem=8G -t 1-00:00:00 -J 02_rm2_%j --kill-on-invalid-dep=yes -o log/repeatmasker2/$SPECIES.$DB.log -e log/repeatmasker2/$SPECIES.$DB.log $dep scripts/02_repeatmasker2.sh $FILE $DB | awk '{print $NF}')

	# Combine EDTA and RepeatModeler
   dep=""; if [ $JOBID != 0 ]; then dep="-d afterok:$JOBID"; fi
	JOBID=$(sbatch -n 1 -N 1 -p general --mem=8G -t 1:00:00 -J 03_merge_%j -o log/merge/$SPECIES.log -e log/merge/$SPECIES.log $dep scripts/03_merge_anno.sh $FILE | awk '{print $NF}')

	DB="01_EDTA_RepeatModeller"

	# Run RepeatMasker
   dep=""; if [ $JOBID != 0 ]; then dep="-d afterok:$JOBID"; fi
	JOBID2=$(sbatch -n 20 -N 1 -p general --mem=160G -t 3-00:00:00 -J 02_rm_%j --kill-on-invalid-dep=yes -o log/repeatmasker/$SPECIES.$DB.log -e log/repeatmasker/$SPECIES.$DB.log $dep scripts/02_repeatmasker.sh $FILE $DB | awk '{print $NF}')
   dep=""; if [ $JOBID != 0 ]; then dep="-d afterok:$JOBID2"; fi
	JOBID2=$(sbatch -n 1 -N 1 -p general --mem=8G -t 1-00:00:00 -J 02_rm2_%j --kill-on-invalid-dep=yes -o log/repeatmasker2/$SPECIES.$DB.log -e log/repeatmasker2/$SPECIES.$DB.log $dep scripts/02_repeatmasker2.sh $FILE $DB | awk '{print $NF}')

	# Find good genomic hits
   dep=""; if [ $JOBID != 0 ]; then dep="-d afterok:$JOBID"; fi
	JOBID=$(sbatch -n 10 -N 1 -p general --mem=80G -t 8:00:00 -J 04_hits_%j --kill-on-invalid-dep=yes -o log/hits/$SPECIES.$DB.log -e log/hits/$SPECIES.$DB.log $dep scripts/04_hits.sh $FILE $DB | awk '{print $NF}')

	# Apply similarity thresholds to collapse sequences
   dep=""; if [ $JOBID != 0 ]; then dep="-d afterok:$JOBID"; fi
	JOBID=$(sbatch -n 20 -N 1 -p general --mem=160G -t 12:00:00 -J 05_cdhit_%j -o log/cdhit/$SPECIES.log -e log/cdhit/$SPECIES.log $dep scripts/05_cdhit.sh $FILE | awk '{print $NF}')

	DB="03_subset_reduced"

	# Run RepeatMasker
   dep=""; if [ $JOBID != 0 ]; then dep="-d afterok:$JOBID"; fi
	JOBID2=$(sbatch -n 20 -N 1 -p general --mem=160G -t 3-00:00:00 -J 02_rm_%j --kill-on-invalid-dep=yes -o log/repeatmasker/$SPECIES.$DB.log -e log/repeatmasker/$SPECIES.$DB.log $dep scripts/02_repeatmasker.sh $FILE $DB | awk '{print $NF}')
   dep=""; if [ $JOBID != 0 ]; then dep="-d afterok:$JOBID2"; fi
	JOBID2=$(sbatch -n 1 -N 1 -p general --mem=8G -t 1-00:00:00 -J 02_rm2_%j --kill-on-invalid-dep=yes -o log/repeatmasker2/$SPECIES.$DB.log -e log/repeatmasker2/$SPECIES.$DB.log $dep scripts/02_repeatmasker2.sh $FILE $DB | awk '{print $NF}')

	# Create bowtie indices
   dep=""; if [ $JOBID != 0 ]; then dep="-d afterok:$JOBID"; fi
	JOBIDx=$(sbatch -n 1 -N 1 -p general --mem=8G -t 8:00:00 -J 06_bowtie_%j -o log/bowtie/$SPECIES.log -e log/bowtie/$SPECIES.log $dep scripts/06_bowtie.sh $FILE | awk '{print $NF}')

	# Env analysis
   dep=""; if [ $JOBID != 0 ]; then dep="-d afterok:$JOBID"; fi
 	JOBID=$(sbatch -n 10 -N 1 -p general --mem=80G -t 8:00:00 -J 07_env_%j --kill-on-invalid-dep=yes -o log/env/$SPECIES.log -e log/env/$SPECIES.log $dep scripts/07_env.sh $FILE | awk '{print $NF}')

	# Find good genomic hits
   dep=""; if [ $JOBID != 0 ]; then dep="-d afterok:$JOBID"; fi
	JOBID=$(sbatch -n 10 -N 1 -p general --mem=80G -t 8:00:00 -J 04_hits_%j --kill-on-invalid-dep=yes -o log/hits/$SPECIES.$DB.log -e log/hits/$SPECIES.$DB.log $dep scripts/04_hits.sh $FILE $DB | awk '{print $NF}')

	# Subfamily analysis
   dep=""; if [ $JOBID != 0 ]; then dep="-d afterok:$JOBID"; fi
	JOBID=$(sbatch -n 10 -N 1 -p general --mem=80G -t 8:00:00 -J 08_subfamily_%j --kill-on-invalid-dep=yes -o log/subfamily/$SPECIES.log -e log/subfamily/$SPECIES.log $dep scripts/08_subfamily.sh $FILE | awk '{print $NF}')

	# Analysis of cluster or other hand-picked regions
   dep=""; if [ $JOBID != 0 ]; then dep="-d afterok:$JOBID"; fi
	JOBIDx=$(sbatch -n 20 -N 1 -p general --mem=8G -t 3-00:00:00 -J 09_ca_%j --kill-on-invalid-dep=yes -o log/cluster_analysis/$SPECIES.log -e log/cluster_analysis/$SPECIES.log $dep scripts/09_cluster_analysis.sh $FILE | awk '{print $NF}')

	# Make summary files
   dep=""; if [ $JOBID != 0 ]; then dep="-d afterok:$JOBID:$JOBID2"; fi
	JOBID=$(sbatch -n 1 -N 1 -p general --mem=8G -t 1:00:00 -J 10_info_%j --kill-on-invalid-dep=yes -o log/info/$SPECIES.log -e log/info/$SPECIES.log $dep scripts/10_info.sh $FILE | awk '{print $NF}')

	# Running TE-Aid
   dep=""; if [ $JOBID != 0 ]; then dep="-d afterok:$JOBID"; fi
	JOBID2=$(sbatch -n 1 -N 1 -p general --mem=8G -t 3-00:00:00 -J 11_teaid_%j --kill-on-invalid-dep=yes -o log/teaid/$SPECIES.log -e log/teaid/$SPECIES.log $dep scripts/11_teaid.sh $FILE | awk '{print $NF}')

	# Running automatic re-construction of consensus
   dep=""; if [ $JOBID != 0 ]; then dep="-d afterok:$JOBID"; fi
	JOBID=$(sbatch -n 1 -N 1 -p general --mem=8G -t 10-00:00:00 -J 12_consensus_%j --kill-on-invalid-dep=yes -o log/consensus/$SPECIES.log -e log/consensus/$SPECIES.log $dep scripts/12_consensus.sh $FILE | awk '{print $NF}')

	# Running automatic re-construction of consensus
   dep=""; if [ $JOBID != 0 ]; then dep="-d afterok:$JOBID"; fi
	JOBID=$(sbatch -n 1 -N 1 -p general --mem=8G -t 3-00:00:00 -J 13_teaid_%j --kill-on-invalid-dep=yes -o log/consensus/$SPECIES.teaid.log -e log/consensus/$SPECIES.teaid.log $dep scripts/13_teaid.sh $FILE | awk '{print $NF}')

	cd ${WD}
done
