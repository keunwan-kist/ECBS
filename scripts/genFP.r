#!~/opt/bin/ Rscript

# Keunwan Park

options<-commandArgs(trailingOnly=T)

if(length(options) < 2) stop("Invalid argument number\n\nRscript [].r [sdf file] [out FP matrix file name]\n")
if(!is.na(options[1])) sdf_fn = options[1]
if(!is.na(options[2])) out_fn = options[2]

suppressPackageStartupMessages(library("ChemmineR"))
suppressPackageStartupMessages(library("ChemmineOB"))

# Edit the path for the storable data file for your system 
#load("/home/users/keunwan/programs/EECBS_v1/scripts/comb_maccs_zero_idx.storable.data")
load("../scripts/comb_maccs_zero_idx.storable.data")

# maccs_zero_idx variable is loaded

sdfset <- read.SDFset(sdf_fn)	# 5906 drugs
cid(sdfset) <- sdfid(sdfset)

#cid(sdfset) <- makeUnique(cid(sdfset))

maccs <- fingerprintOB(sdfset,"MACCS")
fp4 <- fingerprintOB(sdfset,"FP4")

comb_mat = cbind(as.matrix(maccs),as.matrix(fp4))

comb_nz <- comb_mat[,-maccs_zero_idx]

write.table( comb_nz, file=out_fn, quote=F,col.names=F)	# for feature selection


