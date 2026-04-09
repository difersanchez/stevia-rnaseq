#!/bin/bash
set -euo pipefail

source config/project.env
mkdir -p results/trim

fastp \
  -i "$R1" \
  -I "$R2" \
  -o "results/trim/${SAMPLE}_R1.trim.fq.gz" \
  -O "results/trim/${SAMPLE}_R2.trim.fq.gz" \
  --detect_adapter_for_pe \
  --thread "$THREADS" \
  --html "results/trim/${SAMPLE}.fastp.html" \
  --json "results/trim/${SAMPLE}.fastp.json"
