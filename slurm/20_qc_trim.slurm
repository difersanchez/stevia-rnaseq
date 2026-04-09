#!/bin/bash
#SBATCH --job-name=stevia_hisat2_index
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --time=4:00:00
#SBATCH --output=logs/%x_%j.out  # Standard output log
#SBATCH --error=logs/%x_%j.err   # Standard error log
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=difersanchez@pol.una.py

set -euo pipefail
source "$HOME/miniforge3/etc/profile.d/conda.sh"
conda activate stevia_rnaseq

bash scripts/qc/01_fastqc_raw.sh
bash scripts/qc/02_fastp_trim.sh
bash scripts/qc/03_fastqc_trimmed.sh
bash scripts/qc/04_multiqc.sh
