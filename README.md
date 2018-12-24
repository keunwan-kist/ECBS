# ensECBS 

## Description
Scripts to run ensemble evolutionary chemical binding similarity (ensECBS).


## Directory: 
scripts/ - script directory for running ensECBS model.

example/ - test examples for ensECSB run.

RF_Models_Integrated/ - directory for pre-built models. Pfam, Family, Superfamily, Target-ECSB, and ensemble ensECSB models should be downloaded from (https://doi.org/10.5072/zenodo.256309) 

[![DOI](https://sandbox.zenodo.org/badge/DOI/10.5072/zenodo.256309.svg)](https://doi.org/10.5072/zenodo.256309)

## Prerequisites: 
Before running ensECBS script, please install the prerequisite programs and edit the path variabales in the scripts. 

R - tested version 3.4.2

Perl - tested version v5.16.3 

R ranger package (0.8.0 or higher)

ChemmineOB package, 
```
source("https://bioconductor.org/biocLite.R")
biocLite("ChemmineOB") 
biocLite("ChemmineR")
```

## Script to run ensECBS 
`perl scripts/ensECBS_calc_script.pl`

**Usage**: perl ensECBS_calc_script.pl -db <db.mat> -seed <seed.mat> -pair_mat <seed_db.mat> -out <out file> -overwrite -overwrite_model -overwrite_pair_mat -delete_file -help

**Options**:

-db : data mat file (necessary)

-seed : query mat file (necessary)

-pair_mat : paired mat file, if used, -db & -seed options will be ignored

-out : out file name (necessary)

-overwrite : re-calculate all result files

-overwrite_model : re-calcuate model score generation step

-overwrite_pair_mat : re-generate paired mat file

-delete_file : delete all intermediate files

## Run examples
See ./example/TEST_example.txt file  

## Contributors
Keunwan Park (keunwan@kist.re.kr)

