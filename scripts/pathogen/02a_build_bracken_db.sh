#!/bin/bash
set -euo pipefail

source config/project.env
export SAMPLE

TRIM_READ_LEN=$(python - <<'PY'
import gzip, os
sample = os.path.join("results", "trim", os.environ["SAMPLE"] + "_R1.trim.fq.gz")
n = 0
total = 0
with gzip.open(sample, "rt") as fh:
    for i, line in enumerate(fh, 1):
        if i % 4 == 2:
            total += len(line.rstrip())
            n += 1
            if n == 100000:
                break
print(round(total / n))
PY
)

echo "Detected read length: $TRIM_READ_LEN"

DB_DIR="refs/kraken_curated"

THREADS=1

echo "Step 1: Generating the numeric k-mer map (prelim_map.txt)..."
# We run kraken2-build again. Since hash.k2d exists, 
# it will skip the build and just generate the map.
kraken2-build --threads "$THREADS" --db "$DB_DIR" --kmer-len 35 --build

echo "Step 2: Verifying prelim_map.txt..."
# This should now show numbers (TaxIDs) instead of "ACCNUM"
head "$DB_DIR/prelim_map.txt"

echo "Step 3: Running Bracken build..."
# Now we use the Bracken-specific tool with the read length
bracken-build -d "$DB_DIR" -t "$THREADS" -k 35 -l "$TRIM_READ_LEN"


echo "ALL DONE"
