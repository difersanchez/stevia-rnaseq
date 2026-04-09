#!/bin/bash
set -euo pipefail

source config/project.env
mkdir -p results/qc/raw

# Removing parallelization because it messed up the HPC mem allocation
#fastqc -t 2 -o results/qc/raw "$R1" "$R2"

fastqc -o results/qc/raw "$R1" "$R2"

