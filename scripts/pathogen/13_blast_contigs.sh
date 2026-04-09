#!/bin/bash
set -euo pipefail

source config/project.env

blastn \
  -query "results/assembly/${SAMPLE}_rnaspades/transcripts.fasta" \
  -db refs/validation/pathogen_refs \
  -num_threads "$THREADS" \
  -evalue 1e-10 \
  -max_target_seqs 10 \
  -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore" \
  > "results/pathogen/${SAMPLE}.contigs_vs_pathogen_refs.tsv"
