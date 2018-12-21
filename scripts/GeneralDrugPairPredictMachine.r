#!~/opt/bin/Rscript

# Keunwan Park

options<-commandArgs(trailingOnly=T)

if(length(options) < 2) stop("Invalid argument number\n\nRscript [].r [RF classification model] [Drug Pair matrix to be tested] [output fn, optional] [read header? 1]\n")
if(!is.na(options[1])) rf_model_name = options[1]
if(!is.na(options[2])) test_drugpair_fn = options[2]
if(!is.na(options[3])) output_fn = options[3]

if(!is.na(options[4])){

	test_data <- read.table(test_drugpair_fn,header=T)

}else{

	test_data <- read.table(test_drugpair_fn)

}

drugpair_name <- test_data[,c(1,2)]

test_data <- test_data[,-c(1,2)]

#################### training and validation #######################

suppressPackageStartupMessages(require(ranger))
load(file = rf_model_name)	# load "data.rb" model variable whatever the file name is 

#test_pred <- predict(data.rb, test_data, num.trees=50) 
test_pred <- predict(data.rb, test_data) 

#cat("Test finished... Now saving the result probability\n")

if(!is.na(options[3])){
	write.table( cbind(drugpair_name,round(test_pred$predictions[,2],5)), file=output_fn, quote=F, row.names=F, col.names=F)
}else{
	write.table( cbind(drugpair_name,round(test_pred$predictions[,2],5)), quote=F, row.names=F, col.names=F)
}


