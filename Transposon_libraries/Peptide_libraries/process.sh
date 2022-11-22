#!/bin/bash

# Author: Susanne Bornelöv
# Last modified: 2022-11-20

# Extract databases for env, gag and pol

cp /Users/bornel01/Software/RepeatMasker-4.1.2-Dfam-3.5/Libraries/RepeatPeps.lib .

# Do we want to include "grep Drosophila"?

cat RepeatPeps.lib | grep "_env" | grep -v _env_pol | sed -e 's/>//' | cut -d' ' -f1 > ids.txt
seqkit grep -f ids.txt RepeatPeps.lib > env.pep
makeblastdb -in env.pep -dbtype prot

cat RepeatPeps.lib | grep "_gag" | sed -e 's/>//' | cut -d' ' -f1 > ids.txt
seqkit grep -f ids.txt RepeatPeps.lib > gag.pep
makeblastdb -in gag.pep -dbtype prot

cat RepeatPeps.lib | grep "_pol" | grep -v _env_pol | sed -e 's/>//' | cut -d' ' -f1 > ids.txt
seqkit grep -f ids.txt RepeatPeps.lib > pol.pep
makeblastdb -in pol.pep -dbtype prot
