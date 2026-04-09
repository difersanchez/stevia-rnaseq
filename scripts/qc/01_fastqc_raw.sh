#!/bin/bash
set -euo pipefail

source config/project.env
mkdir -p results/qc/raw

fastqc -t "$THREADS" -o results/qc/raw "$R1" "$R2"
