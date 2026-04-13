#!/bin/bash
#SBATCH --job-name=stevia_kraken_build
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=60G
#SBATCH --time=8:00:00
#SBATCH --output=logs/%x_%j.out  # Standard output log
#SBATCH --error=logs/%x_%j.err   # Standard error log
##SBATCH --mail-type=BEGIN,END,FAIL
##SBATCH --mail-user=user@youremail.com # your email

set -euo pipefail
source "$HOME/miniforge3/etc/profile.d/conda.sh"
conda activate stevia_pathogen

bash scripts/pathogen/01_build_kraken_db.sh
bash scripts/pathogen/02_build_bracken_db.sh
