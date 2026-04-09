#!/bin/bash
set -euo pipefail

source config/project.env
kraken2-build --build --threads "$THREADS" --db refs/kraken_curated
