#!/bin/bash
set -euo pipefail

source config/project.env
mkdir -p results/pathogen

NONHOST_R1="results/nonhost/${SAMPLE}_nonhost_R1.fq.gz"
NONHOST_R2="results/nonhost/${SAMPLE}_nonhost_R2.fq.gz"

kraken2 \
  --db refs/kraken_curated \
  --paired \
  --threads "$THREADS" \
  --use-names \
  --report "results/pathogen/${SAMPLE}.k2.report" \
  --output "results/pathogen/${SAMPLE}.k2.out" \
  "$NONHOST_R1" "$NONHOST_R2"
