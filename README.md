# A.millepora_WA

**Original cleaning steps + what we have now (the code for this is in file called fastq_to_bam) (all steps were done on HPC so they are written in the format of writing a job file which was then submitted to be run on the HPC)**

- List of original samples sequenced, along with their file names in my format is in **samples_sequenced.xlsx**
- Originally got our *A. millepora* samples as paired .fastq files
- Got the Fuller sequences from NCBI SRA database - steps I used to download and turn these into
- First used **fastqc** to check quality of each sequence and **multiqc** to summarise this
    - Output from this in table format is in **multiqc_output.xlsx**
    - Link to website with graphs etc. is **multiqc_report.html** —> this also has results for samoensis so ignore anything starting with SA or SS
- Used **cutadapt** to remove adapter reads and any reads less than Q=15, or length < 25bp
    - This produced .trimlog files with information about each sample, which I will put in **quality_check** folder
    - Excel file called **cutadapt_summary** also includes a summary of these files
- Used **bowtie2** to map to genome —> used a concatenated *A. millepora* + symbionts genome (has genomes of four Symbiodiniaceae strains/species concatenated at the end)
    - This resulted in a single .sam file for each sample
- Then used **samtools view** to extract only host reads (getting rid of symbiont reads) —> current .bam files have only host reads
- Then used **samtools sort** to make .bam files and **samtools index** to create .bam.csi files

- Currently have .fastq.gz files in /work/08908/sanna21/fastqfiles and /work/08908/sanna21/fuller
    - As the original fastq files were lost, the new ones have been made from .bam files, so they’re not paired, just one for each sample
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

- First, tried GADMA —> didn’t really work so I think if you were to try again you’re better to try from scratch instead of trying to decipher all of the options I tried. I’ll include the best figure it made, but the residuals from this model were huge, and Misha suggested that it didn’t work because the data just doesn’t fit any of the models that GADMA uses. The following method takes a LOT more models and tries to fit the data to them
- Then tried a different method, using *moments* —> followed steps on Misha’s GitHub page to obtain bootstrapped SFS with ANGSD (at the end of the README)  https://github.com/z0on/AFS-analysis-with-moments
    - Got the bootstrapped SFS files, but then when I tried to run the actual scripts, I got weird errors and therefore haven’t got any output from this —> asked Misha for help and he was unsure of where the errors are coming from
