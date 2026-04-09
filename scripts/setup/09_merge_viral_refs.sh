#!/bin/bash
set -euo pipefail

: > refs/custom_refs/custom_viral.fa

find refs/custom_refs/ngd_viral -type f -name "*.fna.gz" | sort | while read -r f; do
  gzip -cd "$f" >> refs/custom_refs/custom_viral.fa
done

test -s refs/custom_refs/custom_viral.fa
