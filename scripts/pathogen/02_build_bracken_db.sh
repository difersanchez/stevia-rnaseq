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

# Going into the DB directory so paths are relative and easy for Bracken
cd refs/kraken_curated

# Ensure the prelim_map is where Bracken expects it (root of the DB)
if [ ! -f "prelim_map.txt" ]; then
    cp taxonomy/prelim_map.txt .
fi

# Run the build again
# Using -d . because we are already inside the directory
bracken-build -d . -t 1 -k 35 -l "$TRIM_READ_LEN"

#bracken-build -d refs/kraken_curated -t "$THREADS" -k 35 -l "$TRIM_READ_LEN"

