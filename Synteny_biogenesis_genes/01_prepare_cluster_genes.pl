#!/usr/bin/perl -w
# Author: Susanne Bornelöv
# Last edited: 2021-01-12
use strict;

mkdir "tmp";

# Find overlap between gene annotations and selected genes
SystemBash("bedtools window -a <(cat /mnt/scratchb/ghlab/sus/REFERENCE/dmelanogaster6/Drosophila_melanogaster.BDGP6.28.100.ucsc-named.gtf | awk '\$3==\"gene\"') -b selected_genes.bed -w 1000000 | grep -v tRNA | grep -v miRNA | grep -v snoRNA | grep -v asRNA | grep -v sisRNA > tmp/overlap.bed");
my %selected_genes;
my %biotypes;
my %ensids;
open IN,"tmp/overlap.bed" or die "Cannot open overlap file\n";
while (my $row = <IN>) {
	chomp $row;
	my @line = split "\t",$row;
	my $posA = $line[3]+0.5*($line[4]-$line[3]);
	my $posB = $line[10]+0.5*($line[11]-$line[10]);
	my $distance = $posA-$posB;
	$row =~ /gene_id "(.+)"; gene_name "(.+)"; .+gene_biotype "(.+)";/;
	my ($ensid,$gene,$biotype) = ($1,$2,$3);
	if ($distance > 0) {
		$selected_genes{$line[12]}{"down"}{$gene} = $distance;
	} else {
		$selected_genes{$line[12]}{"up"}{$gene} = $distance;
	}
	$biotypes{$gene} = $biotype;
	$ensids{$gene} = $ensid;
}

# Print 40 closest genes into tmp/selected_genes.txt and create query.fa
SystemBash("rm query.fa");
my %processed;
open OUT,">tmp/selected_genes.txt";
foreach my $clust (keys %selected_genes) {
	foreach my $direction ("up","down") {
		my $count = 0;
		foreach my $gene (sort {abs($selected_genes{$clust}{$direction}{$a}) <=> abs($selected_genes{$clust}{$direction}{$b}) } keys %{ $selected_genes{$clust}{$direction} }) {
			printf OUT "$clust\t$gene\t$ensids{$gene}\t$biotypes{$gene}\t".($selected_genes{$clust}{$direction}{$gene})."\n";
			next if $gene eq "CG32500" || $gene eq "CG33502"; # Identitical sequences...
			last if $count++ == 20;
			if (!defined($processed{$ensids{$gene}})) {
				if ($biotypes{$gene} eq "protein_coding") {
					my @ids=`cat /mnt/scratchb/ghlab/sus/REFERENCE/dmelanogaster6/dmel-all-CDS-r6.36.fasta | grep $ensids{$gene} | cut -d' ' -f1 | sed -e 's/>//' | head -n1`;
#					printf "TEST: $ensids{$gene} - $ids[0]\n";
					if (defined($ids[0])) {
						chomp $ids[0];
						SystemBash("samtools faidx /mnt/scratchb/ghlab/sus/REFERENCE/dmelanogaster6/dmel-all-CDS-r6.36.fasta \"$ids[0]\" | sed -e 's/$ids[0]/$gene/' >> query.fa");
					}
				} else {
					my @ids=`cat /mnt/scratchb/ghlab/sus/REFERENCE/dmelanogaster6/dmel-all-gene-r6.36.fasta | grep $ensids{$gene} | cut -d' ' -f1 | sed -e 's/>//' | head -n1`;
					chomp $ids[0];
					SystemBash("samtools faidx /mnt/scratchb/ghlab/sus/REFERENCE/dmelanogaster6/dmel-all-gene-r6.36.fasta $ids[0] | sed -e 's/$ensids{$gene}/$gene/' >> query.fa");
				}
				$processed{$ensids{$gene}} = 1;
			}
		}
	}
}
close OUT;

# This function makes sure that Bash is used on Ubuntu systems.
sub SystemBash {
	my @args = ( "bash", "-c", shift );
	system(@args);
}
