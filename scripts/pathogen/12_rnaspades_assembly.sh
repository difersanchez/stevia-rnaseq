#!/bin/bash
set -euo pipefail

source config/project.env
mkdir -p results/assembly

NONHOST_R1="results/nonhost/${SAMPLE}_nonhost_R1.fq.gz"
NONHOST_R2="results/nonhost/${SAMPLE}_nonhost_R2.fq.gz"

rnaspades.py \
  -1 "$NONHOST_R1" \
  -2 "$NONHOST_R2" \
  -t "$THREADS" \
  -m 120 \
  -o "results/assembly/${SAMPLE}_rnaspades"
