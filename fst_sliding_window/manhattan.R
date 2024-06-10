library(ggplot2)
library(cowplot)
library(qqman)

setwd("C:/Users/sanna/Desktop/2023/newslidingwindow/ash_fuller/")

# starting with files for each chromosome from the fst sliding window analysis 

# loop through each chromosome, and do the following:
# inf1="chr1.fst.txt"
# chr1=as.data.frame(read.table(inf1,header=TRUE))
# chr1pos=as.numeric(chr1$midPos)
# chr1length=as.numeric(length(chr1pos))
# chr1num=rep(1, chr1length)
# chr1fst=as.numeric(chr1$Fst)

for (i in 1:14) {
  # Create the inf variable for each i
  assign(paste0("inf", i), paste0("chr", i, ".fst.txt"))
  
  # Read the fst sliding window output and assign it to the corresponding chr variable
  assign(paste0("chr", i), as.data.frame(read.table(get(paste0("inf", i)), header = TRUE)))
  
  # Convert midPos column to numeric and assign to chromsome position variable
  assign(paste0("chr", i, "pos"), as.numeric(get(paste0("chr", i))$midPos))
  
  # Get the length of chromosome position and assign to chromosome length variable
  assign(paste0("chr", i, "length"), length(get(paste0("chr", i, "pos"))))
  
  # Create a vector of repetition of the chromosome number 
  assign(paste0("chr", i, "num"), rep(i, get(paste0("chr", i, "length"))))
  
  # Convert Fst column to numeric and assign to chromosome fst variable
  assign(paste0("chr", i, "fst"), as.numeric(get(paste0("chr", i))$Fst))
}


# calculate total length
totallength=chr1length+chr2length+chr3length+chr4length+chr5length+chr6length+chr7length+chr8length+chr9length+chr10length+chr11length+chr12length+chr13length+chr14length

# create the variables needed for the table to give to manhattan function
# just combining each of the variables we made above
SNP=as.character(1:totallength)
CHR=as.integer(c(chr1num,chr2num,chr3num,chr4num,chr5num,chr6num,chr7num,chr8num,chr9num,chr10num,chr11num,chr12num,chr13num,chr14num))
BP=as.integer(c(chr1pos,chr2pos,chr3pos,chr4pos,chr5pos,chr6pos,chr7pos,chr8pos,chr9pos,chr10pos,chr11pos,chr12pos,chr13pos,chr14pos))
P=c(chr1fst,chr2fst,chr3fst,chr4fst,chr5fst,chr6fst,chr7fst,chr8fst,chr9fst,chr10fst,chr11fst,chr12fst,chr13fst,chr14fst)

gwasResults=data.frame(SNP,CHR,BP,P)

manhattan(gwasResults,logp=FALSE,ylab="FST") 

# to look at a subset of one chromosome
manhattan(subset(gwasResults, CHR == 1),logp=FALSE,ylab="FST")

