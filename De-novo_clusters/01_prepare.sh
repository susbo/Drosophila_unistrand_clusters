#!/bin/bash
# Create a scratch folder for output files and make a link to it

# Author: Susanne Bornelöv
# Last edited: 2023-02-21 (documentation and comments)

folder="/mnt/scratchb/ghlab/sus/Jasper/201103_find_clusters/03_edta_clusters"

if [ ! -e "scratch" ]; then
	mkdir -p $folder
	ln -s $folder scratch
fi


