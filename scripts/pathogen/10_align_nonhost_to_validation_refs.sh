#!/bin/bash
set -euo pipefail

source config/project.env
mkdir -p results/pathogen

NONHOST_R1="results/nonhost/${SAMPLE}_nonhost_R1.fq.gz"
NONHOST_R2="results/nonhost/${SAMPLE}_nonhost_R2.fq.gz"

bowtie2 \
  --very-sensitive-local \
  -x refs/validation/all_refs \
  -1 "$NONHOST_R1" \
  -2 "$NONHOST_R2" \
  -p "$THREADS" 2> "results/pathogen/${SAMPLE}.bowtie2.log" \
  | samtools sort -@ 4 -o "results/pathogen/${SAMPLE}.vs_pathogens.bam"

samtools index "results/pathogen/${SAMPLE}.vs_pathogens.bam"
