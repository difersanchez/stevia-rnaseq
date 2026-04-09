#!/bin/bash
set -euo pipefail

mkdir -p refs/validation

find refs/kraken_curated/library -type f \
  \( -name "*.fa" -o -name "*.fna" -o -name "*.fasta" -o -name "*.fa.gz" -o -name "*.fna.gz" -o -name "*.fasta.gz" \) \
  | sort | while read -r f; do
    case "$f" in
      *.gz) gzip -cd "$f" ;;
      *) cat "$f" ;;
    esac
  done > refs/validation/all_refs.fa

awk '/^>/{acc=$1; sub(/^>/,"",acc); hdr=substr($0,2); sub(/^[^ ]+ ?/,"",hdr); print acc "\t" hdr}' \
  refs/validation/all_refs.fa > refs/validation/reference_map.tsv
