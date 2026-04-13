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
  -p 2 \
  -x "$INDEX_BASE" \
  -1 "$TRIM_R1" \
  -2 "$TRIM_R2" \
  --summary-file "results/host/${SAMPLE}.hisat2.summary.txt" \
  --new-summary \
  --time \
  --no-temp-splicesite \
  --max-intronlen 20000 \
  -k 1 \
  --max-seeds 10 \
  --no-mixed \
  --no-discordant \
  --no-unal \
  --un-conc-gz "results/nonhost/${SAMPLE}_nonhost_R%.fq.gz" \
  2> "results/host/${SAMPLE}.hisat2.stderr.log" \
  -S results/host/temp.sam

# After HISAT2 finishes...
echo "HISAT2 finished. Starting memory cleanup..."

echo "Checking memory status"
free -h

sync   # Force flush buffers to disk

echo "Sleeping after flushing memory"
sleep 15

# Check memory to see if the OS cleared the HISAT2 index
echo "After sleeping memory status:"
free -h

echo "Running samtools sort "

samtools sort -@ 2 -m 4G -o "$HOST_BAM" results/host/temp.sam
rm results/host/temp.sam


samtools index "$HOST_BAM"
samtools flagstat "$HOST_BAM" > "results/host/${SAMPLE}.flagstat.txt"
samtools idxstats "$HOST_BAM" > "results/host/${SAMPLE}.idxstats.txt"

echo "Finished. Check results/host/ and results/nonhost/"
