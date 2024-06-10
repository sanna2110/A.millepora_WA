### FST Sliding Window Analysis (adjusted from code from Luke Thomas) ###

# making files with the lists of bams to be used for each group
# change this depending on which comparison you're making

ls *A*.bam > aut.bamlist
ls *S*.bam > spr.bamlist

# setting filters and todo as shortcuts and shortcut for genome

FILTERS="-uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 -trim 0 -C 50 -baq 1 -skipTriallelic 1 -minMapQ 20 -minQ 20 -minMaf 0.05 -SNP_pval 1e-5"
TODO="-doMaf 1 -doMajorMinor 1 -doSaf 1 -doCounts 1"

export MIL_GENOME=$STOCKYARD/honsgen/Amil.symb.cat.genome.fasta

# producing .saf files (instruction file = angsaf)

>angsaf
for pop in *.bamlist
do
echo "angsd -b $pop -GL 1 -ref $MIL_GENOME -anc $MIL_GENOME -out ${pop/.bamlist} $FILTERS $TODO -P 8" >> angsaf
done

# run angsaf job file 

# running fst sliding window analysis (instruction file = sfs) 
# make sure when the output of this is saved, it is saved into a SPECIES folder as there is no mention of species in the file names

>sfs
echo "realSFS aut.saf.idx spr.saf.idx > aut.spr.ml && \
realSFS fst index aut.saf.idx spr.saf.idx -sfs aut.spr.ml -fstout Fst && \
realSFS fst stats Fst.fst.idx && \
realSFS fst stats2 Fst.fst.idx -win 100000 -step 10000 > slidingwindow.fst.txt " >> sfs

# run sfs job file 
# download slidingwindow.fst.txt file to local computer - use manhattan.R script to make plot