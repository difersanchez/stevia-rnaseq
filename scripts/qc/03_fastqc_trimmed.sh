#!/bin/bash
set -euo pipefail

source config/project.env
mkdir -p results/qc/trimmed

fastqc -t "$THREADS" -o results/qc/trimmed \
  "results/trim/${SAMPLE}_R1.trim.fq.gz" \
  "results/trim/${SAMPLE}_R2.trim.fq.gz"
