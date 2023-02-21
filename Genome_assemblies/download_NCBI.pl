#!/usr/bin/perl -w
# This script will read index.html and download all NCBI annotation genes for any species from
# the Drosophila genus.
#
# Author: Susanne Bornelöv
# Last edited: 2023-02-21

use strict;

my $prefix="/mnt/scratchb/ghlab/sus/REFERENCE/drosophila";

open IN,"index.html";
while (my $row = <IN>) {
	if ($row =~ /Taxonomy.+id=\d+">(Drosophila .+) \(flies\)</) {
		my $species = $1;
		printf "Species: $species\n";
		$species =~ s/ /_/;
		<IN>; <IN>;	<IN>; <IN>; <IN>; # Skip five rows...
		$row = <IN>;
		$row =~ /href="(.+)" class="link/;
		my $url = $1;
		printf "URL: $url\n";
		mkdir "$prefix/NCBI/$species";
		`wget -N -e robots=off -r -l3 -nH --cut-dirs=8 --no-parent -A "genomic.fna.gz" $url -P $prefix/NCBI/$species`;
		`wget -N -e robots=off -r -l3 -nH --cut-dirs=8 --no-parent -A "gtf.gz" $url -P $prefix/NCBI/$species`;
	}
}
close IN;
