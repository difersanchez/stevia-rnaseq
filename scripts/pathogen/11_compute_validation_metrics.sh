#!/bin/bash
set -euo pipefail

source config/project.env

samtools idxstats "results/pathogen/${SAMPLE}.vs_pathogens.bam" > "results/pathogen/${SAMPLE}.idxstats.tsv"
samtools coverage "results/pathogen/${SAMPLE}.vs_pathogens.bam" > "results/pathogen/${SAMPLE}.coverage.tsv"
samtools depth -aa "results/pathogen/${SAMPLE}.vs_pathogens.bam" > "results/pathogen/${SAMPLE}.depth.tsv"
