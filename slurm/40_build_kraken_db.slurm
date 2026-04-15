#!/bin/bash
#SBATCH --job-name=stevia_kraken_build
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=64G
#SBATCH --time=8:00:00
#SBATCH --output=logs/%x_%j.out  # Standard output log
#SBATCH --error=logs/%x_%j.err   # Standard error log
##SBATCH --mail-type=BEGIN,END,FAIL
##SBATCH --mail-user=user@youremail.com # your email

# Try to set the limit to unlimited for this session
ulimit -l unlimited || echo "Could not set ulimit to unlimited"
ulimit -v unlimited || echo "Could not set ulimit to unlimited"

set -euo pipefail
source "$HOME/miniforge3/etc/profile.d/conda.sh"
conda activate stevia_pathogen

echo "Running kraken"

bash scripts/pathogen/01_build_kraken_db.sh

echo "DONE:scripts/pathogen/01_build_kraken_db.sh"

#bash scripts/pathogen/01a_fix_kraken_database.sh #run this if 01 fails 

echo "Running bracken build database"

bash scripts/pathogen/02_build_bracken_db.sh

echo "DONE: scripts/pathogen/02_build_bracken_db.sh"

echo "DONE: SLURM JOB"
