# Synteny biogenesis genes

Analysis to find the syntenic location of piRNA biogenesis genes.

Search for syntenic location of genes listed in `selected_genes.bed`. To run this pipeline, use
```
perl 01_prepare_cluster_genes.pl
```
to create `tmp/overlap.bed` (genes within 1Mb of the selected genes) and `tmp/selected_genes.txt` (up to 20 up- and down-stream genes based on the overlap file). The `tmp/selected_genes.txt` is next used to create `query.fa` with all query genes for use in the next step.

Next, use
```
. 02_blat.sh
```
to launch blat for genes in `query.fa` against all genomes. This step uses the configuration in `02_blat.template` and assumes that jobs can be submitted with slurm. The output will be stored in the `tmp/psl` folder as `ASSEMBLY.raw.psl` and `ASSEMBLY.filter.psl`, respectively.

Finally, use
```
perl make_html.pl > hits.html
```
To produce a table of all `ASSEMBLY.filter.psl` hits.
