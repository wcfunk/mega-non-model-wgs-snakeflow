## Major Updates
Eric and I made some changes to accomodate processing new fastq files with the addition of stored gvcf files from a previous run

1. Configs can largely stay the same as before as long as the ref genome is the same. scaff_groups, chromosomes, and scatters can remain the same. You will need to make a new units file. I suggest prepping a units file for the new fastqs and merging with the old units in R. I will add my updated prep-configs.Rmd here soon.

2. Update snakemake. I used 8.20.4 here

3. I had some timestamp errors that resulted from hardlinking the bams below downsampling threshold into the downsampled folder. If needed, copy or move those files to the donwsampled folder and touch them to update the timestamp. This should resolve any errors. As a last resort you can use snakemake --touch to adjust the timestamps for all files.

4. I made some workflow changes to allow addition and genotyping of stored gvcfs to the workflow. The previous workflow used the gvcf sections to construct the genomic databases, bypassing the gvcf files. We fixed this. Just rclone the files you want to add straight into results/bqsr-round-0/gvcf
