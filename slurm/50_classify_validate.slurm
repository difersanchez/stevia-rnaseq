#!/bin/bash
#SBATCH --job-name=stevia_pathogen_scan
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=60G
#SBATCH --time=16:00:00
#SBATCH --output=logs/%x_%j.out  # Standard output log
#SBATCH --error=logs/%x_%j.err   # Standard error log
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=difersanchez@pol.una.py

# --- START TIMING ---
start_time=$(date +%s)
start_date=$(date)

echo "----------------------------------------------------"
echo "Job started at: $start_date"
echo "----------------------------------------------------"


set -euo pipefail
source "$HOME/miniforge3/etc/profile.d/conda.sh"
conda activate stevia_pathogen

bash scripts/pathogen/03_kraken2_classify.sh
bash scripts/pathogen/04_bracken_species.sh
bash scripts/pathogen/05_bracken_genus.sh
bash scripts/pathogen/06_extract_candidate_species.sh
bash scripts/pathogen/07_build_validation_fasta.sh
bash scripts/pathogen/08_make_blast_db.sh
bash scripts/pathogen/09_build_bowtie2_validation_index.sh
bash scripts/pathogen/10_align_nonhost_to_validation_refs.sh
bash scripts/pathogen/11_compute_validation_metrics.sh
bash scripts/pathogen/12_rnaspades_assembly.sh
bash scripts/pathogen/13_blast_contigs.sh

# --- END TIMING ---
end_time=$(date +%s)
end_date=$(date)
runtime_seconds=$((end_time - start_time))

echo "----------------------------------------------------"
echo "Job finished at: $end_date"
echo "Total runtime: $((runtime_seconds / 60)) minutes and $((runtime_seconds % 60)) seconds"
echo "----------------------------------------------------"
