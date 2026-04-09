#!/bin/bash
set -euo pipefail

source config/project.env
mkdir -p refs/host/hisat2_index

HOST_FASTA="refs/host/stevia.fa"
test -s "$HOST_FASTA"

rm -rf refs/host/hisat2_index/*
hisat2-build -p "$THREADS" "$HOST_FASTA" refs/host/hisat2_index/stevia
