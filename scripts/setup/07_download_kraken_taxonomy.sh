#!/bin/bash
set -euo pipefail

mkdir -p refs/kraken_curated
kraken2-build --download-taxonomy --db refs/kraken_curated --use-ftp
