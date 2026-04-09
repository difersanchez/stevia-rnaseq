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

bracken-build -d refs/kraken_curated -t "$THREADS" -k 35 -l "$TRIM_READ_LEN"
