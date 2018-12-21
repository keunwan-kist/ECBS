
scripts/ - script directory for running ensECBS model 
example/ - test examples for ensECSB run
Models/ - directory for pre-built Pfam, Family, Superfamily, Target-ECSB, and ensemble ensECSB model

#############################
# Before running ensECBS script, please install the programs and edit the path variabales in the scripts 
###########################

# script to generate mat file from chemical sdf file 
# edit the path in load("...PATH/comb_maccs_zero_idx.storable.data")
Rscript scripts/genFP.r	

# Prerequisites: 
R - tested version 3.4.2 
Perl - tested version v5.16.3 

ChemmineOB package  
source("https://bioconductor.org/biocLite.R")
biocLite("ChemmineOB") 
biocLite("ChemmineR")

R ranger package (0.8.0 or higher) 
install.packages("ranger") 


# script to run ensECSB model 
perl scripts/ECBS_calc_script.pl 

Usage: ../scripts/ensECBS_calc_script.pl -db <db.mat> -seed <seed.mat> -pair_mat <seed_db.mat> -out <out file> -overwrite -overwrite_model -overwrite_pair_mat -delete_file -help
Usage:
-db : data mat file (necessary)
-seed : query mat file (necessary)
-pair_mat : paired mat file, if used, -db & -seed options will be ignored
-out : out file name (necessary)
-overwrite : re-calculate all result files
-overwrite_model : re-calcuate model score generation step
-overwrite_pair_mat : re-generate paired mat file
-delete_file : delete all intermediate files



