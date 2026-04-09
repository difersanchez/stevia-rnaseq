#!/bin/bash
set -euo pipefail

source config/project.env
mkdir -p refs/host

datasets download genome accession "$HOST_ACC" \
  --include genome \
  --filename refs/host/stevia_host.zip

unzip -o refs/host/stevia_host.zip -d refs/host/

HOST_FASTA=$(find refs/host/ncbi_dataset/data -type f -name "*.fna" | head -n 1)

if [ -z "${HOST_FASTA:-}" ]; then
  echo "ERROR: could not find host FASTA"
  exit 1
fi

ln -sf "$(realpath "$HOST_FASTA")" refs/host/stevia.fa
