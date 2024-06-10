
# makes an object called bams which is a list of the bam files
bams=read.table("bams.clones")[,1] # list of bam files
bams=sub(".bam","",bams)
length(bams)

ma = as.matrix(read.table("OKclone.ibsMat"))

# changing the row and column names to the list of samples that is listed in "bams"
# important - the output of ANGSD does not name columns, you need to know the order of the samples to be able to label them later (it will be the same order as your original bams file you put into ANGSD)
dimnames(ma)=list(bams,bams)


# as.dist - changing the matrix to distances (formatting)
# hclust - heirarchical clustering function - builds a phylogenetic tree - clusters them according to the distances (in this case this is genetic differences)
# second argument for hclust is the type of clustering we are asking for - ave = average 
# putting the result of this into an object called hc 
hc=hclust(as.dist(ma),"ave")

# plotting the tree - already built into the plot command - cex=0.8, decreases the size of the text
# height is the distance between the samples - samples that are down the bottom of the tree are clones 
plot(hc,cex=0.8) # clustering of samples by IBS (great to detect clones or closely related individuals)