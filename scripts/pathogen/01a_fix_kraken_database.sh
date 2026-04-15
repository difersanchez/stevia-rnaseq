#!/bin/bash
set -euo pipefail

# Try to lift the shell limits
ulimit -l unlimited || true

source config/project.env

# Creating the database.kraken missed
# We run this on your added library files to see where their k-mers land
kraken2 --db refs/kraken_curated --threads 1 \
    --report refs/kraken_curated/database.report \
    refs/kraken_curated/library/added/*.fna > refs/kraken_curated/database.kraken

echo "DONE: refs/kraken_curated/database.kraken"

# Creating the missed prelim_map.txt file
# This pulls TaxID (col 5) and K-mer count (col 2) from the report
# and puts them in the root folder where Bracken expects them.
awk -F$'\t' '{print $5 "\t" $2}' refs/kraken_curated/database.report > refs/kraken_curated/prelim_map.txt

echo "prelim_map.txt DONE!"

head refs/kraken_curated/prelim_map.txt

echo "ALL DONE"
