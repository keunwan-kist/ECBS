use strict;
use File::Basename;
use Getopt::Long;
use Data::Dumper;

################ Description #####################################################
# Wrapper for running ensECBS - ensemble evolutionary chemical binding similarity 
# The script is freely available to academic and government laboratories. For a commecial use, please contact to keunwan@kist.re.kr
# Author: Keunwan Park, KIST, 20181218
# contact: keunwan@kist.re.kr 
#######################################################################


############ Change the dir paths below to your system ################

my $SCPT        = "/home/users/keunwan/programs/EECBS_v1/scripts";
my $Prior_MODEL = "/home/users/keunwan/programs/EECBS_v1/RF_Models_Integrated";	# [target].data.ranger_rf_model
my $INT_Model_D = "$Prior_MODEL/intergrated_scoring_model_D_rf";		# ensECBS   


#######################################################################
#######################################################################


my $usage = "\nUsage: $0 -db <db.mat> -seed <seed.mat> -pair_mat <seed_db.mat> -out <out file> -overwrite -overwrite_model -overwrite_pair_mat -delete_file -help
Usage: 
-db : data mat file (necessary)
-seed : query mat file (necessary)
-pair_mat : paired mat file, if used, -db & -seed options will be ignored
-out : out file name (necessary)
-overwrite : re-calculate all result files 
-overwrite_model : re-calcuate model score generation step
-overwrite_pair_mat : re-generate paired mat file
-delete_file : delete all intermediate files\n\n";

my %args=();
GetOptions("db:s"=>\$args{db},
     "seed:s"=>\$args{seed},
     "pair_mat:s"=>\$args{pair_mat},
     "out:s"=>\$args{out},
     "help:s"=>\$args{help},
     "delete_file:s"=>\$args{delete_file},
     "overwrite:s"=>\$args{overwrite},
     "overwrite_model:s"=>\$args{overwrite_model},
     "overwrite_pair_mat:s"=>\$args{overwrite_pair_mat},
);

my $DB = $args{db};
my $SEED = $args{seed};
my $PAIR_MAT = $args{pair_mat};
my $out_fn = $args{out} or die $usage;
my $overwrite = $args{overwrite};
my $overwrite_model = $args{overwrite_model};
my $overwrite_pair_mat = $args{overwrite_pair_mat};
my $help = $args{help};
my $delete_file = $args{delete_file};

die $usage if(defined $help);

my $INT_Model = $INT_Model_D;
print STDERR "-----------------------------------------------------\n";
print STDERR "----------- ensEECBS model --------------------------\n";
print STDERR "-----------------------------------------------------\n";

print STDERR "[Options]\n";
for my $a (sort keys %args){
	printf STDERR ("%-20s : %-20s %5s\n",$a,$args{$a},defined $args{$a});
}
print STDERR "\n";

if(defined $PAIR_MAT){
	print STDERR "NOT Generating paired chemical data mat,[$PAIR_MAT] will be used instead!\n";
}else{
	unless(defined $DB and defined $SEED){
		print STDERR "Both -db and -seed should be defined, or use -pair_mat option\n";
		die $usage;
	}
}	


my ($db_name,$db_path,$db_suffix);
($db_name,$db_path,$db_suffix) = fileparse($DB,".mat") if(defined $DB);
my ($seed_name,$seed_path,$seed_suffix);
($seed_name,$seed_path,$seed_suffix) = fileparse($SEED,".mat") if(defined $SEED);
my ($pair_name,$pair_path,$pair_suffix);
($pair_name,$pair_path,$pair_suffix) = fileparse($PAIR_MAT,".mat") if(defined $PAIR_MAT);

my %generated_files;

my $out_prefix;
my $drugpair_mat_fn;

