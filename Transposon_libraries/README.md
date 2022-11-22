# Transposon libraries

## EDTA

EDTA was usually run end-to-end:

```
EDTA.pl --genome ../../genome.fa --sensitive 1 --anno 1 --evaluate 1 -t 10 --overwrite 1 --force 1
```

However, some jobs with very long run-time were interrupted and/or failed, these were resumed using the following strategy:
```
EDTA_raw.pl --genome ../../genome.fa --type ltr -t 5 --overwrite 0
EDTA_raw.pl --genome ../../genome.fa --type helitron -t 10 --overwrite 0
EDTA_raw.pl --genome ../../genome.fa --type tir -t 10 --overwrite 0
EDTA.pl --genome ../../genome.fa --sensitive 1 --anno 1 --evaluate 1 -t 10 --overwrite 0 --force 1
```

Our version of EDTA crashed whenever a Penelope elements was detected. The avoid this, one of the scripts was slightly modified. This is described in `EDTA_fix`.

## Library_refinement

A set of scripts used to curate the EDTA and RepeatModeller raw transposon libraries. The master script `run_te_library.sh` will invoke all scripts in the `scripts` folder for each genome assembly. Several paths are hard-coded and reflect the data storage structure on our system, but it should give an detailed overview of all steps that we perform. The `data` folder contain additional data or scripts that are required for running the pipeline.
