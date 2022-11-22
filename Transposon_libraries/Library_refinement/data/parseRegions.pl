#!/usr/bin/perl -w
# Create a summary per TE of global TE content and TE content per cluster region
#
# Author: Susanne Bornelöv
use strict;

# Read whole genome counts per TE
my %counts;
my %bases;
open IN,"info.txt";
<IN>;
while (my $row = <IN>) {
	chomp $row;
	my @tmp = split " ",$row;
	my ($name,$count,$base) = @tmp[0,9,10]; # Name, hits, base
#	printf "name: $name, count: $count, bp: $base\n";
	$counts{"all"}{$name}=$count;
   $bases{"all"}{$name}=$base;
}
close IN;

# Read counts per TE per region
my @summaries = `ls ../cluster_analysis/*.fa.summary`;
foreach my $summary (@summaries) {
	chomp $summary;
	my $region = `basename $summary | sed -e 's/.fa.summary//'`;
	chomp $region;
	open IN,"$summary";
	my $start = 0;
	while (my $row = <IN>) {
   	if ($start == 0 && $row =~ /Repeat Stats/) {
      	$start = 1;
	      <IN>; <IN>; <IN>; <IN>; <IN>;
   	} elsif ($start == 1) {
      	if ($row =~ /------------------/) {
	         last;
   	   } else {
      	   $row =~ s/\%//;
         	$row =~ s/^ \s+ | \s+ $//x;
	         my ($name,$count,$base) = (split m/\s+/, $row)[0, 1, 2];
   	      $counts{$region}{$name}=$count;
      	   $bases{$region}{$name}=$base;
	      }
   	}
	}
	close IN;
}

# Print stuff
my @regions = sort keys %counts;
my @names = sort keys %{$counts{"all"}};

printf "Name";
foreach my $region (@regions) {
	printf "\t$region\t$region";
}
printf "\n";
foreach my $name (@names) {
	printf "$name";
	foreach my $region (@regions) {
		printf "\t".($counts{$region}{$name}//0);
		printf "\t".($bases{$region}{$name}//0);
	}
	printf "\n";
}