if(defined $PAIR_MAT){
	
	print STDERR "Paired Chemical Matrix given : [$PAIR_MAT]\n";  
	$out_prefix = $pair_name;
	$drugpair_mat_fn = $PAIR_MAT;

}else{
	############# make TEST<->DB pair matrix.. #########################
	
	$out_prefix = "$seed_name\_$db_name";
	$drugpair_mat_fn = $out_prefix.".dp.mat";

	if(defined $overwrite or defined $overwrite_pair_mat or ! -s $drugpair_mat_fn){

		print STDERR "Loading MAT FILES: DB $db_name / SEED $seed_name\n\n";

		my @DB_MAT;
		open(IN,$DB) or die "can't open file: $DB\n";
		while(<IN>){
			chomp;
			next if(/^$/);
			push @DB_MAT,$_;
		}
		close IN;

		my @SEED_MAT;
		open(IN,$SEED) or die "can't open file: $SEED\n";
		while(<IN>){
			chomp;
			next if(/^$/);
			push @SEED_MAT,$_;
		}
		close IN;

		print STDERR "Generating drug pair feature matrix : [$drugpair_mat_fn]\n";

		open(OUT,">$drugpair_mat_fn") or die "can't open file:$drugpair_mat_fn\n";

		$generated_files{$drugpair_mat_fn}=1;		
	
		for my $t (@SEED_MAT){
			my @t_vec = split(/\s+/,$t);
			for my $m (@DB_MAT){
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
		print STDERR "[WARN] NOT Generating paired chemical data mat, [$drugpair_mat_fn] already exist ??\n";  
	}
}

#########################################################

my $train_size;
my %Size;
my @model_repos;

####################################################

my @ECS_prior_model = ("target","pfam","fam","supfam");
for my $m (@ECS_prior_model){
	push @model_repos, "$Prior_MODEL/$m.data.ranger_rf_model";
}

print STDERR "outfile prefix: [$out_prefix]\n";

for my $model (@model_repos){
  if(-s $model){
    
		my ($rf_name,$path,$suffix) = fileparse($model);
		my $model_out_fn = "$out_prefix.$rf_name.data";		
		if(defined $overwrite or defined $overwrite_model or ! -s $model_out_fn){

			############### MODEL RUNNUNG ####################################
			print STDERR "$rf_name Model Prediction\n";
			`Rscript $SCPT/GeneralDrugPairPredictMachine.r $model $drugpair_mat_fn $model_out_fn`;
			############### MODEL RUNNING ####################################
			
			$generated_files{$model_out_fn}=1;
		
		}else{
			print STDERR "[WARN] $rf_name Model Prediction - [$model_out_fn] already exist??\n";
		}

	}else{
    print STDERR "\nWarning: $model NOT FOUND\n";
  }
}
print STDERR "\n\nFinished - Model Predictions ... check out $out_prefix.\*.data\n";

################################################################

my %Data;

for my $c (@ECS_prior_model){			# for each model category  
  my $data = "$out_prefix.$c.data.ranger_rf_model.data";		# naming - causion ..
	if(-s $data){
		open(IN,$data) or die "can't open file:$data\n";
		while(<IN>){
			chomp;
			my ($q,$db,$score,$ecdf)=split;
			$Data{$q}{$db}{$c}{score}=$score;
		}
		close IN;
	}else{
		print STDERR "Warning[DATA]: $data NOT Found!!\n";
	}
}
######################################################

my $score_out_fn = "$out_prefix.all_scores.txt";
print STDERR "Writing Intergrated & Normalized score results to [$score_out_fn]\n";
open(OUT,">$score_out_fn") or die "can't open file:$score_out_fn\n";

$generated_files{$score_out_fn}=1;


print OUT "Drug1 Drug2 target pfam family superfamily\n";		# EECBS(D)

for my $q (keys %Data){
	for my $db (keys %{$Data{$q}}){
		my @score_ary;
		for my $c (@ECS_prior_model){			# integrated model, order is important 
			my $c_score = $Data{$q}{$db}{$c}{score} || 0; 
			push @score_ary,$c_score;
		}

		print OUT "$q $db @score_ary\n";
	}
}

close OUT;

print STDERR "Running Intergrated Models Summing All Predictions: $INT_Model\n";
`Rscript $SCPT/GeneralDrugPairPredictMachine.r $INT_Model $score_out_fn $out_fn read_header`;
print STDERR "DONE... check final score file: [$out_fn]\n\n";

if(defined $delete_file){
	for my $f (keys %generated_files){
		print STDERR "Deleting $f ...\n";
		`rm $f`;
	}
}



