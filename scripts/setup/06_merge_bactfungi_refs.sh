#!/bin/bash
set -euo pipefail

mkdir -p refs/custom_refs
: > refs/custom_refs/custom_bactfungi.fa

find refs/custom_refs/ngd_bacteria refs/custom_refs/ngd_fungi -type f -name "*.fna.gz" | sort | while read -r f; do
  gzip -cd "$f" >> refs/custom_refs/custom_bactfungi.fa
done

test -s refs/custom_refs/custom_bactfungi.fa
