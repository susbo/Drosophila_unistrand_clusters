#!/usr/bin/perl -w
#
use strict;

open IN,$ARGV[0];

while (my $row = <IN>) {
	if ($row =~ /^>([^\s]+) /) {
		my $name = $1;

		# Select first part in "NT_479533.1 Drosophila simulans strain w501 chromosome 2L, whole genome shotgun" (i.e., NT_479533)
		my @line = split "\\.",$name;
		my $new = $line[0];

		if ($row =~ /mitochondrion/) {
			$new = "chrM";
		} elsif ($row =~ /chromosome ([^,]+),/) {
			$new = "chr$1";
			if ($new =~ s/ map unlocalized//) {
				$new = "$new"."_$line[0]";
			}
			if ($new =~ s/Unknown/Un/) {
				$new = "$new"."_$line[0]";
			}
			if ($new =~ s/ unlocalized genomic scaffold//) {
				$new = "$new"."_$line[0]";
			}
			$new =~ s/NW_//;
		} elsif ($row =~ / ([^\s]+) genomic scaffold/) {
			$new = $1;
			$new =~ s/v2_//;
			$new =~ s/random/rand/;
		}
		if ($new eq "unplaced") {
			$new = "chrUn"."_$line[0]";
			$new =~ s/NW_//;
		}
#chromosome Unknown
		printf STDERR "$name\t$new\n";
		printf ">$new\n";
	} else {
		printf "$row";
	}
}

close IN;
