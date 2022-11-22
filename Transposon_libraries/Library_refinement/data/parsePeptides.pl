#!/usr/bin/perl
# Author: Susanne Bornelöv
# Last changed: 2022-11-19
use strict;

# TE_00000127#LTR/Gypsy   Gypsy4_env#LTR/Gypsy    54.762  210     69      13      1       573     84      286     1.79e-46        153     701     487     0.299572        0.431211
# TE_00000127#LTR/Gypsy   Gypsy4_env#LTR/Gypsy    33.673  196     92      7       90      602     114     296     8.48e-13        58.9    701     487     0.279601        0.402464
# TE_00000127#LTR/Gypsy   Gypsy-7_DBi_env#LTR/Gypsy       38.800  250     135     14      1       699     16      264     5.52e-30        108     701     427     0.356633        0.58548
# TE_00000127#LTR/Gypsy   Gypsy-2_DSe_env#LTR/Gypsy       40.670  209     97      12      1       570     69      269     1.45e-28        104     701     464     0.298146        0.450431
# TE_00000127#LTR/Gypsy   Gypsy-15_DWil_env#LTR/Gypsy     38.679  212     102     10      4       579     67      270     3.64e-28        103     701     471     0.302425        0.450106

open IN,$ARGV[0];

my %lengths;
my %positions;

while (my $row = <IN>) {
	chomp $row;
	my @line = split "\t",$row;
	$lengths{$line[1]} = $line[13]; # slen
	foreach my $i ($line[8]..$line[9]) {
		$positions{$line[0]}{$line[1]}[$i] = 1;
	}
}

close IN;

foreach my $query (keys %positions) {
	foreach my $target (keys %{ $positions{$query} } ) {
		printf "$query\t$target\t$lengths{$target}\t";
		my $coverage = 0;
		foreach my $pos (0 .. @{$positions{$query}{$target}}) {
			$coverage += $positions{$query}{$target}[$pos]//0;
		}
		printf "$coverage\n";
	}
}
