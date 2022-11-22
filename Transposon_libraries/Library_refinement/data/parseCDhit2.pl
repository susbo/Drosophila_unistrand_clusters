#!/usr/bin/perl -w
# Author: Susanne Bornelöv
# Last change: 2022-11-21
use strict;

open IN,"cat $ARGV[0] |" or die "Cannot open infile: $ARGV[0]\n";
while (my $row = <IN>) {
	chomp $row;
	$row =~ s/\%/\%\%/; # Replace to allow print of a string with % in it
	if ($row =~ /(\d+)nt, >(.+)\.\.\. /) {
		my ($N, $name) = ($1, $2);
		$row =~ /\[(\d+) [^*]+([\*]*)\]/;
		my ($count, $star) = ($1, $2);
		if ($star eq "*" && $count > 1) {
#			printf "$name\n";
			printf "$name\t$N\t$count\t$star\n";
		}
	}
}

close IN;
