# steps used to go from original paired .fastq.gz files (or .sra files for Fuller sequences) to .bam files

# downloading Fuller sequences
# finding files online to download - get SAMN1347100-SAMN13447120 (20 samples)
# downloading from NCBI

> prefetch
for n in `seq 13447100 1 13447120`; do
echo "prefetch -O sra SAMN$n" >>prefetch
done

# run prefetch job file

# originally .sra files -> converting into fastq files

> fastqdump
for n in `seq 10571312 1 10571328` ; do
echo "fastq-dump --outdir fastq --gzip --skip-technical  --readids --read-filter pass --dumpbase --split-3 --clip sra/SRR$n/SRR"$n".sra" >>fastqdump
done

for n in `seq 10571393 1 10571399` ; do
echo "fastq-dump --outdir fastq --gzip --skip-technical  --readids --read-filter pass --dumpbase --split-3 --clip sra/SRR$n/SRR"$n".sra" >>fastqdump
done

for n in `seq 10571567 1 10571568` ; do
echo "fastq-dump --outdir fastq --gzip --skip-technical  --readids --read-filter pass --dumpbase --split-3 --clip sra/SRR$n/SRR"$n".sra" >>fastqdump
done

# run fastqdump job file

# all of the following steps were also done to the Fuller sequences, with minor differences resulting from slightly different naming format 

# decompress all of the fq files
gzip -d  *.gz &

# FASTQC

fastqc -o fastqcout --extract --threads 4 *.fq

# multiqc to bring all of this together
multiqc .

# download multiqc report

# removing adapters (specified with the -a and -A options)
# specifying quality cutoff of Q = 15 (-q option)
# removing any reads <25 bp in length (-m option)
>filter
for file in *_R1.fq; do
echo "cutadapt -a CTGTCTCTTATACACATCT -A CTGTCTCTTATACACATCT -q 15,15 -m 25 -o ${file/.fq/}.trim -p ${file/_R1.fq/}_R2.trim $file ${file/_R1.fq/}_R2.fq > ${file/_R1.fq/}_trimlog.txt" >> filter;
done

# run filter job file 

# aligning to genome

# making shortcut to genome (concatenated A. millepora and symbiont genomes)
export HONS_GENOME_FASTA=$STOCKYARD/honsgen/Amil.symb.cat.genome.fasta

# indexing genome for bowtie2
echo "bowtie2-build $HONS_GENOME_FASTA $HONS_GENOME_FASTA" >index

# run index job file

# samtools index 
samtools faidx $HONS_GENOME_FASTA

# bowtie2 
# --no unal = suppress SAM records for reads that fail to align
# --local = specifies local read alignment. In this mode, Bowtie 2 might "trim" or "clip" some read characters from one or both ends of the alignment if doing so maximizes the alignment score.
# -x argument = basename of the index for the reference genome (name of the index files up to but not including the .1.bt2 (for example)
# -U argument = list of files containing unpaired reads to be aligned (this is each of our .trim files)
# -S argument = file to write SAM alignments to (in this case it is the name of the original .trim file but ending in sam)
# -p 8 - allows for multithreading

>mapping
for file in *R1.trim; do 
echo "bowtie2 --no-unal --local -p 8 -x $HONS_GENOME_FASTA -1 $file -2 ${file/R1.trim/}R2.trim -S ${file/_R1.trim/}.sam" >> mapping;
done

# run mapping job file

# samtools view to make new files with just host reads

>hostbams
for F in *.bam; do
echo "samtools view $F chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 -o ${.bam/}_host.bam" >> hostbams;
done

# run hostbams job file

# samtools sort to make bam files

>samtobam
for file in *.sam; do 
echo "samtools sort -O bam -o ${file/.sam}.bam $file" >> samtobam;
done

# run samtobam job file

# samtools index to make compressed bam files (.bam.csi) for easy access

>bamindex
for file in *.bam; do
echo "samtools index -c $file" >> bamindex;
done

# run bamindex job file

# next, ran ANGSD Quality Analysis
# setting FILTERS and TODO to analyse quality of reads using angsd

FILTERS="-uniqueOnly 1 -minMapQ 20 -maxDepth 10000"
TODO="-doQsDist 1 -doDepth 1 -doCounts 1 -dumpCounts 2"

echo "angsd -b bams -GL 1 $FILTERS $TODO -P 4 -out dd" > angqc

# run angqc job file

# as the next step didn't work with our original dd.counts file (because it was too large), we have made a new smaller version
# firstly, renaming dd.counts.gz as dd.countsALL.gz
# then, reading the file, piping that into head which will look at the first 300000 lines, and then piping this into gzip which will compress the 
# information and put it into a new file called dd.counts.gz

mv dd.counts.gz dd.countsAll.gz
zcat dd.countsAll.gz | head -300000 | gzip >dd.counts.gz

# running plotQC (output of this will be dd.)

Rscript ~/bin/plotQC.R prefix=dd bams=bams

# result of this showed that all .bam files passed the quality check, so didn't need to remove any

# checking for clones

# make copies of three bam files
# make a bams list with the clones --> once we have the clones:

ls *.bam > bams.clones

# run angsd with the clones
# running angsd with 80% of samples (minInd = 80% of samples)

FILTERS="-uniqueOnly 1 -minMapQ 20 -minQ 20 -dosnpstat 1 -doHWE 1 -sb_pval 1e-5 -hetbias_pval 1e-5 -minInd 19 -snp_pval 1e-5 -minMaf 0.05 -maxHetFreq 0.5"
TODO="-doMajorMinor 1 -skipTriallelic 1 -doMaf 1 -doCounts 1 -makeMatrix 1 -doIBS 1 -doCov 1 -doGeno 8 -doPost 1 -doGlf 2"

>clonesm
echo "angsd -b bams.clones -GL 1 $FILTERS $TODO -P 12 -out OKclone" >clone

# run clone job file

# download OKclone.ibsMat and bams.clones to laptop and work in R

# in R --> using R script called clonecheck.R
# this will produce bams_noclones with no clones --> we have also removed the copy files from bams_noclones

# scp bams_noclones back to TACC

# rerun angsd with no clones