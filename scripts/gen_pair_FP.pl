use strict;
use File::Basename;
use Getopt::Long;
use Data::Dumper;

# Description:
# generating pair chemical data 
# Keunwan Park, KIST, 20180817
# keunwan@kist.re.kr 


my $usage = "Usage: $0 -fp1 <fp1.mat> -fp2 <fp2.mat> -out <out file>\n";

my %args=();
GetOptions("fp1:s"=>\$args{fp1},
     "fp2:s"=>\$args{fp2},
     "out:s"=>\$args{out},
);


my $fp1 = $args{fp1} or die $usage;
my $fp2 = $args{fp2} or die $usage;
my $out_fn = $args{out};

my @MAT1;
open(IN,$fp1) or die "can't open file: $fp1\n";
while(<IN>){
  chomp;
  next if(/^$/);
  push @MAT1,$_;
}
close IN;

my @MAT2;
open(IN,$fp2) or die "can't open file: $fp2\n";
while(<IN>){
  chomp;
  next if(/^$/);
  push @MAT2,$_;
}
close IN;

############# make TEST<->DB pair matrix.. #########################


if(defined $out_fn){
		
	open(OUT,">$out_fn") or die "can't open file:$out_fn\n";

	for my $t (@MAT1){
		my @t_vec = split(/\s+/,$t);
		for my $m (@MAT2){
			my @inter;
			my @m_vec = split(/\s+/,$m);
			for(my $i=1;$i<@m_vec;$i++){
				##########################################################
				push @inter, $t_vec[$i] + $m_vec[$i]; # diff bit
				##########################################################
			}
			print OUT "$t_vec[0] $m_vec[0] @inter\n";
		}
	}
	close OUT;
}else{
	for my $t (@MAT1){
		my @t_vec = split(/\s+/,$t);
		for my $m (@MAT2){
			my @inter;
			my @m_vec = split(/\s+/,$m);
			for(my $i=1;$i<@m_vec;$i++){
				##########################################################
				push @inter, $t_vec[$i] + $m_vec[$i]; # diff bit
				##########################################################
			}
			print "$t_vec[0] $m_vec[0] @inter\n";
		}
	}

}

