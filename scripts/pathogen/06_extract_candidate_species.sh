#!/bin/bash
set -euo pipefail

source config/project.env

awk -F'\t' '$4=="S" && $2>=25 {gsub(/^ +/,"",$6); print $5"\t"$6"\t"$2}' \
  "results/pathogen/${SAMPLE}.k2.report" \
  > "results/pathogen/${SAMPLE}.candidate_species.tsv"
