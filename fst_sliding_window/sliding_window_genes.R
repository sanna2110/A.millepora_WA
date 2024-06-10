

setwd("C:/Users/sanna/Documents/2023/newslidingwindow/ash_ning")
# Load the FST data
fst_data <- read.table("slidingwindownva.fst.txt", header = TRUE)

# Load the genomic coordinates and gene IDs data
gene_data <- read.table("Amillepora_genes.tab", header = FALSE)
header <- c("chr","start","end","name")
colnames(gene_data) <- header

# pulling out only high fst values
high_fst <- fst_data[fst_data$Fst >= 0.4,]

# Create an empty vector to store matched gene IDs
matched_genes <- character()

# Loop through each row in high_fst
for (i in 1:nrow(high_fst)) {
  # Extract chromosome and middle position for the current row
  chr <- high_fst$chr[i]
  middle_pos <- high_fst$midPos[i]
  
  # Subset gene_data for the same chromosome as the current row
  chr_gene_data <- gene_data[gene_data$chr == chr, ]
  
  # Find genes that overlap with the middle position within the same chromosome
  overlapping_genes <- chr_gene_data$name[chr_gene_data$start <= middle_pos & chr_gene_data$end >= middle_pos]
  
  # If there are overlapping genes, add them to matched_genes; otherwise, add NA
  if (length(overlapping_genes) > 0) {
    matched_genes <- c(matched_genes, overlapping_genes)
  } else {
    matched_genes <- c(matched_genes, NA)
  }
}


unique_ID <- unique(matched_genes)
unique_ID

gene_class <- read.delim("amil_gene2kogClass.tab", col.names = c("name","class"))

# Filter the gene functions based on the matching gene IDs
matching_functions <- gene_class[gene_class$name %in% unique_ID, ]

# Print the matching gene functions
print(matching_functions)


# Create empty rows to fill in in the following loop
matching_functions$start <- numeric(nrow(matching_functions))
matching_functions$end <- numeric(nrow(matching_functions))
matching_functions$chr <- character(nrow(matching_functions))

# Loop through each row in matching_functions
for (i in 1:nrow(matching_functions)) {
  # Extract name for the current row
  name <- matching_functions$name[i]
  
  # fill in new column for start
  matching_functions$start[i]=gene_data$start[gene_data$name==name]
  matching_functions$end[i] = gene_data$end[gene_data$name==name]
  matching_functions$chr[i]=gene_data$chr[gene_data$name==name]
  
}

# change order of rows
matching_functions <- matching_functions[c(1,2,5,3,4)]


# read in annotation table
annotation_table <- read_excel("Amillepora_trinotate_annotation_report.xlsx")

# adding in GO terms
matching_GO <- as.data.frame(annotation_table[annotation_table$transcript_id %in% matching_functions$name,])
matching_GO <-matching_GO[,c(2,13)]

# order dataframes by protein name
matching_functions <- matching_functions[order(matching_functions$name),]
matching_GO <- matching_GO[order(matching_GO$transcript_id),]

# add GO terms
matching_functions$GO_terms <- matching_GO$gene_ontology_blast

# putting in chr order
matching_functions$chr <- factor(matching_functions$chr, levels = c("chr1", "chr2","chr8", "chr12","chr13"))

# order dataframe by chr 
matching_functions <- matching_functions[order(matching_functions$chr), ]

matching_functions$chr <- as.character(matching_functions$chr)

# save table
write.csv(matching_functions,file="ash_ningaloo_genes.csv")





