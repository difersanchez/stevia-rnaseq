#!/bin/bash
set -euo pipefail

source config/project.env

mkdir -p results/host/hisat2 results/nonhost results/host

INDEX_BASE="refs/host/hisat2_index/stevia"
TRIM_R1="results/trim/${SAMPLE}_R1.trim.fq.gz"
TRIM_R2="results/trim/${SAMPLE}_R2.trim.fq.gz"
HOST_BAM="results/host/hisat2/${SAMPLE}.host.sorted.bam"

if [ ! -s "${INDEX_BASE}.1.ht2" ] && [ ! -s "${INDEX_BASE}.1.ht2l" ]; then
  echo "ERROR: HISAT2 index not found"
  exit 1
fi

hisat2 \
  -p "$THREADS" \
  -x "$INDEX_BASE" \
  -1 "$TRIM_R1" \
  -2 "$TRIM_R2" \
  --summary-file "results/host/${SAMPLE}.hisat2.summary.txt" \
  --new-summary \
  --un-conc-gz "results/nonhost/${SAMPLE}_nonhost_R%.fq.gz" \
  2> "results/host/${SAMPLE}.hisat2.stderr.log" \
| samtools sort -@ 4 -o "$HOST_BAM" -

samtools index "$HOST_BAM"
samtools flagstat "$HOST_BAM" > "results/host/${SAMPLE}.flagstat.txt"
samtools idxstats "$HOST_BAM" > "results/host/${SAMPLE}.idxstats.txt"
