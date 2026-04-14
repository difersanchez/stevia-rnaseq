#!/bin/bash
set -euo pipefail

# Try to lift the shell limits
ulimit -l unlimited || true

source config/project.env
#kraken2-build --build --threads "$THREADS" --db refs/kraken_curated
kraken2-build --build --threads 1 --db refs/kraken_curated

