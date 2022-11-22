#!/usr/bin/perl -w
#
use strict;

my %counts;
open IN,"../hits/01_EDTA_RepeatModeller/blast_hits.filtered.summary" or die "Cannot open infile\n";
while (my $row = <IN>) {
	chomp $row;
	my @line = split "\t",$row;
	$counts{$line[1]} = $line[0];
}
close IN;

my $max = 0;
my $maxpos = 0;
my @buffer;

open IN,"cat $ARGV[0] |" or die "Cannot open infile: $ARGV[0]\n";
while (my $row = <IN>) {
	chomp $row;
	$row =~ s/\%/\%\%/; # Replace to allow print of a string with % in it
	if ($row =~ /(\d+)nt, >(.+)\.\.\. /) {
		my ($N, $name) = ($1, $2);
		my $score = ($counts{$name}//0+0.0001)*($N);
		if ($score > $max) {
			$max = $score;
			$maxpos = @buffer;
		}
		push @buffer, "$row\t\t[".($counts{$name}//0)." - $score";
	} else {
		foreach my $i (0..@buffer-1) {
			printf "$buffer[$i]";
			printf "*" if $maxpos == $i;
			printf "]\n";
		}
		$max = 0;
		$maxpos = 0;
		@buffer = ();
		printf "$row\n";
	}
}

foreach my $i (0..@buffer-1) {
	printf "$buffer[$i]";
	printf "]\n";
}

close IN;
