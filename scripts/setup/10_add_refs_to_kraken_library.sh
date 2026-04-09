#!/bin/bash
set -euo pipefail

test -s refs/custom_refs/custom_viral.fa
test -s refs/custom_refs/custom_bactfungi.fa

kraken2-build --add-to-library refs/custom_refs/custom_viral.fa --db refs/kraken_curated
kraken2-build --add-to-library refs/custom_refs/custom_bactfungi.fa --db refs/kraken_curated
