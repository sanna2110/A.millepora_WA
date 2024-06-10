# A.millepora_WA

**Original cleaning steps + what we have now (the code for this is in file called fastq_to_bam) (all steps were done on HPC so they are written in the format of writing a job file which was then submitted to be run on the HPC)**

- List of original samples sequenced, along with their file names in my format is in **samples_sequenced.xlsx**
- Originally got our *A. millepora* samples as paired .fastq files
- Got the Fuller sequences from NCBI SRA database - steps I used to download and turn these into
- First used **fastqc** to check quality of each sequence and **multiqc** to summarise this
    - Output from this in table format is in **multiqc_output.xlsx**
    - Link to website with graphs etc. is **multiqc_report.html** —> this also has results for samoensis so ignore anything starting with SA or SS
- Used **cutadapt** to remove adapter reads and any reads less than Q=15, or length < 25bp
    - This produced .trimlog files with information about each sample, which I will put **XXXX**
    - Excel file called **cutadapt_summary** also includes a summary of these files
- Used **bowtie2** to map to genome —> used a concatenated *A. millepora* + symbionts genome (has genomes of four Symbiodiniaceae strains/species concatenated at the end)
    - This resulted in a single .sam file for each sample
- Then used **samtools view** to extract only host reads (getting rid of symbiont reads) —> current .bam files have only host reads
- Then used **samtools sort** to make .bam files and **samtools index** to create .bam.csi files

- Currently have .fastq.gz files in /work/08908/sanna21/fastqfiles
    - These have been made from .bam files, so they’re not paired, just one for each sample
- Currently have .bam files in /scratch/08908/sanna21/gadma/
    - This include all of our *A. millepora* samples (14x autumn spawners, 10x spring spawners)
    - Also includes Fuller samples (20 samples)
    

**ANGSD Quality Analysis + Clone Check + PCA**

- Ran quality check analysis with angsd
    - Showed that all files passed, so didn’t need to exclude any
- Check for clones —> instructions in .bash file and **check_clone.R** R script
    - There were no clones so didn’t need to remove any
- Ran ANGSD again with same filters without the clone samples
- Download bams.qc and OKall.ibsMat to local computer and run **PCAFuller.R** in R to create PCAs

**FST Sliding Window Analysis**

- Script for this analysis in ANGSD is in file called **fst_sliding_window.bash** - I ran this also on the HPC
- Once the sliding window output is downloaded, need to separate into chromosome files to use in the **manhattan.R** script
- To make Manhattan plot from FST sliding window results - use **manhattan.R**
- To find genes matching the areas of interest, use **sliding_window_genes.R**
    - First need to look at Manhattan plot and decide on a cut-off for ‘large’ FST values
    - This script creates a table with each of the genes found in the regions of high FST and their function
- Currently have the FST sliding window output files + Manhattan plots for each comparison, and gene table for Ashmore vs Ningaloo

**Demographic History Analysis**

- Tried GADMA
- Tried moments (Misha’s github)
