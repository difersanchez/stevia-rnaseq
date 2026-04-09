#!/bin/bash
set -euo pipefail

source config/project.env
mkdir -p results/qc/trimmed

#Parallelization removed for messing with JVM allocation.
#fastqc -t 2 -o results/qc/trimmed \
fastqc -o results/qc/trimmed \
  "results/trim/${SAMPLE}_R1.trim.fq.gz" \
  "results/trim/${SAMPLE}_R2.trim.fq.gz"
