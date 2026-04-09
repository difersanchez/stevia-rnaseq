#!/bin/bash
set -euo pipefail

mkdir -p refs/custom_refs/ngd_bacteria
BACT_G=$(cat refs/custom_lists/bacteria_genera.txt)

scripts/helpers/retry_download.sh "ncbi-genome-download \
  --section refseq \
  --formats fasta \
  --assembly-levels complete,chromosome,scaffold \
  --refseq-categories reference,representative \
  --genera \"$BACT_G\" \
  --parallel 1 \
  --no-cache \
  --output-folder refs/custom_refs/ngd_bacteria \
  bacteria"
