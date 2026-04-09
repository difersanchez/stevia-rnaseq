#!/bin/bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Create all Conda/Mamba environments for the Stevia pathogen RNA-seq pipeline
#
# Usage:
#   bash create_mamba_envs.sh
#
# Assumptions:
#   - Miniforge / Mambaforge / Conda is already installed
#   - This script is run from the project root, or the envs directory below is
#     edited to point to the correct location
# -----------------------------------------------------------------------------

# If Miniforge is installed in the default home location, initialize Conda.
# Comment this block out if your cluster uses a module system instead.
if [ -f "$HOME/miniforge3/etc/profile.d/conda.sh" ]; then
  source "$HOME/miniforge3/etc/profile.d/conda.sh"
fi

# Fail early if mamba is unavailable
if ! command -v mamba >/dev/null 2>&1; then
  echo "ERROR: mamba is not in PATH. Activate your conda/miniforge installation first."
  exit 1
fi

# Use the env definitions from ./envs by default
ENV_DIR="./envs"

if [ ! -d "$ENV_DIR" ]; then
  echo "ERROR: env directory not found: $ENV_DIR"
  exit 1
fi

mamba env create -f "$ENV_DIR/stevia_setup.yml"
mamba env create -f "$ENV_DIR/stevia_rnaseq.yml"
mamba env create -f "$ENV_DIR/stevia_pathogen.yml"
mamba env create -f "$ENV_DIR/stevia_report.yml"

echo "[OK] All environments created successfully."
echo "Available environments:"
conda env list
