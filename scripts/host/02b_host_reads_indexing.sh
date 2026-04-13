#!/bin/bash

set -euo pipefail

source config/project.env

#This script is not necessary if the HPC handle samtools with out issues

# DO NOT run this if script 02_filter_host_reads.sh was successfully ran
# This was designed as an alternative for low resources HPC


HOST_BAM="results/host/hisat2/${SAMPLE}.host.sorted.bam"

# Checking memory
echo "Memory status:"
free -h

echo "Running samtools sort "

# more restrictive run
samtools sort -@ 2 -m 1G -T results/host/${SAMPLE}_sorting -o "$HOST_BAM" results/host/temp.sam
#samtools sort -@ 2 -m 4G -o "$HOST_BAM" results/host/temp.sam

echo "Sorting done"

samtools index "$HOST_BAM"

echo "Indexing finished"

samtools flagstat "$HOST_BAM" > "results/host/${SAMPLE}.flagstat.txt"
samtools idxstats "$HOST_BAM" > "results/host/${SAMPLE}.idxstats.txt"

echo "Finished. Check results/host/ and results/nonhost/"
