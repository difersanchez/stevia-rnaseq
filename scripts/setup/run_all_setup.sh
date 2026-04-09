#!/bin/bash
set -euo pipefail

source "$HOME/miniforge3/etc/profile.d/conda.sh"
conda activate stevia_setup

bash scripts/setup/01_estimate_read_length.sh
bash scripts/setup/02_download_host_genome.sh
bash scripts/setup/03_write_curated_lists.sh
bash scripts/setup/04_download_bacteria_refs.sh
bash scripts/setup/05_download_fungi_refs.sh
bash scripts/setup/06_merge_bactfungi_refs.sh
bash scripts/setup/07_download_kraken_taxonomy.sh
bash scripts/setup/08_download_viral_refs.sh
bash scripts/setup/09_merge_viral_refs.sh
bash scripts/setup/10_add_refs_to_kraken_library.sh
