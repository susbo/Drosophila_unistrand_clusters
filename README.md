# *Drosophila* unistrand piRNA clusters
Code used in (van Lopik et al., 2023) to analyse *flamenco* conservation and *flamenco*-like unistrand clusters across *Drosophila* species.

## Overview

### Analyses

* [Genome_assemblies](https://github.com/susbo/Uni-strand_clusters/tree/main/Genome_assemblies) - Scripts to download and process all 193 genome assemblies used in this study.
* [Transposon_libraries](https://github.com/susbo/Uni-strand_clusters/tree/main/Transposon_libraries) - Scripts/instructions to generate EDTA transposon libraries as well as curated ones.
* [De-novo_clusters](https://github.com/susbo/Uni-strand_clusters/tree/main/De-novo_clusters) - Scripts to calculate genome-wide LTR and transposons content, respectively. This enables detection of unistrand clusters based on transposon coverage.
* Synteny visualisation - Scripts to produce macro-/microsynteny plots using MCScan. These are currently available at [https://github.com/marianna-trapotsi/MCScan_plot](https://github.com/marianna-trapotsi/MCScan_plot).
* [Synteny_biogenesis_genes](https://github.com/susbo/Uni-strand_clusters/tree/main/Synteny_biogenesis_genes) - Scripts to find syntenic locations of genes relevant for somatic piRNA biogenesis.

Please do not hesitate to reach out if you are missing information about any particular analysis step used in the paper and we will add it here if possible.

### Version

The current version is 0.1. For other the versions, see the [releases on this repository](https://github.com/susbo/Uni-stand_clusters/releases). 

### Authors

* **Susanne Bornelöv** - [susbo](https://github.com/susbo)
* **Jasper van Lopik** - [Jvanlopik](https://github.com/JvanLopik)

### License

This project is licensed under the  GNU GPLv3 License - see the [LICENSE](LICENSE) file for details.

### Citation

If you use these scripts and pipelines, please cite our preprint:<br />
**Unistrand piRNA clusters are an evolutionarily conserved mechanism to suppress endogenous retroviruses across the Drosophila genus** <br />
Jasper van Lopik, Azad Alizada, Maria-Anna Trapotsi, Gregory J. Hannon, Susanne Bornelöv, Benjamin Czech Nicholson <br />
*bioRxiv* 2023.02.27.530199; doi: [https://doi.org/10.1101/2023.02.27.530199](https://doi.org/10.1101/2023.02.27.530199)
