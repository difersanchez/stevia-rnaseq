#!/bin/bash
#SBATCH --job-name=stevia_hisat2_index
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=50G
#SBATCH --time=4:00:00
#SBATCH --output=logs/%x_%j.out  # Standard output log
#SBATCH --error=logs/%x_%j.err   # Standard error log
#SBATCH --mail-type=BEGIN,END,FAIL   
#SBATCH --mail-user=difersanchez@pol.una.py

set -euo pipefail
source "$HOME/miniforge3/etc/profile.d/conda.sh"
conda activate stevia_rnaseq

bash scripts/host/01_build_hisat2_index.sh
