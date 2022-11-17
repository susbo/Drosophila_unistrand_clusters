#!/usr/bin/perl -w
# Create HTML file describing putative clusters with relevant information
# Author: Susanne Bornelöv
# Last edit: 2022-11-17
use strict;

my %clusters;

open IN,"tmp/selected_genes.txt";
while (my $row = <IN>) {
	chomp $row;
#	printf "$row\n";
	my @line = split "\t",$row;
	my ($cluster,$gene,$shift) = ($line[0],$line[1],$line[4]);

	my @hits = `grep "$gene" tmp/psl/*.filter.psl`;
	#hit: tmp/psl/Dalb-GCF_009650485.1.filter.psl:772	157	0	0	7	686	8	2641	+	Pld	3837	178	1793	NC_047629.1	55557198	48587376	48590946	12	152,88,6,38,80,4,19,5,23,181,7,326,	178,336,424,435,510,590,595,616,621,1278,1460,1467,	48587376,48587528,48587617,48587627,48587759,48587840,48587844,48587864,48587870,48590431,48590612,48590620,
	foreach my $hit (@hits) {
		chomp $hit;
#		printf "hit: $hit\n";
		$hit =~ /tmp\/psl\/(.+).filter.psl/;
		my $name = $1;
		my @info = split "\t",$hit;
		my ($chr,$from,$to) = ($info[13],$info[15],$info[16]);
		$clusters{$name}{$cluster}{$chr}{$gene} = [round($from+($to-$from)/2),round($shift)];
	}
}

printf "<html><head><link rel='stylesheet' href='style.css'></head><body>";
printf "<p><u>Predicted locations of dm6 biogenesis genes across <i>Drosophila</i> genomes.</u><br><br><b>Sample:</b> <i>Drosophila</i> species and genome build<br><b>Gene:</b> Name of gene (in <i>Drosophila melanogaster</i>)<br><b>Position</b>: Predicted position with link to the genome browser<br><b>Up/Down:</b> Number of upstream/downstream genes found (<b>black</b> = support on both sides; <font color='grey'><b>grey</b></font> = support only on one side)<br><b>Genes:</b> Detailed information about genes found (<b>black</b> = gene symbol; <font color='red'><b>red</b></font> = position in <i>Drosophila melanogaster</i> relative gene midpoint; <font color='green'><b>green</b></font> = predicted position in species genome)\n";
printf "<table border=1 style='font-size: 11px; border: 1px solid'><tr><th>Sample</th><th>Gene</th><th>Position</th><th>Up</th><th>Down</th><th>Genes</th></tr>\n\n";

