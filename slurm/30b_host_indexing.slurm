#!/bin/bash
#SBATCH --job-name=stevia_host_indexing
#SBATCH --nodes=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=64G
#SBATCH --time=1:00:00
#SBATCH --output=logs/%x_%j.out  # Standard output log
#SBATCH --error=logs/%x_%j.err   # Standard error log
##SBATCH --mail-type=BEGIN,END,FAIL
##SBATCH --mail-user=user@youremail.com # your email


# This is only implemented for low resources HPC
# DO NOT run if 30_host_filter.slurm ran without issues.

set -euo pipefail
source "$HOME/miniforge3/etc/profile.d/conda.sh"
conda activate stevia_rnaseq

bash scripts/host/02b_host_reads_indexing.sh
echo "indexing finished"
