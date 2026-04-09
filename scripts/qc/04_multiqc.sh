#!/bin/bash
set -euo pipefail

mkdir -p results/qc/multiqc
multiqc -o results/qc/multiqc results/qc/raw results/qc/trimmed results/trim
