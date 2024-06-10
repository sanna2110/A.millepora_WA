# getting all of the packages/programs needed
library(adegenet)
require(vegan)
library(dplyr)
library(ggplot2)
library(RColorBrewer)
library(vegan)
library(pairwiseAdonis)
library(dplyr)
library(ggplot2)

#anything with 80% ibs matrix is called OKall.

# making matrix in R with values from 80% ibs matrix
inf=commandArgs(T)

setwd("C:/Users/sanna/Desktop/2023/PCA")
inf="OKall.ibsMat"
ma = as.matrix(read.table(inf))

# reading bams, removing file name trash
bams=scan("bams.qc",what="character") # list of bam files
bams=sub(".bam","",bams)
bams=sub("/.+/","",bams)
dimnames(ma)=list(bams,bams)

# plotting PCA with 80% ibs matrix
pp0=capscale(ma~1)
plot(pp0, scaling=1)

### MAKING CONDITIONS TABLE

# making vectors with species, spawning time and location
spawn <- substr(bams, 2,2)
location <- substr(bams,1,2)
state <- recode(location, MA = "West", MS = "West", SR = "East")

location <- recode(location, MA = "NR", MS = "AR", SR = "F" )

# making a table combining these vectors
conds=data.frame(cbind(spawn,location,state))
conds

# renaming the factors to make sense in the legends
conds$location <- gsub("NR", "Ningaloo Reef", conds$location)
conds$location <- gsub("AR", "Ashmore Reef", conds$location)
conds$location <- gsub("F", "Fuller", conds$location)
conds$spawn <- gsub("A", "Autumn", conds$spawn)
conds$spawn <- gsub("S", "Spring", conds$spawn)
conds$spawn <- gsub("R", "Spring", conds$spawn)

# making main scores 
scores=as.data.frame(scores(pp0, scaling=1)$sites)

### WEST VS EAST
# using scores because this comparison uses all of the samples
# this one is literally just using state factor and all samples

ggplot(scores,aes(MDS1,MDS2,color=conds$state))+geom_point()+coord_equal()+theme_bw()+labs(colour="Location")+theme(aspect.ratio=1,legend.title = element_blank(),legend.text = element_text(size = 9, colour = "black"),panel.background = element_blank(),panel.grid.major = element_blank(), panel.grid.minor = element_blank(),axis.line = element_line(colour = "black"),panel.border = element_rect(colour = "black", fill=NA, size=1),legend.position="right",legend.background = element_blank(),legend.box.background = element_rect(colour = "grey"))

### SPRING VS AUTUMN
# using scores because this comparison uses all of the samples
# this one is just using spawning factor and all samples

ggplot(scores,aes(MDS1,MDS2,color=conds$spawn))+geom_point()+coord_equal()+theme_bw()+labs(colour="Spawning Time")+theme(aspect.ratio=1,legend.title = element_blank(),legend.text = element_text(size = 9, colour = "black"),panel.background = element_blank(),panel.grid.major = element_blank(), panel.grid.minor = element_blank(),axis.line = element_line(colour = "black"),panel.border = element_rect(colour = "black", fill=NA, size=1),legend.position="right",legend.background = element_blank(),legend.box.background = element_rect(colour = "grey"))

### NINGALOO VS ASHMORE (24 samples all together)
# making new conds table, matrix, and scores with just WA samples
waconds=conds[1:24,]

wama=ma[1:24,1:24]

ppwa=capscale(wama~1)

wascores=as.data.frame(scores(ppwa, scaling=1)$sites)

ggplot(wascores,aes(MDS1,MDS2,color=waconds$location))+geom_point()+coord_equal()+theme_bw()+labs(colour="Location")+theme(aspect.ratio=1,legend.title = element_blank(),legend.text = element_text(size = 9, colour = "black"),panel.background = element_blank(),panel.grid.major = element_blank(), panel.grid.minor = element_blank(),axis.line = element_line(colour = "black"),panel.border = element_rect(colour = "black", fill=NA, size=1),legend.position="right",legend.background = element_blank(),legend.box.background = element_rect(colour = "grey"))

### ASHMORE VS FULLER (first 10 are MA and last 20 are Fuller (out of 44))
avfconds=conds[15:44,]

avfma=ma[15:44,15:44]

ppavf=capscale(avfma~1)

avfscores=as.data.frame(scores(ppavf, scaling=1)$sites)

ggplot(avfscores,aes(MDS1,MDS2,color=avfconds$location))+geom_point()+coord_equal()+theme_bw()+labs(colour="Location")+theme(aspect.ratio=1,legend.title = element_blank(),legend.text = element_text(size = 9, colour = "black"),panel.background = element_blank(),panel.grid.major = element_blank(), panel.grid.minor = element_blank(),axis.line = element_line(colour = "black"),panel.border = element_rect(colour = "black", fill=NA, size=1),legend.position="right",legend.background = element_blank(),legend.box.background = element_rect(colour = "grey"))


### ADONIS2

# running adonis2 with all of the samples, using different combinations of factors
adonis2(ma~spawn,state,location,conds)
adonis2(wama~spawn,conds)
adonis2(avfma~location,conds)



