#!/bin/bash
#SBATCH --job-name=stevia_qc_trim
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=48G
#SBATCH --time=4:00:00
#SBATCH --output=logs/%x_%j.out  # Standard output log
#SBATCH --error=logs/%x_%j.err   # Standard error log
##SBATCH --mail-type=BEGIN,END,FAIL
##SBATCH --mail-user=difersanchez@pol.una.py

set -euo pipefail

# Avoiding fastqc JVM complaining for memory allocation
# -Xms is the starting memory, -Xmx is the limit.
#export _JAVA_OPTIONS="-Xms512m -Xmx2g -XX:CompressedClassSpaceSize=512m" #removed parallelization in fastqc runs

source "$HOME/miniforge3/etc/profile.d/conda.sh"
conda activate stevia_rnaseq

bash scripts/qc/01_fastqc_raw.sh
bash scripts/qc/02_fastp_trim.sh
bash scripts/qc/03_fastqc_trimmed.sh
bash scripts/qc/04_multiqc.sh