foreach my $sample (sort { $a cmp $b } keys %clusters) {
	###### Find rowspan
	my $rowspan = 0;
	foreach my $clust (keys %{ $clusters{$sample} }) {
		my $rowadd = 0;
		foreach my $chr (keys %{ $clusters{$sample}{$clust} }) {
			my $last_pos = 0; my $N_genes = 0;
			my @keys = sort { $clusters{$sample}{$clust}{$chr}{$a}[0] <=> $clusters{$sample}{$clust}{$chr}{$b}[0] } keys %{ $clusters{$sample}{$clust}{$chr} };
			foreach my $key (@keys) {
				if ($last_pos != 0 && (abs($clusters{$sample}{$clust}{$chr}{$key}[0]-$last_pos)>1000000)) {
					$rowadd++ if $N_genes>2;
					$N_genes = 0;
				}
				$N_genes++;
				$last_pos = $clusters{$sample}{$clust}{$chr}{$key}[0];
			}
			$rowadd++ if $N_genes>2;
		}
		$rowadd = 1 if $rowadd == 0;
		$rowspan += $rowadd;
	}
	printf "<tr><th rowspan=$rowspan>$sample</th>\n";
	######

	my $N_clust = 0;
	foreach my $clust (sort { $a cmp $b } keys %{ $clusters{$sample} }) {
		printf "<tr>" if $N_clust++ > 0;

		###### Find rowspan
		my $rowspan = 0;
		foreach my $chr (keys %{ $clusters{$sample}{$clust} }) {
			my $last_pos = 0; my $N_genes = 0;
			my @keys = sort { $clusters{$sample}{$clust}{$chr}{$a}[0] <=> $clusters{$sample}{$clust}{$chr}{$b}[0] } keys %{ $clusters{$sample}{$clust}{$chr} };
			foreach my $key (@keys) {
				if ($last_pos != 0 && (abs($clusters{$sample}{$clust}{$chr}{$key}[0]-$last_pos)>1000000)) {
					$rowspan++ if $N_genes>2;
					$N_genes = 0;
				}
				$N_genes++;
				$last_pos = $clusters{$sample}{$clust}{$chr}{$key}[0];
			}
			$rowspan++ if $N_genes>2;
		}
		$rowspan = 1 if $rowspan == 0;
		my $clust_short = $clust; $clust_short =~ s/Cluster//;
		printf "<td rowspan=$rowspan>$clust_short</td>\n";
		######

		my $N_chr = 0;
		foreach my $chr (sort { $a cmp $b } keys %{ $clusters{$sample}{$clust} }) {
			my %genes; my $last_pos = 0; my $first_pos = 0;
			my @keys = sort { $clusters{$sample}{$clust}{$chr}{$a}[0] <=> $clusters{$sample}{$clust}{$chr}{$b}[0] || $clusters{$sample}{$clust}{$chr}{$a}[1] <=> $clusters{$sample}{$clust}{$chr}{$b}[1] } keys %{ $clusters{$sample}{$clust}{$chr} };
			foreach my $key (@keys) {
				# Check if print needed
				if ($last_pos != 0 && (abs($clusters{$sample}{$clust}{$chr}{$key}[0]-$last_pos)>1000000)) {
					my ($plus,$minus) = counts(\%genes);
					if ($plus+$minus>2) {
						printf "<tr>" if $N_chr++ > 0;
						printf "<td>";
						printf "<font color='grey'>" if $plus==0 || $minus==0;
						my $sample2 = $sample; $sample2 =~ s/-/\//;
						printf "$chr:$first_pos-$last_pos</td><td>";
						printf "<font color='grey'>" if $plus==0 || $minus==0;
						printf "$minus/20</td><td>";
						printf "<font color='grey'>" if $plus==0 || $minus==0;
						printf "$plus/20</td><td><font style='font-size:9px'>";
						foreach my $gene (sort { $genes{$a}[0] <=> $genes{$b}[0]} keys %genes) {
#							printf "<p>" if $last_pos != 0 && abs($last_pos-$genes{$gene}[0])>1000000;
							printf " $gene [<font color='red'>$genes{$gene}[1]</font>|<font color='green'>$genes{$gene}[0]</font>],";
						}
						printf "</font></td></tr>\n";
					}
					%genes = ();
					$first_pos = 0;
				}
				$genes{$key} = [$clusters{$sample}{$clust}{$chr}{$key}[0],$clusters{$sample}{$clust}{$chr}{$key}[1]];
				$last_pos = $clusters{$sample}{$clust}{$chr}{$key}[0];
				$first_pos = $clusters{$sample}{$clust}{$chr}{$key}[0] if $first_pos == 0;
			}
			# Print last cluster
			my ($plus,$minus) = counts(\%genes);
			next if $plus+$minus<3;
			printf "<tr>" if $N_chr++ > 0;
			printf "<td>";
			printf "<font color='grey'>" if $plus==0 || $minus==0;
			my $sample2 = $sample; $sample2 =~ s/-/\//;
			printf "$chr:$first_pos-$last_pos</td><td>";
			printf "<font color='grey'>" if $plus==0 || $minus==0;
			printf "$minus/20</td><td>";
			printf "<font color='grey'>" if $plus==0 || $minus==0;
			printf "$plus/20</td><td><font style='font-size:9px'>";
			foreach my $gene (sort { $genes{$a}[0] <=> $genes{$b}[0]} keys %genes) {
#				printf "<p>" if $last_pos != 0 && abs($last_pos-$genes{$gene}[0])>1000000;
				printf " $gene [<font color='red'>$genes{$gene}[1]</font>|<font color='green'>$genes{$gene}[0]</font>],";
			}
			printf "</font></td></tr>\n";
		}
		if ($N_chr == 0) {
			printf "<td colspan=4 style='background-color:#EEEEEE'></td></tr>\n";
		}
	}
}

printf "</table>";
printf "</body></html>";

sub round {
	return int($_[0]+0.5);
}

sub counts {
	my %genes = %{$_[0]};
	my ($plus,$minus) = (0,0);
	foreach my $gene (sort { $genes{$a}[1] <=> $genes{$b}[1] } keys %genes) {
		$plus++ if $genes{$gene}[1]>0;
		$minus++ if $genes{$gene}[1]<=0;
	}
	return ($plus,$minus);
}
