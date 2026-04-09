#!/bin/bash
set -euo pipefail

makeblastdb \
  -in refs/validation/all_refs.fa \
  -dbtype nucl \
  -parse_seqids \
  -out refs/validation/pathogen_refs
