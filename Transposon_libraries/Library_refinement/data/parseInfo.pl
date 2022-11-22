#!/usr/bin/perl -w
# Parse different information to allow downstream plotting
#
# Author: Susanne Bornelöv
# Last change: 2022-11-22
use strict;

# Get a list of all TEs and their family
open IN,"../fasta/03_subset_reduced.fa";
my %families;
while (my $row = <IN>) {
	if ($row =~ />(.+)#([^\s]+) /) {
		my ($name,$family) = ($1,$2);
		$families{$name} = $family;
	}
}

# What is their subfamily?
open IN,"../subfamily/ids_stringent_95.txt";
my %subfamilies95;
<IN>;
while (my $row = <IN>) {
	chomp $row;
	$row =~ /^(.+)#(.+)\t(.+) (.+)$/;
	my ($name,$subfamily) = ($1,$4);
	$subfamilies95{$name} = $subfamily;
}

# What is their subfamily?
open IN,"../subfamily/ids_stringent_90.txt";
my %subfamilies90;
<IN>;
while (my $row = <IN>) {
	chomp $row;
	$row =~ /^(.+)#(.+)\t(.+) (.+)$/;
	my ($name,$subfamily) = ($1,$4);
	$subfamilies90{$name} = $subfamily;
}

# What is their subfamily?
open IN,"../subfamily/ids_stringent_80.txt";
my %subfamilies90;
<IN>;
while (my $row = <IN>) {
	chomp $row;
	$row =~ /^(.+)#(.+)\t(.+) (.+)$/;
	my ($name,$subfamily) = ($1,$4);
	$subfamilies80{$name} = $subfamily;
}

# What is their length?
open IN,"../fasta/03_subset_reduced.fa.fai";
my %lengths;
while (my $row = <IN>) {
	chomp $row;
	$row =~ s/#/\t/;
	my ($name,$length) = (split "\t",$row)[0,2];
	$lengths{$name} = $length;
}

# Do they have env?
open IN,"cat ../env/env.outfmt6.summary | awk '\$4/\$3>0.5' |" or die "Cannot open env file\n";
my %env;
while (my $row = <IN>) {
	$row =~ /^([^#]+)#/;
	my ($name) = ($1);
	$env{$name}=1;
}

# Do they have gag?
open IN,"cat ../env/gag.outfmt6.summary | awk '\$4/\$3>0.5' |" or die "Cannot open gag file\n";
my %gag;
while (my $row = <IN>) {
	$row =~ /^([^#]+)#/;
	my ($name) = ($1);
	$gag{$name}=1;
}

# Do they have pol?
open IN,"cat ../env/pol.outfmt6.summary | awk '\$4/\$3>0.5' |" or die "Cannot open pol file\n";
my %pol;
while (my $row = <IN>) {
	$row =~ /^([^#]+)#/;
	my ($name) = ($1);
	$pol{$name}=1;
}

# How many genomic copies?
open IN,"../repeatmasker/03_subset_reduced/summary.txt";
my %counts;
my %coverage;
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
   		$counts{$name}=$count;
   		$coverage{$name}=$base;
		}
	}
}

# Count number of good hits per TE
open IN,"cat ../hits/03_subset_reduced/blast_hits.filtered.summary |" or die "Cannot open hits summary file\n";
my %hits;
while (my $row = <IN>) {
	chomp $row;
	my @line = split "\t",$row;
	my @tmp = split "#",$line[1];
	$hits{$tmp[0]}=$line[0];
}

# What is the divergence?
open IN,"../repeatmasker/03_subset_reduced/genome.divsum";
<IN>; <IN>; <IN>; <IN>; <IN>; <IN>;
my %coverage2;
my %kimuras;
while (my $row = <IN>) {
	chomp $row;
	if ($row eq "") {
		last;
	} else {
		my ($family,$name,$length,$length2,$kimura) = split "\t", $row;
   	$coverage2{$name}=$length2;
   	$kimuras{$name}=$kimura;
	}
}

printf "Name\tFamily\tSub-95\tSub-90\tSub-80\tenv\tgag\tpol\tCount\tHits\tCoverage\tCoverage2\tKimura\tLength\n";
foreach my $name (sort keys %families) {
	printf "$name";
	printf "\t$families{$name}";
	printf "\t".($subfamilies95{$name}//"-");
	printf "\t".($subfamilies90{$name}//"-");
	printf "\t".($subfamilies80{$name}//"-");
	printf "\t".($env{$name}//0);
	printf "\t".($gag{$name}//0);
	printf "\t".($pol{$name}//0);
	printf "\t".($counts{$name}//0);
	printf "\t".($hits{$name}//0);
	printf "\t".($coverage{$name}//0);
	printf "\t".($coverage2{$name}//0);
	printf "\t".($kimuras{$name}//0);
	printf "\t".($lengths{$name}//0);
	printf "\n";
}
