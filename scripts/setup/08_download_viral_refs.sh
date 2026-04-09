#!/bin/bash
set -euo pipefail

rm -rf refs/custom_refs/ngd_viral
mkdir -p refs/custom_refs/ngd_viral

scripts/helpers/retry_download.sh "ncbi-genome-download \
  --section refseq \
  --formats fasta \
  --parallel 1 \
  --no-cache \
  --output-folder refs/custom_refs/ngd_viral \
  viral"
