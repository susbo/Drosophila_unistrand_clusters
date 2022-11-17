# Synteny biogenesis genes

Analysis to find the syntenic location of piRNA biogenesis genes.

Search for syntenic location of genes listed in `selected_genes.bed`. To run this pipeline, use
```
perl 01_prepare_cluster_genes.pl
```
to create `tmp/overlap.bed` and `tmp/selected_genes.txt`. The first file contains other genes within 1Mb of the selected genes, and the second file contains up to 20 up- and down-stream genes based on the overlap file.

Next, use
```
. 02_blat.sh
```
to launch blat for genes in `tmp/selected_genes.txt` against all genomes. This used the configuration in `02_blat.template`. The output will be stored in the `tmp/psl` folder as `ASSEMBLY.raw.psl` and `ASSEMBLY.filter.psl`, respectively.

Finally, use
```
perl make_html.pl > hits.html
```
To produce a table of all hits.
